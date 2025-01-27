//
//  AccountTableViewCell.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/6/24.
//

import UIKit
import Kingfisher

class AccountTableViewCell: UITableViewCell {
    // MARK: - Variables
    static let identifier: String = "AccountTableViewCell"
    
    // MARK: - UI Components
    private var userImageView: UIImageView = CircularImageView(cornerRadius: 30)
    
    private var userFullnameLabel: UILabel = {
        let label = UILabel()
        label.text = "First Last"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
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
        contentView.addSubview(userImageView)
        contentView.addSubview(userFullnameLabel)
        
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            userImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            userImageView.heightAnchor.constraint(equalToConstant: 60),
            userImageView.widthAnchor.constraint(equalToConstant: 60),
            
            userFullnameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userFullnameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 15),
            userFullnameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }
    
    func configCell(userFullname: String, imageURL: String?) {
        userFullnameLabel.text = userFullname
        userImageView.setImage(imageURL: imageURL)
    }
}
