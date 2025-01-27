//
//  ChangePasswordViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/9/24.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    // MARK: - Varibles
    private var viewModel: ChangePasswordViewModelProtocol
    
    // MARK: - UI Components
    private let currentPasswordTextField: UITextField = {
        let textField = DebtMateTextField(
            placeholder: String(localized: "change_password_current_password_placeholder"),
            type: .password
        )
        textField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        
        return textField
    }()
    
    private let newPasswordTextField: UITextField = {
        let textField = DebtMateTextField(
            placeholder: String(localized: "change_password_new_password_placeholder"),
            type: .password
        )
        textField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        
        return textField
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = DebtMateTextField(
            placeholder: String(localized: "change_password_confirm_password_placeholder"),
            type: .password
        )
        textField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        
        return textField
    }()
    
    private lazy var currentPasswordRow = createTextFieldRow(
        title: String(localized: "change_password_current_password_label"),
        field: currentPasswordTextField
    )
    
    private lazy var newPasswordRow = createTextFieldRow(
        title: String(localized: "change_password_new_password_label"),
        field: newPasswordTextField
    )
    
    private lazy var confirmPasswordRow = createTextFieldRow(
        title: String(localized: "change_password_confirm_password_label"),
        field: confirmPasswordTextField
    )
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let updatePasswordButton: UIButton = {
        let button = DebtMateButton(
            title: String(localized: "change_password_update_button")
        )
        button.isEnabled = false
        button.alpha = 0.5
        button.addTarget(self, action: #selector(didTapChangePassword), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initializer
    init(viewModel: ChangePasswordViewModelProtocol = ChangePasswordViewModel()) {
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
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        view.addSubview(updatePasswordButton)
        view.addSubview(activityIndicator)
        
        stackView.addArrangedSubview(currentPasswordRow)
        stackView.addArrangedSubview(newPasswordRow)
        stackView.addArrangedSubview(confirmPasswordRow)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor, multiplier: 0.3),
            
            updatePasswordButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24),
            updatePasswordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            updatePasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            updatePasswordButton.heightAnchor.constraint(equalToConstant: 48),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = String(localized: "change_password_screen_title")
    }
    
    private func clearTextFields() {
        currentPasswordTextField.text = ""
        newPasswordTextField.text = ""
        confirmPasswordTextField.text = ""
    }
    
    private func enableChangePasswordButton(isEnabled: Bool) {
        updatePasswordButton.isEnabled = isEnabled
        updatePasswordButton.alpha = isEnabled ? 1 : 0.5
    }
    
    // MARK: - Selectors
    @objc func textFieldsDidChange() {
        viewModel.validatePassword(oldPassword: currentPasswordTextField.text,
                                   newPassword: newPasswordTextField.text,
                                   confirmPassword: confirmPasswordTextField.text)
    }
    
    @objc func didTapChangePassword() {
        viewModel.changePassword(oldPassword: currentPasswordTextField.text,
                                 newPassword: newPasswordTextField.text)
    }
}

extension ChangePasswordViewController: ChangePasswordViewModelDelegate {
    func didStateChange(to state: ViewState) {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
        case .loading:
            activityIndicator.startAnimating()
            enableChangePasswordButton(isEnabled: false)
        case .success:
            activityIndicator.stopAnimating()
            presentAlert(title: String(localized: "change_password_alert_success_title"),
                         message: String(localized: "change_password_alert_success_message"))
        case .failure(let error):
            presentAlert(title: String(localized: "change_password_alert_failed_title"),
                         message: error.localizedDescription)
        }
    }
    
    func didValidatePassword(isValid: Bool) {
        enableChangePasswordButton(isEnabled: isValid)
    }
}
