//
//  ContactTableViewCell.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/10/24.
//

import Foundation
import UIKit

class ContactTableViewCell: UITableViewCell {
    static let identifier: String = "ContactTableViewCell"
    
    // MARK: - UI Components
    private let contactImageView: UIImageView = CircularImageView(cornerRadius: 25)
    
    private let contactNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .debtMateBlack
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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contactImageView.image = nil
        self.contactNameLabel.text = nil
    }
    
    // MARK: - UI Setup
    private func setupCell() {
        self.backgroundColor = .systemBackground
        
        contentView.addSubview(contactImageView)
        contentView.addSubview(contactNameLabel)
        
        NSLayoutConstraint.activate([
            contactImageView.widthAnchor.constraint(equalToConstant: 50),
            contactImageView.heightAnchor.constraint(equalToConstant: 50),
            contactImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            contactImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contactImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            contactNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contactNameLabel.leadingAnchor.constraint(equalTo: contactImageView.trailingAnchor, constant: 12),
            contactNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configCell(contact: Contact) {
        contactNameLabel.text = contact.name
        
        if let image = contact.profileImage {
            contactImageView.image = image
        } else {
            contactImageView.image = UIImage(named: "mock-profile")
        }
    }
    
    func configCell(person: Person) {
        contactNameLabel.text = person.fullName
        
        contactImageView.setImage(imageURL: person.imageURL,
                                  placeholder: UIImage(named: "mock-profile"))
    }
}

