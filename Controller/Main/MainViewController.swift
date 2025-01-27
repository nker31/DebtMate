//
//  MainViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/5/24.
//

import UIKit

class MainViewController: UIViewController {
    // MARK: - Varibles
    var viewModel: MainViewModelProtocol
    
    // MARK: - UI Components
    let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = .debtMateBlack
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let leftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .trailing
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let lentLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "main_total_lent")
        label.font = .systemFont(ofSize: 20, weight: .light)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let borrowLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "main_total_borrowed")
        label.font = .systemFont(ofSize: 20, weight: .light)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let lentTotalLabel: UILabel = {
        let label = UILabel()
        label.text = "$0"
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let borrowTotalLabel: UILabel = {
        let label = UILabel()
        label.text = "$0"
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.register(PersonTableViewCell.self, forCellReuseIdentifier: PersonTableViewCell.identifier)
        tableView.rowHeight = 90
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.addTarget(self, action: #selector(tapAddButton), for: .touchUpInside)
        button.backgroundColor = .debtMateBlack
        button.tintColor = .debtMateWhite
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initializer
    init(viewModel: MainViewModelProtocol = MainViewModel()) {
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
        viewModel.fetchUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        
        setupData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(activityIndicator)
        
        headerView.addSubview(dividerLine)
        headerView.addSubview(leftStackView)
        headerView.addSubview(rightStackView)
        
        leftStackView.addArrangedSubview(lentLabel)
        leftStackView.addArrangedSubview(lentTotalLabel)
        
        rightStackView.addArrangedSubview(borrowLabel)
        rightStackView.addArrangedSubview(borrowTotalLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: view.frame.height / 8),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            dividerLine.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            dividerLine.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            dividerLine.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.6),
            dividerLine.widthAnchor.constraint(equalToConstant: 2),
            
            leftStackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            leftStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            leftStackView.trailingAnchor.constraint(equalTo: dividerLine.leadingAnchor, constant: -20),
            leftStackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            
            rightStackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            rightStackView.leadingAnchor.constraint(equalTo: dividerLine.trailingAnchor, constant: 20),
            rightStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            rightStackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupNavigationBar() {
        title = "DebtMate"
        navigationController?.navigationBar.tintColor = .debtMateBlack
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(navigateToSetting))
        let addButton = UIBarButtonItem(image: UIImage(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(navigateToHistory))
        navigationItem.leftBarButtonItem = settingButton
        navigationItem.rightBarButtonItem = addButton
    }
    
    func setupData() {
        let balance = viewModel.calculateTotalBalance()
        lentTotalLabel.text = "\(balance.0)"
        borrowTotalLabel.text = "\(balance.1)"
        tableView.reloadData()
    }
    
    // MARK: - Selectors
    @objc func navigateToSetting() {
        let settingViewController = SettingViewController()
        navigationController?.pushViewController(settingViewController, animated: true)
    }
    
    @objc func navigateToHistory() {
        let historyViewcontroller = TransactionHistoryViewController()
        navigationController?.pushViewController(historyViewcontroller, animated: true)
    }
    
    @objc func tapAddButton() {
        let addTransactionViewController = AddTransactionViewController()
        navigationController?.pushViewController(addTransactionViewController, animated: true)
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.personData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PersonTableViewCell.identifier, for: indexPath) as! PersonTableViewCell
        let person = viewModel.personData[indexPath.row]
        let personalBalance = viewModel.calculatePersonalBalance(for: person.personID)
        cell.configCell(person: person, balance: personalBalance)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = PersonalTransactionViewModel(person: viewModel.personData[indexPath.row])
        let viewController = PersonalTransactionViewController(viewModel: viewModel)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: String(localized: "main_delete_person_button")) { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            presentDeleteItemAlert { isDelete in
                if isDelete {
                    self.viewModel.deletePerson(from: indexPath.row)
                }
            }
            
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension MainViewController: MainViewModelDelegate {
    func didStateChange(to viewState: ViewState) {
        switch viewState {
        case .idle:
            activityIndicator.stopAnimating()
        case .loading:
            activityIndicator.startAnimating()
        case .success:
            activityIndicator.stopAnimating()
            setupData()
        case .failure(let error):
            activityIndicator.stopAnimating()
            presentAlert(title: String(localized: "main_error_title"),
                         message: error.localizedDescription)
        }
    }
}
