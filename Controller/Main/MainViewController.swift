//
//  MainViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/5/24.
//

import UIKit

class MainViewController: UIViewController {
    // MARK: - Varibles
    
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
    
    // MARK: - Initializer
    init() {
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
        print("MainViewController: navigateToSetting")
    }
    
    @objc func navigateToHistory() {
       print("MainViewController: navigateToHistory")
    }
    
    @objc func tapAddButton() {
        print("MainViewController: tapAddButton")
    }
}
