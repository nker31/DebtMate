//
//  SwitchTableViewCell.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/6/24.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {
    // MARK: - Varibles
    static let identifier = "SwitchTableViewCellIndentifier"
    
    // MARK: - UI Components
    let toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        return toggleSwitch
    }()
    
    // MARK: - Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    // MARK: - UI Setup
    private func setupCell() {
        contentView.addSubview(toggleSwitch)
        
        NSLayoutConstraint.activate([
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
