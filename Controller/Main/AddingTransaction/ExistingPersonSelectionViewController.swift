//
//  ExistingPersonSelectionViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/12/24.
//

import UIKit

protocol ExistingPersonSelectionViewControllerDelegate: AnyObject {
    func existingPersonSelectionViewControllerDidSelectPerson(person: Person)
}

class ExistingPersonSelectionViewController: UIViewController {
    // MARK: - Varibles
    private var viewModel: ExistingPersonSelectionViewModelProtocol
    weak var delegate: ExistingPersonSelectionViewControllerDelegate?
    
    // MARK: - UI Components
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = String(localized: "existing_person_selection_search_placeholder")
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
        button.setTitle(String(localized: "existing_person_selection_cancel_button"), for: .normal)
        button.addTarget(self,
                         action: #selector(cancelButtonTapped),
                         for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let notFoundLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "existing_person_selection_not_found_message")
        label.textAlignment = .center
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    // MARK: - Initializer
    init(viewModel: ExistingPersonSelectionViewModelProtocol = ExistingPersonSelectionViewModel()) {
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
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        viewModel.delegate = self
        viewModel.fetchExistingPersons()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        let searchStackView = UIStackView(arrangedSubviews: [searchBar, cancelButton])
        searchStackView.axis = .horizontal
        searchStackView.spacing = 8
        searchStackView.alignment = .center
        searchStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchStackView)
        view.addSubview(tableView)
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
            
            notFoundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notFoundLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Selectors
    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension ExistingPersonSelectionViewController: UITableViewDataSource, UITableViewDelegate  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredPersonData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier, for: indexPath) as! ContactTableViewCell
        cell.configCell(person: viewModel.filteredPersonData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPerson = viewModel.filteredPersonData[indexPath.row]
        delegate?.existingPersonSelectionViewControllerDidSelectPerson(person: selectedPerson)
        dismiss(animated: true, completion: nil)
    }
}
extension ExistingPersonSelectionViewController: ExistingPersonSelectionViewModelDelegate {
    func didReloadPersonData(isEmpty: Bool) {
        tableView.reloadData()
        notFoundLabel.isHidden = !isEmpty
    }
}

extension ExistingPersonSelectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.onSearchTextChanged(searchText)
    }
}
