//
//  SignUpViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/5/24.
//

import UIKit

class SignUpViewController: UIViewController {
    // MARK: - Varibles
    private var viewModel: SignUpViewModelProtocol
    private var imagePickerImager: ImagePickerManagerController
    
    // MARK: - UI Components
    let profileImageView: UIImageView =  {
        let imageView = CircularImageView(cornerRadius: 60)
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.tintColor = .debtMateBlack
        return imageView
    }()
    
    let profileImageButton: UIButton = CircularImagePickerButton(cornerRadius: 15)
    
    let fullNameTextField: UITextField = DebtMateTextField(placeholder: String(localized: "signup_full_name_placeholder"), type: .name)
    
    let emailTextField: UITextField = DebtMateTextField(placeholder: String(localized: "signup_email_placeholder"), type: .email)
    
    let passwordTextField: UITextField = DebtMateTextField(placeholder: String(localized: "signup_password_placeholder"), type: .password)
    
    let confirmTextField: UITextField = DebtMateTextField(placeholder: String(localized: "signup_confirm_password_placeholder"), type: .password)
    
    let policyCheckBoxButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.tintColor = .debtMateBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onCheckBoxTapped), for: .touchUpInside)
        return button
    }()
    
    let policyLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "signup_terms_and_condition_label")
        label.font = .systemFont(ofSize: 14)
        label.textColor = .debtMateBlack
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let policyStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var signUpButton: UIButton = {
        let button = DebtMateButton(title: String(localized: "signup_button"), type: .regular)
        button.alpha = 0.5
        button.isEnabled = false
        button.addTarget(self, action: #selector(onTapSignUpButton), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initializer
    init(viewModel: SignUpViewModelProtocol = SignUpViewModel(),
         imagePickerManager: ImagePickerManagerController = ImagePickerManagerController()) {
        self.imagePickerImager = imagePickerManager
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
        setupImagePickerMenu(button: profileImageButton,
                             imagePickerManager: imagePickerImager,
                             delegate: self)
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = .systemBackground

        policyStack.addArrangedSubview(policyCheckBoxButton)
        policyStack.addArrangedSubview(policyLabel)
        
        let textfieldStack: UIStackView = UIStackView(arrangedSubviews: [
            createTextFieldRow(title: String(localized: "signup_full_name_label"), field: fullNameTextField),
            createTextFieldRow(title: String(localized: "signup_email_label"), field: emailTextField),
            createTextFieldRow(title: String(localized: "signup_password_label"), field: passwordTextField),
            createTextFieldRow(title: String(localized: "signup_confirm_password_label"), field: confirmTextField),
            policyStack,
        ])
        textfieldStack.axis = .vertical
        textfieldStack.spacing = 20
        textfieldStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(profileImageView)
        view.addSubview(profileImageButton)
        view.addSubview(textfieldStack)
        view.addSubview(signUpButton)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            profileImageButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            profileImageButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            profileImageButton.widthAnchor.constraint(equalToConstant: 30),
            profileImageButton.heightAnchor.constraint(equalToConstant: 30),
            
            textfieldStack.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            textfieldStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textfieldStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            signUpButton.topAnchor.constraint(equalTo: textfieldStack.bottomAnchor, constant: 20),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpButton.heightAnchor.constraint(equalToConstant: 48),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupNavigationBar() {
        title = String(localized: "signup_screen_title")
        self.navigationController?.navigationBar.tintColor = .debtMateBlack
    }
    
    // MARK: - Selectors
    @objc func onCheckBoxTapped() {
        if viewModel.isAcceptedTerms {
            viewModel.acceptTermsAndConditions(isAccepted: false)
        } else {
            let termsAndConditionConntroller = TermsAndConditionsViewController()
            termsAndConditionConntroller.modalPresentationStyle = .fullScreen
            termsAndConditionConntroller.delegate = self
            
            present(termsAndConditionConntroller, animated: true)
        }
    }
    
    @objc func onTapSignUpButton() {
        guard let fullname = fullNameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmTextField.text else {
            return
        }
        
        self.viewModel.signUp(fullName: fullname,
                                 email: email,
                                 password: password,
                                 confirmPassword: confirmPassword)
    }
}

extension SignUpViewController: SignUpViewModelDelegate {
    func showAlert(title: String, message: String) {
        presentAlert(title: title, message: message)
    }
    
    func didAcceptTermsAndConditions(isAccepted: Bool) {
        let image = isAccepted ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        policyCheckBoxButton.setImage(image, for: .normal)
        signUpButton.isEnabled = isAccepted
        signUpButton.alpha = isAccepted ? 1 : 0.5
    }
    
    func didStartSignUp() {
        activityIndicator.startAnimating()
    }
    
    func didFinishSignUp() {
        activityIndicator.stopAnimating()
        let mainViewController = UINavigationController(rootViewController: MainViewController())
        setRootViewController(mainViewController)
    }
    
    func didFailSignUp() {
        activityIndicator.stopAnimating()
    }
}

extension SignUpViewController: ImagePickerManagerControllerDelegate {
    func imagePicked(_ image: UIImage) {
        profileImageView.image = image
        viewModel.setSelectedImage(image: image)
    }
}

extension SignUpViewController: TermsAndConditionsViewControllerDelegate {
    func didTapAccept() {
        viewModel.acceptTermsAndConditions(isAccepted: true)
    }
    
    func didTapReject() {
        viewModel.acceptTermsAndConditions(isAccepted: false)
    }
}

