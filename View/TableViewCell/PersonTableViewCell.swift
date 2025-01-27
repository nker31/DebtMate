//
//  PersonTableViewCell.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/12/24.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    // MARK: - Varibles
    static let identifier = "PersonTableViewCellIdentifier"
    
    // MARK: - UI Components
    var personImageView: UIImageView = CircularImageView(cornerRadius: 30)
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    var subLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .light)
        return label
    }()
    
    var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    var personDetailRow: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 16
        stackView.alignment = .fill
        return stackView
    }()

    // MARK: - Initializer
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
        self.backgroundColor = .systemBackground
        
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subLabel)
        
        personDetailRow.addArrangedSubview(personImageView)
        personDetailRow.addArrangedSubview(textStackView)
        
        self.addSubview(personDetailRow)
        
        NSLayoutConstraint.activate([
            personDetailRow.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            personDetailRow.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            personDetailRow.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            personDetailRow.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15),
            
            personImageView.widthAnchor.constraint(equalToConstant: 60),
            personImageView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    func configCell(person: Person, balance: Float?) {
        if let imageURL = person.imageURL {
            personImageView.setImage(imageURL: imageURL)
        } else {
            personImageView.image = UIImage(named: "mock-profile")
        }
        
        if let balance {
            if balance < 0 {
                subLabel.text = "\(String(localized: "person_cell_borrowed_label")): \(balance * -1)"
            } else if balance > 0 {
                subLabel.text = "\(String(localized: "person_cell_lent_label")): \(balance)"
            } else {
                subLabel.text = "\(String(localized: "person_cell_balance_label")): 0"
            }
        } else {
            subLabel.text = String(localized: "person_cell_no_transaction_label")
        }
        
        titleLabel.text = person.fullName
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
        self.subLabel.text = nil
        self.personImageView.image = nil
    }
}
