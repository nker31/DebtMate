//
//  OnboardingViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/17/24.
//

import UIKit

class OnboardingViewController: UIViewController {
    // MARK: - Variables
    private var imageName: String
    private var headline: String
    private var subheadline: String
    
    // MARK: - UI Components
    private let onBoardingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let onBoardingHeadline: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.textAlignment = .center
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let onBoardingSubheadline: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    init(imageName: String, headline: String, subheadline: String) {
        self.headline = headline
        self.subheadline = subheadline
        self.imageName = imageName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(onBoardingImageView)
        view.addSubview(onBoardingHeadline)
        view.addSubview(onBoardingSubheadline)
        
        let layoutMargins = view.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            onBoardingImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            onBoardingImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            onBoardingImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            onBoardingImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            
            onBoardingHeadline.topAnchor.constraint(equalTo: onBoardingImageView.bottomAnchor, constant: 24),
            onBoardingHeadline.leadingAnchor.constraint(equalTo: layoutMargins.leadingAnchor),
            onBoardingHeadline.trailingAnchor.constraint(equalTo: layoutMargins.trailingAnchor),
            
            onBoardingSubheadline.topAnchor.constraint(equalTo: onBoardingHeadline.bottomAnchor, constant: 12),
            onBoardingSubheadline.leadingAnchor.constraint(equalTo: layoutMargins.leadingAnchor),
            onBoardingSubheadline.trailingAnchor.constraint(equalTo: layoutMargins.trailingAnchor)
        ])
    }
    
    private func setupData() {
        onBoardingImageView.image = UIImage(named: imageName)
        onBoardingHeadline.text = headline
        onBoardingSubheadline.text = subheadline
    }
}
