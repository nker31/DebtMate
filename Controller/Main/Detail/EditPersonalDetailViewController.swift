//
//  EditPersonalDetailViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/13/24.
//

import UIKit
protocol EditPersonalDetailViewControllerDelegate: AnyObject {
    func editPersonalDetailViewControllerDidUpdatePerson(personName: String?, personImage: UIImage?)
}
class EditPersonalDetailViewController: UIViewController {
    // MARK: - Variables
    private var viewModel: EditPersonalDetailViewModelProtocol
    private var imagePickerImager: ImagePickerManagerController
    weak var delegate: EditPersonalDetailViewControllerDelegate?
    
    // MARK: - UI Elements
    private var personImageView: UIImageView = CircularImageView(cornerRadius: 60)
    
    private let changeImageButton = CircularImagePickerButton(cornerRadius: 15)
    
    private let nameTextField: UITextField = {
        let textfield = DebtMateTextField(placeholder: String(localized: "edit_person_name_placeholder"))
        textfield.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        return textfield
    }()
    
    private let phoneNumberTextField: UITextField = {
        let textfield = DebtMateTextField(placeholder: String(localized: "edit_person_phone_number_placeholder"), type: .phoneNumber)
        textfield.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        return textfield
    }()
    
    private let saveButton: UIButton = {
        let button = DebtMateButton(title: String(localized: "edit_person_save_button"))
        button.isEnabled = false
        button.alpha = 0.5
        button.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameTextFieldRow = createTextFieldRow(title: String(localized: "edit_person_name_label"), field: nameTextField)
    
    private lazy var phoneNumberTextFieldRow = createTextFieldRow(title: String(localized: "edit_person_phone_number_label"), field: phoneNumberTextField)
    
    private let activityIndicator = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initializer
    init(viewModel: EditPersonalDetailViewModelProtocol, imagePickerManager: ImagePickerManagerController = ImagePickerManagerController()) {
        self.viewModel = viewModel
        self.imagePickerImager = imagePickerManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.delegate = self
        setupImagePickerMenu(button: changeImageButton,
                             imagePickerManager: imagePickerImager,
                             delegate: self)
        viewModel.setupPersonDetail()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(personImageView)
        view.addSubview(changeImageButton)
        view.addSubview(nameTextFieldRow)
        view.addSubview(phoneNumberTextFieldRow)
        view.addSubview(saveButton)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            personImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            personImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            personImageView.widthAnchor.constraint(equalToConstant: 120),
            personImageView.heightAnchor.constraint(equalToConstant: 120),
            
            changeImageButton.leadingAnchor.constraint(equalTo: personImageView.trailingAnchor, constant: -30),
            changeImageButton.bottomAnchor.constraint(equalTo: personImageView.bottomAnchor, constant: 0),
            changeImageButton.widthAnchor.constraint(equalToConstant: 30),
            changeImageButton.heightAnchor.constraint(equalToConstant: 30),
            
            nameTextFieldRow.topAnchor.constraint(equalTo: personImageView.bottomAnchor, constant: 24),
            nameTextFieldRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextFieldRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            phoneNumberTextFieldRow.topAnchor.constraint(equalTo: nameTextFieldRow.bottomAnchor, constant: 16),
            phoneNumberTextFieldRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            phoneNumberTextFieldRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: phoneNumberTextFieldRow.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 48),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func enableAddPersonButton(isEnabled: Bool) {
        saveButton.isEnabled = isEnabled
        saveButton.alpha = isEnabled ? 1 : 0.5
    }
    
    // MARK: - Selectors
    @objc private func didTapSaveButton() {
        viewModel.updatePersonalDetail(newName: nameTextField.text,
                                       newPhone: phoneNumberTextField.text)
    }
    
    @objc func textFieldsDidChange() {
        viewModel.validatePersonalDetail(newName: nameTextField.text,
                                         newPhone: phoneNumberTextField.text,
                                         originalImage: personImageView.image)
    }
}

extension EditPersonalDetailViewController: ImagePickerManagerControllerDelegate {
    func imagePicked(_ image: UIImage) {
        viewModel.setSelectedImage(image: image)
        viewModel.validatePersonalDetail(newName: nameTextField.text,
                                         newPhone: phoneNumberTextField.text,
                                         originalImage: personImageView.image)
        personImageView.image = image
        
    }
}

extension EditPersonalDetailViewController: EditPersonalDetailViewModelDelegate {
    func didValidatePersonalDetail(isValid: Bool) {
        enableAddPersonButton(isEnabled: isValid)
    }
    
    func didSetupPersonalDetail(person: Person) {
        personImageView.setImage(imageURL: person.imageURL, placeholder: UIImage(named: "mock-profile"))
        nameTextField.text = person.fullName
        phoneNumberTextField.text = person.phoneNumber
    }
    
    func didStateChange(to state: ViewState) {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
        case .loading:
            activityIndicator.startAnimating()
        case .success:
            activityIndicator.stopAnimating()
            delegate?.editPersonalDetailViewControllerDidUpdatePerson(personName: nameTextField.text, personImage: personImageView.image)
            presentAlertAndDismiss(title: String(localized: "edit_person_success_title"),
                                message: String(localized: "edit_person_success_message"),
                                isPopView: true)
        case .failure(let error):
            presentAlert(title: String(localized: "edit_person_error_alert_title"),
                         message: error.localizedDescription)
        }
    }
}
