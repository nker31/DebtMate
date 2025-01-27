//
//  EditTransactionViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/16/24.
//

import UIKit

protocol EditTransactionViewControllerDelegate: AnyObject {
    func editTransactionViewControllerDidUpdateTransaction(_ transaction: Transaction)
}

class EditTransactionViewController: UIViewController {
    // MARK: - Varibles
    private let viewModel: EditTransactionViewModel
    weak var delegate: EditTransactionViewControllerDelegate?
    
    // MARK: - UI Components
    private var amountTextField = {
        let textfield = DebtMateTextField(placeholder: String(localized: "add_transaction_amount_placeholder"), type: .number)
        textfield.addTarget(self, action: #selector(didTextFieldsChange), for: .editingChanged)
        return textfield
    }()
    
    private lazy var amountFieldStackView = createTextFieldRow(title: String(localized: "add_transaction_amount_label"), field: amountTextField)
    
    private var descriptionTextField = {
        let textfield = DebtMateTextField(placeholder: String(localized: "add_transaction_description_placeholder"))
        textfield.addTarget(self, action: #selector(didTextFieldsChange), for: .editingChanged)
        return textfield
    }()
    
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
        datePicker.isHidden = true
        datePicker.addTarget(self, action: #selector(didTextFieldsChange), for: .valueChanged)
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
            amountFieldStackView,
            descriptionFieldStackView,
            dueDateSwitchStackView
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let updateButton: UIButton = {
        let button = DebtMateButton(
            title: "Update"
        )
        button.isEnabled = false
        button.alpha = 0.5
        button.addTarget(self, action: #selector(didTapUpdate), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initializer
    init(viewModel: EditTransactionViewModel) {
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
        viewModel.setupTransactionDetails()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(mainStackView)
        view.addSubview(updateButton)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mainStackView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor, multiplier: 0.2),
            
            updateButton.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 24),
            updateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            updateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            updateButton.heightAnchor.constraint(equalToConstant: 48),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTransactionData(transaction: Transaction) {
        amountTextField.text = String(transaction.amount)
        descriptionTextField.text = transaction.description
        
        if let dueDate = transaction.dueDate {
            dueDatePicker.minimumDate = dueDate
            dueDateSwitch.isOn = true
            dueDatePicker.isHidden = false
            dueDatePicker.date = dueDate
        }
    }
    
    private func enableUpdateButton(isEnabled: Bool) {
        updateButton.isEnabled = isEnabled
        updateButton.alpha = isEnabled ? 1 : 0.5
    }
    
    // MARK: - Selectors
    @objc func didTapUpdate() {
        viewModel.updateTransactionDetails(amount: amountTextField.text,
                                           description: descriptionTextField.text,
                                           date: dueDatePicker.date)
    }
    
    @objc func didTextFieldsChange() {
        viewModel.validateTransaction(amount: amountTextField.text,
                                      description: descriptionTextField.text,
                                      date: dueDatePicker.date)
    }
    
    @objc func dueDateSwitchToggled(_ sender: UISwitch) {
        viewModel.toggleDuaDate(isEnabled: sender.isOn)
        viewModel.validateTransaction(amount: amountTextField.text,
                                      description: descriptionTextField.text,
                                      date: dueDatePicker.date)
    }
}

extension EditTransactionViewController: EditTransactionViewModelDelegate {
    func didToggleDueDate(isEnabled: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.dueDatePicker.isHidden = !isEnabled
        }
    }
    
    func didValidateTransactionDetails(isValid: Bool) {
        enableUpdateButton(isEnabled: isValid)
    }
    
    func didStateChange(to state: ViewState) {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
        case .loading:
            activityIndicator.startAnimating()
        case .success:
            activityIndicator.stopAnimating()
            presentAlertAndDismiss(title: String(localized: "edit_transaction_success_title"),
                                   message: String(localized: "edit_transaction_success_message"),
                                   isPopView: true)
        case .failure(let error):
            activityIndicator.stopAnimating()
            presentAlert(title: String(localized: "edit_transaction_failed_title"),
                         message: error.localizedDescription)
            
        }
    }
    
    func didSetupTransactionDetails(transaction: Transaction) {
        setupTransactionData(transaction: transaction)
    }
    
    func didUpdateTransactionDetails(transaction: Transaction) {
        delegate?.editTransactionViewControllerDidUpdateTransaction(transaction)
    }
}
