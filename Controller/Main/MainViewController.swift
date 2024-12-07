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
        viewModel.delegate = self
        viewModel.fetchUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
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
    
    // MARK: - Selectors
    @objc func navigateToSetting() {
        let settingViewController = SettingViewController()
        navigationController?.pushViewController(settingViewController, animated: true)
    }
    
    @objc func navigateToHistory() {
       print("MainViewController: navigateToHistory")
    }
    
    @objc func tapAddButton() {
        let addTransactionViewController = AddTransactionViewController()
        navigationController?.pushViewController(addTransactionViewController, animated: true)
    }
}

extension MainViewController: MainViewModelDelegate {
    func showAlert(title: String, message: String) {
        presentAlert(title: title, message: message)
    }
    
    func didStartFetchingUserData() {
        activityIndicator.startAnimating()
    }
    
    func didFinishFetchingUserData() {
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    func didFaiedFetchingUserData() {
        activityIndicator.stopAnimating()
    }
}
