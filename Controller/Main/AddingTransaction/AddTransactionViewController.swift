//
//  AddTransactionViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/7/24.
//

import UIKit

class AddTransactionViewController: UIViewController {
    // MARK: - Varibles
    private var viewModel: AddTransactionViewModelProtocol
    
    // MARK: - UI Components
    private var lenderBorrowerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .textfield
        view.layer.cornerRadius = 15
        return view
    }()
    
    private var lenderBorrowerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .debtMateBlack
        label.text = String(localized: "add_transaction_lender_label")
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private var addLenderBorrowerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(String(localized: "add_transaction_select_button"), for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 8
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        return button
    }()
    
    private var lendBorrowSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [
            String(localized: "add_transaction_lend_segment"),
            String(localized: "add_transaction_borrow_segment")
        ])
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .systemGray6
        segmentedControl.layer.cornerRadius = 8
        segmentedControl.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16)
        ]
        segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16)
        ]
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
        
         segmentedControl.addTarget(self, action: #selector(lendBorrowSegmentedControlValueChanged(_:)), for: .valueChanged)
        
        return segmentedControl
    }()
    
    private var amountTextField = DebtMateTextField(placeholder: String(localized: "add_transaction_amount_placeholder"), type: .number)
    
    private lazy var amountFieldStackView = createTextFieldRow(title: String(localized: "add_transaction_amount_label"), field: amountTextField)
    
    private var descriptionTextField = DebtMateTextField(placeholder: String(localized: "add_transaction_description_placeholder"))
    
    private lazy var descriptionFieldStackView = createTextFieldRow(title: String(localized: "add_transaction_description_label"), field: descriptionTextField)
    
    private lazy var dueDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = String(localized: "add_transaction_due_date_label")
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var dueDateSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.isOn = false
        toggleSwitch.onTintColor = UIColor(white: 0.2, alpha: 1.0)
        toggleSwitch.addTarget(self, action: #selector(dueDateSwitchToggled(_:)), for: .valueChanged)
        return toggleSwitch
    }()

    private var dueDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        datePicker.isHidden = true
        return datePicker
    }()

    private lazy var dueDateSwitchStackView: UIStackView = {
        let switchStack = UIStackView(arrangedSubviews: [dueDateLabel, dueDateSwitch])
        switchStack.axis = .horizontal
        switchStack.spacing = 10
        
        let stack = UIStackView(arrangedSubviews: [switchStack, dueDatePicker])
        stack.axis = .vertical
        stack.spacing = 10
        
        return stack
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            lendBorrowSegmentedControl,
            amountFieldStackView,
            descriptionFieldStackView,
            dueDateSwitchStackView
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let activityIndicator = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initializer
    init(viewModel: AddTransactionViewModelProtocol = AddTransactionViewModel()) {
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
        setupMenu()
        viewModel.delegate = self
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        lenderBorrowerView.addSubview(lenderBorrowerLabel)
        lenderBorrowerView.addSubview(addLenderBorrowerButton)
        
        view.addSubview(lenderBorrowerView)
        view.addSubview(mainStackView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            lenderBorrowerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            lenderBorrowerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lenderBorrowerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lenderBorrowerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07),
            
            lenderBorrowerLabel.centerYAnchor.constraint(equalTo: lenderBorrowerView.centerYAnchor),
            lenderBorrowerLabel.leadingAnchor.constraint(equalTo: lenderBorrowerView.leadingAnchor, constant: 20),
            
            addLenderBorrowerButton.centerYAnchor.constraint(equalTo: lenderBorrowerView.centerYAnchor),
            addLenderBorrowerButton.trailingAnchor.constraint(equalTo: lenderBorrowerView.trailingAnchor, constant: -20),
            addLenderBorrowerButton.widthAnchor.constraint(equalToConstant: 90),
            addLenderBorrowerButton.heightAnchor.constraint(equalToConstant: 35),
            
            mainStackView.topAnchor.constraint(equalTo: lenderBorrowerView.bottomAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupNavigationBar() {
        self.navigationController?.navigationBar.tintColor = .debtMateBlack
        let addButton = UIBarButtonItem(title: String(localized: "add_transaction_add_button"),
                                        style: .done,
                                        target: self,
                                        action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    func setupMenu() {
        let addManuallyAction = UIAction(title: String(localized: "add_transaction_add_manually_button"), image: UIImage(systemName: "plus")) { [weak self] _ in
            self?.navigateToAddPersonManually()
        }
        
        let chooseFromContactAction = UIAction(title: String(localized: "add_transaction_select_contact_button"), image: UIImage(systemName: "person.crop.circle.badge.plus")) { [weak self] _ in
            self?.navigateToContactSelection()
        }
        
        let chooseFromExistingAction = UIAction(title: String(localized: "add_transaction_select_existing_button"), image: UIImage(systemName: "note.text")) { [weak self] _ in
            self?.navigateToPersonSelection()
        }
        
        let menu = UIMenu(title: String(localized: "add_transaction_menu_title"), children: [addManuallyAction, chooseFromContactAction, chooseFromExistingAction])
        
        addLenderBorrowerButton.menu = menu
        addLenderBorrowerButton.showsMenuAsPrimaryAction = true
    }
    
    func navigateToAddPersonManually() {
        let addPersonManuallyVC = AddManualPersonViewController()
        addPersonManuallyVC.delegate = self
        navigationController?.pushViewController(addPersonManuallyVC, animated: true)
    }
    
    func navigateToContactSelection() {
        let contactVC = ContactSelectionViewController()
        contactVC.delegate = self
        contactVC.modalPresentationStyle = .fullScreen
        present(contactVC, animated: true, completion: nil)
    }
    
    func navigateToPersonSelection() {
        let personViewController = ExistingPersonSelectionViewController()
        personViewController.delegate = self
        personViewController.modalPresentationStyle = .fullScreen
        present(personViewController, animated: true, completion: nil)
    }
    
    func setLenderBorrowerLabelText() {
        if !viewModel.hasSelection {
            if lendBorrowSegmentedControl.selectedSegmentIndex == 0 {
                lenderBorrowerLabel.text = String(localized: "add_transaction_lender_label")
            } else {
                lenderBorrowerLabel.text = String(localized: "add_transaction_borrower_label")
            }
        }
    }
    
    func setAddLenderBorrowerButton() {
        let button = addLenderBorrowerButton
        
        if viewModel.hasSelection {
            button.setTitle(String(localized: "add_transaction_remove_button"), for: .normal)
            button.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
            button.menu = nil
            button.showsMenuAsPrimaryAction = false
        } else {
            button.setTitle(String(localized: "add_transaction_select_button"), for: .normal)
            setupMenu()
        }
    }
    
    // MARK: - Selectors
    @objc func addButtonTapped() {
        viewModel.handleAddTransaction(amount: amountTextField.text,
                                       description: descriptionTextField.text,
                                       dueDate: dueDatePicker.date)
    }
    
    @objc func lendBorrowSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        let isLending = sender.selectedSegmentIndex == 0
        viewModel.setTransactionType(isLending: isLending)
    }
    
    @objc func removeButtonTapped() {
        viewModel.clearSelection()
    }
    
    @objc func dueDateSwitchToggled(_ sender: UISwitch) {
        viewModel.enableDueDate(isEnabled: sender.isOn)
    }
}

extension AddTransactionViewController: AddManualPersonViewControllerDelegate {
    func addManualPersonViewControllerDidAddPerson(person: Contact) {
        viewModel.setSelectedContact(contact: person)
    }
}

extension AddTransactionViewController: ContactSelectionViewControllerDelegate {
    func contactSelectionViewControllerDidSelectContact(_ contact: Contact) {
        viewModel.setSelectedContact(contact: contact)
    }
}

extension AddTransactionViewController: ExistingPersonSelectionViewControllerDelegate {
    func existingPersonSelectionViewControllerDidSelectPerson(person: Person) {
        viewModel.setSelectedPerson(person: person)
    }
}

extension AddTransactionViewController: AddTransactionViewModelDelegate {
    func didSetSelectedPerson(name: String) {
        lenderBorrowerLabel.text = name
        setAddLenderBorrowerButton()
    }
    
    func didClearSelection() {
        setLenderBorrowerLabelText()
        setAddLenderBorrowerButton()
    }
    
    func didSetTransactionType() {
        setLenderBorrowerLabelText()
    }
    
    func didEnableDueDate(isEnabled: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.dueDatePicker.isHidden = !isEnabled
        }
    }
    
    func didStateChange(to state: ViewState) {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
        case .loading:
            activityIndicator.startAnimating()
        case .success:
            navigationController?.popViewController(animated: true)
        case .failure(let error):
            activityIndicator.stopAnimating()
            showAlert(title: String(localized: "add_transaction_failed_title"),
                      message: error.localizedDescription)
        }
    }
    
    func showAlert(title: String, message: String) {
        presentAlert(title: title, message: message)
    }
}
