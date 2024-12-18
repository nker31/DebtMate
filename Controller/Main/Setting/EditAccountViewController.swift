//
//  EditAccountViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/8/24.
//

import UIKit

class EditAccountViewController: UIViewController {
    // MARK: - Varibles
    private let imagePickerController: ImagePickerManagerController
    private var viewModel: EditAccountViewModelProtocol
    
    // MARK: - UI Components
    private let userImageView: UIImageView = CircularImageView(cornerRadius: 60)
    
    private let imagePickerButton: UIButton = CircularImagePickerButton(cornerRadius: 15)
    
    private let fullNameTextField: UITextField = {
        let textField = DebtMateTextField(placeholder: String(localized: "edit_account_full_name_placeholder"), type: .name)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    lazy var fullNameTextFieldRow = createTextFieldRow(title: String(localized: "edit_account_full_name_label"), field: fullNameTextField)
    
    private let updateButton: UIButton = {
        let button = DebtMateButton(title: String(localized: "edit_account_update_button"))
        button.isEnabled = false
        button.alpha = 0.5
        button.addTarget(self, action: #selector(didTapUpdateButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializer
    init(imagePickerController: ImagePickerManagerController = ImagePickerManagerController(), viewModel: EditAccountViewModelProtocol = EditAccountViewModel()) {
        self.imagePickerController = imagePickerController
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
        viewModel.fetchCurrentUser()
        setupImagePickerMenu(button: imagePickerButton,
                             imagePickerManager: imagePickerController,
                             delegate: self)
    }

    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(userImageView)
        view.addSubview(imagePickerButton)
        view.addSubview(fullNameTextFieldRow)
        view.addSubview(updateButton)
        
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            userImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 120),
            userImageView.heightAnchor.constraint(equalToConstant: 120),
            
            imagePickerButton.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: -30),
            imagePickerButton.bottomAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 0),
            imagePickerButton.widthAnchor.constraint(equalToConstant: 30),
            imagePickerButton.heightAnchor.constraint(equalToConstant: 30),
            
            fullNameTextFieldRow.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 24),
            fullNameTextFieldRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fullNameTextFieldRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            updateButton.topAnchor.constraint(equalTo: fullNameTextFieldRow.bottomAnchor, constant: 24),
            updateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            updateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            updateButton.heightAnchor.constraint(equalToConstant: 48),
        ])
    }
    
    // MARK: - Selectors
    @objc func textFieldDidChange() {
        viewModel.validateAccountDetail(newName: fullNameTextField.text,
                                        newImage: userImageView.image)
    }
    
    @objc func didTapUpdateButton() {
        guard let newName = fullNameTextField.text else { return }
        viewModel.updateUserDetail(newName: newName, newImage: userImageView.image)
    }
}

extension EditAccountViewController: ImagePickerManagerControllerDelegate {
    func imagePicked(_ image: UIImage) {
        userImageView.image = image
        viewModel.validateAccountDetail(newName: fullNameTextField.text, newImage: image)
    }
}

extension EditAccountViewController: EditAccountViewModelDelegate {
    func didValidateAccountDetail(isValid: Bool) {
        updateButton.isEnabled = isValid
        updateButton.alpha = isValid ? 1 : 0.5
    }
    
    func didFetchCurrentUser(user: User) {
        fullNameTextField.text = user.fullName
        
        if let imageURL = user.imageURL {
            userImageView.setImage(imageURL: imageURL)
        } else {
            userImageView.image = UIImage(named: "mock-profile")
        }
        
        viewModel.originalImage = userImageView.image
    }
    
    func didUpdateSuccessfully() {
        presentAlertAndDismiss(title: String(localized: "edit_account_success_title"),
                               message: String(localized: "edit_account_success_message"),
                               isPopView: true)
    }
    
    func showAlert(title: String, message: String) {
        presentAlert(title: title, message: message)
    }
}
