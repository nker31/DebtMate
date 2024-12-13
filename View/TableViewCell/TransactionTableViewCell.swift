//
//  TransactionTableViewCell.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/13/24.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    // MARK: - Varibles
    static let identifier = "TransactionTableViewCell"
    
    // MARK: - UI Elements
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 1
        label.textColor = .label
        return label
    }()
        
    private var subLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()
        
    private var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var paidLabel: UILabel = {
        let label = UILabel()
        label.text = "Paid"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        label.textColor = .systemGreen
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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

        contentView.addSubview(textStackView)
        contentView.addSubview(paidLabel)
        
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subLabel)

        NSLayoutConstraint.activate([
            textStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            textStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            textStackView.trailingAnchor.constraint(equalTo: paidLabel.leadingAnchor, constant: -10),
            textStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
            paidLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            paidLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }
    
    func configCell(transaction: Transaction) {
        configureTitleLabel(for: transaction)
        configureSubLabel(for: transaction)
        configureAppearance(for: transaction)
    }

    private func configureTitleLabel(for transaction: Transaction) {
        let isLend = transaction.isLend
        let amount = transaction.amount
        titleLabel.text = isLend ? "Lent $\(amount)" : "Borrowed $\(amount)"
    }

    private func configureSubLabel(for transaction: Transaction) {
        let description = transaction.description ?? ""
        let stringDate = transaction.createdAt.formatDate(date: transaction.createdAt, format: "MMM d, yyyy, h:mm a")
        subLabel.text = description.isEmpty ? stringDate : "\(description) | \(stringDate)"
    }

    private func configureAppearance(for transaction: Transaction) {
        if transaction.isPaid {
            self.backgroundColor = .systemGreen.withAlphaComponent(0.1)
            titleLabel.textColor = .systemGray
            subLabel.textColor = .systemGray2
            configurePaidLabel(isHidden: false, text: "✓ Paid", color: .systemGreen)
        } else {
            self.backgroundColor = .systemBackground
            titleLabel.textColor = .label
            subLabel.textColor = .secondaryLabel
            configurePaidLabel(isHidden: true)
        }
    }

    private func configurePaidLabel(isHidden: Bool, text: String? = nil, color: UIColor? = nil) {
        paidLabel.isHidden = isHidden
        if let text = text {
            paidLabel.text = text
        }
        if let color = color {
            paidLabel.textColor = color
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subLabel.text = nil
        paidLabel.isHidden = true
        paidLabel.text = "Paid"
        paidLabel.textColor = .systemGreen
        backgroundColor = .systemBackground
        titleLabel.textColor = .label
        subLabel.textColor = .label
    }
}
