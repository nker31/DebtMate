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
        let editViewModel = EditPersonalDetailViewModel(person: viewModel.person)
        let editViewController = EditPersonalDetailViewController(viewModel: editViewModel)
        editViewController.delegate = self
        navigationController?.pushViewController(editViewController, animated: true)
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: String(localized: "person_screen_delete_button")) { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            presentDeleteItemAlert { result in
                guard result else { return }
                
                let initialSections = self.numberOfSections(in: tableView)
                
                let isLendingSection = !self.viewModel.lendingTransactions.isEmpty && indexPath.section == 0
                
                self.viewModel.deleteTransaction(from: indexPath.row,
                                                 isLending: isLendingSection)
                
                tableView.performBatchUpdates {
                    if isLendingSection {
                        if self.viewModel.lendingTransactions.isEmpty {
                            tableView.deleteSections([0], with: .automatic)
                        } else {
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                        }
                    } else {
                        let borrowingSectionIndex = initialSections == 1 ? 0 : 1
                        if self.viewModel.borrowingTransactions.isEmpty {
                            tableView.deleteSections([borrowingSectionIndex], with: .automatic)
                        } else {
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                        }
                    }
                }
            }
        }
        
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let isLendingSection = !self.viewModel.lendingTransactions.isEmpty && indexPath.section == 0
        var isPaid: Bool
        
        if isLendingSection {
            isPaid = viewModel.lendingTransactions[indexPath.row].isPaid
        } else {
            isPaid = viewModel.borrowingTransactions[indexPath.row].isPaid
        }
        
        let title = isPaid
        ? String(localized: "person_screen_unpaid_button")
        : String(localized: "person_screen_paid_button")
        
        let returnAction = UIContextualAction(style: .destructive, title: title) { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            let isLendingSection = !self.viewModel.lendingTransactions.isEmpty && indexPath.section == 0
            
            viewModel.toggleTransactionStatus(from: indexPath.row, isLending: isLendingSection)
            
            tableView.reloadData()
        }
        
        returnAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [returnAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var transaction: Transaction
        
        if viewModel.lendingTransactions.isEmpty {
            transaction = viewModel.borrowingTransactions[indexPath.row]
        } else if viewModel.borrowingTransactions.isEmpty {
            transaction = viewModel.lendingTransactions[indexPath.row]
        } else {
            transaction = indexPath.section == 0 ? viewModel.lendingTransactions[indexPath.row] : viewModel.borrowingTransactions[indexPath.row]
        }
        
        let viewModel = TransactionDetailViewModel(transaction: transaction)
        let transactionDetailsViewController = TransactionDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(transactionDetailsViewController, animated: true)
    }
}
extension PersonalTransactionViewController: PersonalTransactionViewModelDelegate {
    func showAlert(title: String, message: String) {
        presentAlert(title: title, message: message)
    }
    
    func didSetPersonalDetail(person: Person) {
        title = person.fullName
        headerView.configure(imageURL: person.imageURL)
    }
    
    func reloadView(isEmpty: Bool) {
        noTransactionLabel.isHidden = !isEmpty
        tableView.reloadData()
    }
}

extension PersonalTransactionViewController: EditPersonalDetailViewControllerDelegate {
    func editPersonalDetailViewControllerDidUpdatePerson(personName: String?, personImage: UIImage?) {
        title = personName
        headerView.configure(image: personImage)
    }
}
