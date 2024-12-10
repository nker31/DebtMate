//
//  AddManaualPersonViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/10/24.
//

import UIKit

class AddManualPersonViewController: UIViewController {
    // MARK: - Varibles
    private var imagePickerManager: ImagePickerManagerController
    
    // MARK: - UI Components
    private let profileImageView: UIImageView = CircularImageView(cornerRadius: 60)
    
    private let imagePickerButton: UIButton = CircularImagePickerButton(cornerRadius: 15)
    
    private let nameTextField: UITextField = DebtMateTextField(
        placeholder: String(localized: "add_manual_person_name_placeholder")
    )
    
    private let phoneNumberTextField: UITextField = DebtMateTextField(
        placeholder: String(localized: "add_manual_person_phone_number_placeholder"),
        type: .phoneNumber
    )
    
    private lazy var nameStackView = createTextFieldRow(
        title: String(localized: "add_manual_person_name_label"),
        field: nameTextField
    )
    
    private lazy var phoneNumberStackView = createTextFieldRow(
        title: String(localized: "add_manual_person_phone_number_label"),
        field: phoneNumberTextField
    )
    
    private let addButton: UIButton = {
        let button = DebtMateButton(title: "Add", type: .regular)
        button.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializer
    init(imagePickerManager: ImagePickerManagerController = ImagePickerManagerController()) {
        self.imagePickerManager = imagePickerManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setNavigationBar()
        setupImagePickerMenu(button: imagePickerButton,
                             imagePickerManager: imagePickerManager,
                             delegate: self)
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(profileImageView)
        view.addSubview(imagePickerButton)
        view.addSubview(nameStackView)
        view.addSubview(phoneNumberStackView)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            imagePickerButton.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -30),
            imagePickerButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 0),
            imagePickerButton.widthAnchor.constraint(equalToConstant: 30),
            imagePickerButton.heightAnchor.constraint(equalToConstant: 30),
            
            nameStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            phoneNumberStackView.topAnchor.constraint(equalTo: nameStackView.bottomAnchor, constant: 16),
            phoneNumberStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            phoneNumberStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            addButton.topAnchor.constraint(equalTo: phoneNumberStackView.bottomAnchor, constant: 16),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 48),
        ])
    }
    
    func setNavigationBar() {
        title = String(localized: "add_manual_person_screen_title")
    }
    
    // MARK: - Selectors
    @objc private func didTapAddButton() {
        
    }
}

extension AddManualPersonViewController: ImagePickerManagerControllerDelegate {
    func imagePicked(_ image: UIImage) {
        profileImageView.image = image
    }
}
