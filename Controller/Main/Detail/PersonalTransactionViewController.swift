//
//  PersonalTransactionViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/13/24.
//

import UIKit

class PersonalTransactionViewController: UIViewController {
    // MARK: - Varibles
    private var viewModel: PersonalTransactionViewModelProtocol
    
    // MARK: - UI Components
    private let headerView = PersonHeaderView()
    
    private let personNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private let noTransactionLabel: UILabel = EmptyStateLabel(text: String(localized: "person_screen_no_transaction_label"))
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TransactionTableViewCell.self,
                           forCellReuseIdentifier: TransactionTableViewCell.identifier)
        return tableView
    }()
    
    // MARK: - Initializer
    init(viewModel: PersonalTransactionViewModelProtocol) {
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
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.delegate = self
        viewModel.setPersonalDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetchPersonalTransactions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(noTransactionLabel)
        
        tableView.tableHeaderView = headerView
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            noTransactionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noTransactionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupNavigationBar() {
        title = "Detail"
        let editButton = UIBarButtonItem(
            title: String(localized: "person_screen_edit_button"),
            style: .plain,
            target: self,
            action: #selector(didTapEditButton)
        )
        navigationItem.rightBarButtonItem = editButton
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Selectors
    @objc func didTapEditButton() {
        print("PersonalTransactionViewController didTapEditButton")
    }
}

extension PersonalTransactionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 0
        if !viewModel.lendingTransactions.isEmpty {
            sections += 1
        }
        if !viewModel.borrowingTransactions.isEmpty {
            sections += 1
        }
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.lendingTransactions.isEmpty {
            return viewModel.borrowingTransactions.count
        } else if viewModel.borrowingTransactions.isEmpty {
            return viewModel.lendingTransactions.count
        } else {
            return section == 0 ? viewModel.lendingTransactions.count : viewModel.borrowingTransactions.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if viewModel.lendingTransactions.isEmpty {
            return String(localized: "person_screen_borrowing_transactions_section")
        } else if viewModel.borrowingTransactions.isEmpty {
            return String(localized: "person_screen_lending_transactions_section")
        } else {
            return section == 0
            ? String(localized: "person_screen_lending_transactions_section")
            : String(localized: "person_screen_borrowing_transactions_section")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier, for: indexPath) as! TransactionTableViewCell
        
        var transaction: Transaction
        
        if viewModel.lendingTransactions.isEmpty {
            transaction = viewModel.borrowingTransactions[indexPath.row]
        } else if viewModel.borrowingTransactions.isEmpty {
            transaction = viewModel.lendingTransactions[indexPath.row]
        } else {
            transaction = indexPath.section == 0 ? viewModel.lendingTransactions[indexPath.row] : viewModel.borrowingTransactions[indexPath.row]
        }
        
        cell.configCell(transaction: transaction)
        return cell
    }
}
extension PersonalTransactionViewController: PersonalTransactionViewModelDelegate {
    func didSetPersonalDetail(person: Person) {
        title = person.fullName
        headerView.configure(imageURL: person.imageURL)
    }
    
    func reloadView(isEmpty: Bool) {
        noTransactionLabel.isHidden = !isEmpty
        tableView.reloadData()
    }
}
