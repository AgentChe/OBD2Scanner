//
//  OBDAdapter.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

import CoreBluetooth
import RxSwift
import RxCocoa

final class OBDAdapter: NSObject {
    static let shared = OBDAdapter()
    
    private lazy var adapterStateTrigger = BehaviorRelay(value: OBDAdapterState(obd2Adapter?.adapterState ?? OBD2AdapterStateUnknown))
    
    private override init() {
        super.init()
        
        registerPIDs()
        addStateObserver()
    }
    
    private var transporter: LTBTLESerialTransporter?
    private var obd2Adapter: LTOBD2AdapterELM327?
    
    private var serviceUUIDs = [CBUUID]()
    private var pids = [LTOBD2Command]()
}

// MARK: Public
extension OBDAdapter {
    func connect() {
        transporter = LTBTLESerialTransporter(identifier: nil, serviceUUIDs: serviceUUIDs)
        transporter?.connect { [weak self] inputStream, outputStream in
            guard let self = self else {
                return
            }

            guard let inputStream = inputStream, let outputStream = outputStream else {
                return
            }

            self.obd2Adapter = LTOBD2AdapterELM327(inputStream: inputStream, outputStream: outputStream)
            self.obd2Adapter?.connect()
        }
        transporter?.startUpdatingSignalStrength(withInterval: 1)
    }

    func disconnect() {
        obd2Adapter?.disconnect()
        transporter?.disconnect()
        
        obd2Adapter = nil
        transporter = nil
    }
    
    func obtainDTC() -> Single<[DTC]> {
        Single<[DTC]>.create { event in
            guard let obd2Adapter = Self.shared.obd2Adapter else {
                event(.success([]))
                return Disposables.create()
            }

            let dtcPid = LTOBD2PID_STORED_DTC_03()
            obd2Adapter.transmitCommand(dtcPid) { command in
                let codes = dtcPid.troubleCodes.map { code -> DTC in
                    DTC(
                        ecu: code.formattedEcu,
                        code: code.formattedCode,
                        explanation: code.explanation
                    )
                }

                event(.success(codes))
            }
            
            return Disposables.create()
        }
    }
    
    func readSensorData(result: @escaping (SensorData?) -> Void) {
        guard let obd2Adapter = obd2Adapter else {
            result(nil)
            return
        }

        let rpm = LTOBD2PID_ENGINE_RPM_0C.forMode1()
        let speed = LTOBD2PID_VEHICLE_SPEED_0D.forMode1()
        let temp = LTOBD2PID_COOLANT_TEMP_05.forMode1()

        obd2Adapter.transmitMultipleCommands([rpm, speed, temp], completionHandler: { commands in
            let sensorData = SensorData(
                temp: temp.formattedResponse,
                rpm: rpm.formattedResponse,
                speed: speed.formattedResponse
            )
            result(sensorData)
        })
    }
    
    func readPIDs(result: @escaping ([LTOBD2Command]) -> Void) {
        guard let obd2Adapter = obd2Adapter else {
            result([])
            return
        }
        
        obd2Adapter.transmitMultipleCommands(pids, completionHandler: { [weak self] commands in
            result(self?.pids ?? [])
        })
    }
    
    var adapterState: Signal<OBDAdapterState> {
        adapterStateTrigger.asSignal(onErrorSignalWith: .never())
    }
}

