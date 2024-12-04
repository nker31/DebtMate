//
//  LoginViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/4/24.
//

import UIKit

class LoginViewController: UIViewController {
    // MARK: - Varibles
    
    // MARK: - UI Components
    var appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "DebtMate"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .debtMateBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailTextField: UITextField = DebtMateTextField(placeholder: String(localized: "login_email_placeholder"), type: .email)
        
    let passwordTextField: UITextField = DebtMateTextField(placeholder: String(localized: "login_password_placeholder"), type: .password)
    
    var loginButton: UIButton = {
        let button = DebtMateButton(title: String(localized: "login_button"))
        button.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
        
    var noAccountButton: UIButton = {
        let button = DebtMateButton(title: String(localized: "login_no_account_button"), type: .subButton)
        button.addTarget(self, action: #selector(signUpButtonTapped(_:)), for: .touchUpInside)
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
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        let textfieldStack: UIStackView = UIStackView(arrangedSubviews: [
            createTextFieldRow(title: String(localized: "login_email_label"), field: emailTextField),
            createTextFieldRow(title: String(localized: "login_password_label"), field: passwordTextField),
            loginButton,
            loginButton,
            noAccountButton
        ])
        
        textfieldStack.axis = .vertical
        textfieldStack.spacing = 24
        textfieldStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(appNameLabel)
        view.addSubview(textfieldStack)
        
        NSLayoutConstraint.activate([
            appNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            appNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textfieldStack.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 60),
            textfieldStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textfieldStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            noAccountButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    // MARK: - Selectors
    @objc private func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            return
        }
        
    }
    
    @objc private func signUpButtonTapped(_ sender: UIButton) {
        
    }
}
