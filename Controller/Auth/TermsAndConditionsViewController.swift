//
//  TermsAndConditionsViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/5/24.
//

import UIKit

protocol TermsAndConditionsViewControllerDelegate: AnyObject {
    func didTapAccept()
    func didTapReject()
}

class TermsAndConditionsViewController: UIViewController {
    // MARK: - Variables
    weak var delegate: TermsAndConditionsViewControllerDelegate?
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "terms_conditions_screen_title")
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.textAlignment = .left
        textView.font = .systemFont(ofSize: 16)
        textView.text = String(localized: "terms_conditions_text")
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    var rejectButton: UIButton = {
        let button = UIButton()
        button.setTitle(String(localized: "terms_conditions_reject_button"), for: .normal)
        button.setTitleColor(.debtMateBlack, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1.5
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(didTapRejectButton), for: .touchUpInside)
        return button
    }()
    
    var acceptButton: UIButton = {
        let button = UIButton()
        button.setTitle(String(localized: "terms_conditions_accept_button"), for: .normal)
        button.setTitleColor(.debtMateWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .debtMateBlack
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1.5
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(didTapAcceptButton), for: .touchUpInside)
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
        updateButtonStyles(for: traitCollection)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateButtonStyles(for: traitCollection)
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView(arrangedSubviews: [rejectButton, acceptButton])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(textView)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -20),
            
            stackView.heightAnchor.constraint(equalToConstant: 48),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    func updateButtonStyles(for traitCollection: UITraitCollection) {
        if traitCollection.userInterfaceStyle == .dark {
            rejectButton.layer.borderColor = UIColor.white.cgColor
        } else {
            rejectButton.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    // MARK: - Selectors
    @objc func didTapRejectButton() {
        print("Terms and Conditions: Reject Button Tapped")
        delegate?.didTapReject()
        dismiss(animated: true)
    }
    
    @objc func didTapAcceptButton() {
        print("Terms and Conditions: Accept Button Tapped")
        delegate?.didTapAccept()
        dismiss(animated: true)
    }
}
