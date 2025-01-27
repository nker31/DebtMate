//
//  TransactionHistoryViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/15/24.
//

import UIKit

class TransactionHistoryViewController: UIViewController {
    // MARK: - Varibles
    private var viewModel: TransactionHistoryViewModel
    
    // MARK: - UI Components
    var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TransactionHistoryCell.self, forCellReuseIdentifier: TransactionHistoryCell.identifier)
        return tableView
    }()
    
    var emptyLabel : UILabel = EmptyStateLabel(text: String(localized: "transaction_history_empty_label"))

    // MARK: - Initializer
    init(viewModel: TransactionHistoryViewModel = TransactionHistoryViewModel()) {
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
        setupNavigationBar()
        tableView.dataSource = self
        tableView.delegate = self
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetchTransactions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = String(localized: "transaction_history_screen_title")
    }
}

extension TransactionHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.groupedTransactions.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionDate = viewModel.groupedTransactions[section].date
        return sectionDate.formatted(.dateTime.year().month(.wide).day())
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.groupedTransactions[section].transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionHistoryCell.identifier, for: indexPath) as! TransactionHistoryCell
        
        let transaction = viewModel.groupedTransactions[indexPath.section].transactions[indexPath.row]
        cell.configure(with: transaction, personName: viewModel.findPersonName(from: transaction.personID))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = viewModel.groupedTransactions[indexPath.section].transactions[indexPath.row]
        let viewModel = TransactionDetailViewModel(transaction: transaction)
        let transactionDetailsViewController = TransactionDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(transactionDetailsViewController, animated: true)
    }
}

extension TransactionHistoryViewController: TransactionHistoryViewModelDelegate {
    func reloadTransactionHistory() {
        tableView.reloadData()
    }
}
