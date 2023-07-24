//
//  DTCCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

import UIKit

final class DTCCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension DTCCell {
    func setup(element: DTC) {
        
    }
}

// MARK: Private
private extension DTCCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension DTCCell {
    func makeConstraints() {
        
    }
}

// MARK: Lazy initialization
private extension DTCCell {
    
}
