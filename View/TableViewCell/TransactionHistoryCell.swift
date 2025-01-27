//
//  TransactionHistoryCell.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/15/24.
//

import UIKit

class TransactionHistoryCell: UITableViewCell {
    // MARK: - Variables
    static let identifier: String = "TransactionHistoryCell"
    
    // MARK: - UI Elements
    private lazy var typeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
        
    private lazy var personNameLabel: UILabel = createLabel(font: .boldSystemFont(ofSize: 16))
        
    private lazy var amountLabel: UILabel = {
        let label = createLabel(font: .boldSystemFont(ofSize: 16), alignment: .right)
        return label
    }()
        
    private lazy var descriptionLabel: UILabel = {
        let label = createLabel(font: .systemFont(ofSize: 14), color: .secondaryLabel)
        label.numberOfLines = 1
        return label
    }()
        
    private lazy var statusLabel: UILabel = {
        let label = createLabel(font: .systemFont(ofSize: 12), alignment: .right)
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.addSubview(typeIcon)
        contentView.addSubview(personNameLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            typeIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            typeIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            typeIcon.widthAnchor.constraint(equalToConstant: 30),
            typeIcon.heightAnchor.constraint(equalToConstant: 30),
            
            personNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            personNameLabel.leadingAnchor.constraint(equalTo: typeIcon.trailingAnchor, constant: 16),
            
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: personNameLabel.centerYAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: personNameLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: personNameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusLabel.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor)
        ])
    }
    
    private func createLabel(font: UIFont, color: UIColor = .debtMateBlack, alignment: NSTextAlignment = .natural) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = color
        label.textAlignment = alignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    // MARK: - Configuration
    func configure(with transaction: Transaction, personName: String?) {
        configureTypeIcon(for: transaction)
        personNameLabel.text = personName ?? String(localized: "transaction_history_cell_default_person_name")
        amountLabel.text = formatAmount(transaction.amount)
        descriptionLabel.text = transaction.description ?? " "
        configureStatus(for: transaction)
    }
    
    private func configureTypeIcon(for transaction: Transaction) {
        typeIcon.image = transaction.isLend ? UIImage(systemName: "arrow.up.circle") : UIImage(systemName: "arrow.down.circle")
        typeIcon.tintColor = transaction.isLend ? .systemGreen : .systemRed
    }
    
    private func configureStatus(for transaction: Transaction) {
        if !transaction.isPaid {
            if let dueDate = transaction.dueDate {
                statusLabel.text = Date() > dueDate ? String(localized: "transaction_history_cell_unpaid_overdue_status") : String(localized: "transaction_history_cell_unpaid_status")
            } else {
                statusLabel.text = String(localized: "transaction_history_cell_unpaid_status")
            }
            statusLabel.textColor = .systemOrange
        } else {
            statusLabel.text = String(localized: "transaction_history_cell_paid_status")
            statusLabel.textColor = .systemGreen
        }
    }
    
    private func formatAmount(_ amount: Float) -> String {
        return String(format: "$%.2f", amount)
    }
}
