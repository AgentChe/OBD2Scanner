//
//  RestAPITransport.swift
//  Soccer
//
//  Created by Андрей Чернышев on 11.03.2022.
//

import RxSwift
import Alamofire

final class RestAPITransport {
    func callServerApi(requestBody: APIRequestBody) -> Single<Any> {
        Single.create { single in
            let manager = Alamofire.Session.default
            manager.session.configuration.timeoutIntervalForRequest = 30
            
            let encodedUrl = requestBody.url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            let request = manager.request(
                encodedUrl,
                method: requestBody.method,
                parameters: requestBody.parameters,
                encoding: requestBody.encoding,
                headers: requestBody.headers
            )
            .validate(statusCode: requestBody.validStatusCodes)
            .response { response in
                if let error = response.error {
                    single(.failure(NetworkError(.serverNotAvailable, underlyingError: error)))
                } else if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        single(.success(json))
                    } catch let error {
                        single(.failure(NetworkError(.serverNotAvailable, underlyingError: error)))
                    }
                } else {
                    single(.failure(NetworkError(.serverNotAvailable)))
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
