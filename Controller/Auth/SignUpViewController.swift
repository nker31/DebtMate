//
//  SignUpViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/5/24.
//

import UIKit

class SignUpViewController: UIViewController {
    // MARK: - Varibles
    
    // MARK: - UI Components
    
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
    }
    
    // MARK: - Selectors
    
}
