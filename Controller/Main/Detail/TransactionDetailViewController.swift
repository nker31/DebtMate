//
//  TransactionDetailViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/15/24.
//

import UIKit

class TransactionDetailViewController: UIViewController {
    // MARK: - Varibles
    private var viewModel: TransactionDetailViewModel
    
    // MARK: - UI Components
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let transactionTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var detailsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            descriptionView,
            dueDateView,
            statusView,
            createdAtView
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var descriptionView = createDetailRow(title: String(localized: "transaction_detail_description_label"), icon: UIImage(systemName: "doc.text"))
    private lazy var  dueDateView = createDetailRow(title: String(localized: "transaction_detail_due_date_label"), icon: UIImage(systemName: "calendar"))
    private lazy var  statusView = createDetailRow(title: String(localized: "transaction_detail_status_label"), icon: UIImage(systemName: "checkmark.circle"))
    private lazy var  createdAtView = createDetailRow(title: String(localized: "transaction_detail_created_at_label"), icon: UIImage(systemName: "clock"))
    
    private let markAsPaidButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapMarkButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializer
    init(viewModel: TransactionDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.delegate = self
        viewModel.setupTransactionData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(amountLabel)
        view.addSubview(transactionTypeLabel)
        view.addSubview(detailsStackView)
        view.addSubview(markAsPaidButton)
        
        NSLayoutConstraint.activate([
            amountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            transactionTypeLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 8),
            transactionTypeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            transactionTypeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            detailsStackView.topAnchor.constraint(equalTo: transactionTypeLabel.bottomAnchor, constant: 30),
            detailsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            detailsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            markAsPaidButton.topAnchor.constraint(equalTo: detailsStackView.bottomAnchor, constant: 30),
            markAsPaidButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            markAsPaidButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            markAsPaidButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createDetailRow(title: String, icon: UIImage?) -> UIStackView {
        let iconView = UIImageView(image: icon)
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title
        
        let titleStackView = UIStackView(arrangedSubviews: [iconView, titleLabel])
        titleStackView.axis = .horizontal
        titleStackView.alignment = .leading
        titleStackView.spacing = 8
        
        let valueLabel = UILabel()
        valueLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 1
        
        let detailStackView = UIStackView(arrangedSubviews: [titleStackView, valueLabel])
        detailStackView.axis = .horizontal
        detailStackView.spacing = 8
        detailStackView.alignment = .leading
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        detailStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            titleStackView.widthAnchor.constraint(equalTo: detailStackView.widthAnchor, multiplier: 0.35),
            valueLabel.widthAnchor.constraint(equalTo: detailStackView.widthAnchor, multiplier: 0.65)
        ])
        
        return detailStackView
    }
    
    private func configureDetailView(_ detailView: UIStackView, value: String, color: UIColor = .label) {
        if let valueLabel = detailView.arrangedSubviews.last as? UILabel {
            valueLabel.text = value
            valueLabel.textColor = color
        }
    }
    
    private func configureUI(transaction: Transaction) {
        // Amount
        amountLabel.text = "$\(String(format: "%.2f", transaction.amount))"
        
        transactionTypeLabel.text = transaction.isLend ? String(localized: "transaction_detail_type_lent") : String(localized: "transaction_detail_type_borrowed")
        transactionTypeLabel.textColor = .debtMateBlack
        
        let description = transaction.description ?? String(localized: "transaction_detail_no_description")
        configureDetailView(descriptionView, value: description)
        
        if let dueDate = transaction.dueDate {
            let formattedDate = dueDate.formatted(date: .abbreviated, time: .omitted)
            if transaction.isPaid {
                configureDetailView(dueDateView, value: formattedDate, color: .label)
            } else {
                configureDetailView(dueDateView, value: formattedDate, color: dueDate < Date() ? .systemRed : .label)
            }
        } else {
            configureDetailView(dueDateView, value: String(localized: "transaction_detail_no_due_date"))
        }
        
        configureDetailView(createdAtView, value: transaction.createdAt.formatted(.dateTime.year().month(.wide).day().hour().minute()))
        
        configureStatusView(isPaid: transaction.isPaid)
    }
    
    private func configureStatusView(isPaid: Bool) {
        configureDetailView(statusView, value: isPaid ? String(localized: "transaction_detail_status_paid") : String(localized: "transaction_detail_status_unpaid"), color: isPaid ? .systemGreen : .systemOrange)
        markAsPaidButton.setTitle(isPaid ? String(localized: "transaction_detail_mark_as_unpaid_button") : String(localized: "transaction_detail_mark_as_paid_button"), for: .normal)
        markAsPaidButton.backgroundColor = isPaid ? .systemRed : .systemGreen
    }
    
    // MARK: - Selectors
    @objc func didTapMarkButton(_ sender: UIButton) {
        viewModel.toggleTransactionStatus()
    }
}

extension TransactionDetailViewController: TransactionDetailViewModelDelegate {
    func didToggleTransactionFailed(error: any Error) {
        presentAlert(title: String(localized: "transaction_detail_toggle_failed_title"),
                     message: error.localizedDescription)
    }
    
    func didSetupTransactionData(transaction: Transaction) {
        configureUI(transaction: transaction)
    }
    
    func didToggleTransactionStatus(isPaid: Bool) {
        configureStatusView(isPaid: isPaid)
    }
}
