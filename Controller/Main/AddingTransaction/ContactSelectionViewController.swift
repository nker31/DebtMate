//
//  ContactSelectionViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/10/24.
//

import UIKit

protocol ContactSelectionViewControllerDelegate: AnyObject {
    func contactSelectionViewControllerDidSelectContact(_ contact: Contact)
}

class ContactSelectionViewController: UIViewController {
    // MARK: - Varibles
    private var viewModel: ContactSelectionViewModelProtocol
    weak var delegate: ContactSelectionViewControllerDelegate?
    
    // MARK: - UI Components
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = String(localized: "contact_selection_search_placeholder")
        searchBar.delegate = self
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ContactTableViewCell.self,
                           forCellReuseIdentifier: ContactTableViewCell.identifier)
        return tableView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(String(localized: "contact_selection_cancel_button"), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let accessDeniedLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "contact_selection_access_denied_message")
        label.textAlignment = .center
        label.textColor = .systemGray
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(String(localized: "contact_selection_go_to_settings_button"), for: .normal)
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private let notFoundLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "contact_selection_not_found_message")
        label.textAlignment = .center
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private lazy var searchStackView: UIStackView = {
        let searchStackView = UIStackView(arrangedSubviews: [searchBar, cancelButton])
        searchStackView.axis = .horizontal
        searchStackView.spacing = 8
        searchStackView.alignment = .center
        searchStackView.translatesAutoresizingMaskIntoConstraints = false
        return searchStackView
    }()
    
    // MARK: - Initializer
    init(viewModel: ContactSelectionViewModelProtocol = ContactSelectionViewModel()) {
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
        viewModel.askForContactAccess()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetchContacts()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(searchStackView)
        view.addSubview(tableView)
        view.addSubview(accessDeniedLabel)
        view.addSubview(settingsButton)
        view.addSubview(notFoundLabel)
        
        NSLayoutConstraint.activate([
            searchStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            searchBar.widthAnchor.constraint(equalTo: searchStackView.widthAnchor, multiplier: 0.8),
            cancelButton.widthAnchor.constraint(equalToConstant: 60),
            
            tableView.topAnchor.constraint(equalTo: searchStackView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            accessDeniedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            accessDeniedLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            
            notFoundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notFoundLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Selectors
    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func settingsButtonTapped() {
        navigateToSystemSettings()
    }
}

extension ContactSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier, for: indexPath) as! ContactTableViewCell
        cell.configCell(contact: viewModel.filteredContacts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = viewModel.filteredContacts[indexPath.row]
        delegate?.contactSelectionViewControllerDidSelectContact(contact)
        dismiss(animated: true, completion: nil)
    }
}

extension ContactSelectionViewController: ContactSelectionViewModelDelegate {
    func reloadContacts() {
        tableView.reloadData()
    }
    
    func toggleEmtpyState(isEmpty: Bool) {
        notFoundLabel.isHidden = !isEmpty
    }
    
    func toggleAccessDeniedState(isDenied: Bool) {
        accessDeniedLabel.isHidden = !isDenied
        settingsButton.isHidden = !isDenied
    }
}

extension ContactSelectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.handleSearchTextChanged(text: searchText)
    }
}