// MARK: Private
private extension OBDAdapter {
    func registerPIDs() {
        serviceUUIDs.append(contentsOf: [
            CBUUID(string: "FFF0"),
            CBUUID(string: "FFE0"),
            CBUUID(string: "BEEF"),
            CBUUID(string: "E7810A71-73AE-499D-8C15-FAA9AEF0C3F2")
        ])
        
        pids.append(contentsOf: [
            LTOBD2CommandELM327_IGNITION_STATUS.command(),
            LTOBD2CommandELM327_READ_VOLTAGE.command(),
            LTOBD2CommandELM327_DESCRIBE_PROTOCOL.command(),
            LTOBD2PID_VIN_CODE_0902(),
            LTOBD2PID_FUEL_SYSTEM_STATUS_03.forMode1(),
            LTOBD2PID_OBD_STANDARDS_1C.forMode1(),
            LTOBD2PID_FUEL_TYPE_51.forMode1(),
            LTOBD2PID_ENGINE_LOAD_04.forMode1(),
            LTOBD2PID_COOLANT_TEMP_05.forMode1(),
            LTOBD2PID_SHORT_TERM_FUEL_TRIM_1_06.forMode1(),
            LTOBD2PID_LONG_TERM_FUEL_TRIM_1_07.forMode1(),
            LTOBD2PID_SHORT_TERM_FUEL_TRIM_2_08.forMode1(),
            LTOBD2PID_LONG_TERM_FUEL_TRIM_2_09.forMode1(),
            LTOBD2PID_FUEL_PRESSURE_0A.forMode1(),
            LTOBD2PID_INTAKE_MAP_0B.forMode1(),
            LTOBD2PID_ENGINE_RPM_0C.forMode1(),
            LTOBD2PID_VEHICLE_SPEED_0D.forMode1(),
            LTOBD2PID_TIMING_ADVANCE_0E.forMode1(),
            LTOBD2PID_INTAKE_TEMP_0F.forMode1(),
            LTOBD2PID_MAF_FLOW_10.forMode1(),
            LTOBD2PID_THROTTLE_11.forMode1(),
            LTOBD2PID_SECONDARY_AIR_STATUS_12.forMode1(),
            LTOBD2PID_OXYGEN_SENSORS_PRESENT_2_BANKS_13.forMode1()
        ])

        for i in 0..<8 {
            pids.append(LTOBD2PID_OXYGEN_SENSORS_INFO_1.pid(forSensor: UInt(i), mode: 1))
        }
        
        pids.append(contentsOf: [
            LTOBD2PID_OXYGEN_SENSORS_PRESENT_4_BANKS_1D.forMode1(),
            LTOBD2PID_AUX_INPUT_1E.forMode1(),
            LTOBD2PID_RUNTIME_1F.forMode1(),
            LTOBD2PID_DISTANCE_WITH_MIL_21.forMode1(),
            LTOBD2PID_FUEL_RAIL_PRESSURE_22.forMode1(),
            LTOBD2PID_FUEL_RAIL_GAUGE_PRESSURE_23.forMode1()
        ])

        for i: UInt in 0..<8 {
            pids.append(LTOBD2PID_OXYGEN_SENSORS_INFO_2.pid(forSensor: i, mode: 1))
        }

        pids.append(contentsOf: [
            LTOBD2PID_COMMANDED_EGR_2C.forMode1(),
            LTOBD2PID_EGR_ERROR_2D.forMode1(),
            LTOBD2PID_COMMANDED_EVAPORATIVE_PURGE_2E.forMode1(),
            LTOBD2PID_FUEL_TANK_LEVEL_2F.forMode1(),
            LTOBD2PID_WARMUPS_SINCE_DTC_CLEARED_30.forMode1(),
            LTOBD2PID_DISTANCE_SINCE_DTC_CLEARED_31.forMode1(),
            LTOBD2PID_EVAP_SYS_VAPOR_PRESSURE_32.forMode1(),
            LTOBD2PID_ABSOLUTE_BAROMETRIC_PRESSURE_33.forMode1()
        ])

        for i: UInt in 0..<8 {
            pids.append(LTOBD2PID_OXYGEN_SENSORS_INFO_3.pid(forSensor: i, mode: 1))
        }
        
        pids.append(contentsOf: [
            LTOBD2PID_CATALYST_TEMP_B1S1_3C.forMode1(),
            LTOBD2PID_CATALYST_TEMP_B2S1_3D.forMode1(),
            LTOBD2PID_CATALYST_TEMP_B1S2_3E.forMode1(),
            LTOBD2PID_CATALYST_TEMP_B2S2_3F.forMode1(),
            LTOBD2PID_CONTROL_MODULE_VOLTAGE_42.forMode1(),
            LTOBD2PID_ABSOLUTE_ENGINE_LOAD_43.forMode1(),
            LTOBD2PID_AIR_FUEL_EQUIV_RATIO_44.forMode1(),
            LTOBD2PID_RELATIVE_THROTTLE_POS_45.forMode1(),
            LTOBD2PID_AMBIENT_TEMP_46.forMode1(),
            LTOBD2PID_ABSOLUTE_THROTTLE_POS_B_47.forMode1(),
            LTOBD2PID_ABSOLUTE_THROTTLE_POS_C_48.forMode1(),
            LTOBD2PID_ACC_PEDAL_POS_D_49.forMode1(),
            LTOBD2PID_ACC_PEDAL_POS_E_4A.forMode1(),
            LTOBD2PID_ACC_PEDAL_POS_F_4B.forMode1(),
            LTOBD2PID_COMMANDED_THROTTLE_ACTUATOR_4C.forMode1(),
            LTOBD2PID_TIME_WITH_MIL_4D.forMode1(),
            LTOBD2PID_TIME_SINCE_DTC_CLEARED_4E.forMode1(),
            LTOBD2PID_MAX_VALUE_FUEL_AIR_EQUIVALENCE_RATIO_4F.forMode1(),
            LTOBD2PID_MAX_VALUE_OXYGEN_SENSOR_VOLTAGE_4F.forMode1(),
            LTOBD2PID_MAX_VALUE_OXYGEN_SENSOR_CURRENT_4F.forMode1(),
            LTOBD2PID_MAX_VALUE_INTAKE_MAP_4F.forMode1(),
            LTOBD2PID_MAX_VALUE_MAF_AIR_FLOW_RATE_50.forMode1()
        ])
    }
    
    func addStateObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeAdapterState), name: .init(LTOBD2AdapterDidUpdateState), object: nil)
    }
    
    @objc
    func didChangeAdapterState() {
        guard let obd2Adapter = obd2Adapter else {
            return
        }
        
        adapterStateTrigger.accept(OBDAdapterState(obd2Adapter.adapterState))
    }
}
