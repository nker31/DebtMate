//
//  AccountDetailViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/8/24.
//

import UIKit

class AccountDetailViewController: UIViewController {
    // MARK: - Varibles
    private var viewModel: AccountDetailViewModelProtocol
    
    // MARK: - UI Components
    private let headerView = AccountHeaderView()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Initializer
    init(viewModel: AccountDetailViewModelProtocol = AccountDetailViewModel()) {
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
        viewModel.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetchCurrentUser()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    private func setupNavigationBar() {
        title = String(localized: "account_screen_title")
    }
}
   
extension AccountDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.accountMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = viewModel.accountMenu[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let editAccountViewController = EditAccountViewController()
            navigationController?.pushViewController(editAccountViewController, animated: true)
        case 1:
            let changePasswordViewController = ChangePasswordViewController()
            navigationController?.pushViewController(changePasswordViewController, animated: true)
        default:
            break
        }
    }
}

extension AccountDetailViewController: AccountDetailViewModelDelegate {
    func didFetchCurrentUserFailed(error: any Error) {
        presentAlert(title: "Error", message: error.localizedDescription)
    }
    
    func didFetchCurrentUser(_ currentUser: User) {
        headerView.configure(with: currentUser)
    }
}
 
