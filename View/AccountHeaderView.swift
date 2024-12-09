//
//  Accountself.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/8/24.
//

import UIKit

class AccountHeaderView: UIView {
    private let accountImageView: UIImageView = {
        let imageView = CircularImageView(cornerRadius: 45)
        imageView.image = UIImage(named: "mock-profile")
        return imageView
    }()
    
    private let accountFullnameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Guest"
        return label
    }()
    
    private let accountEmailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "guest@email.com"
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.backgroundColor = .clear
        
        self.addSubview(accountImageView)
        self.addSubview(accountFullnameLabel)
        self.addSubview(accountEmailLabel)

        NSLayoutConstraint.activate([
            accountImageView.widthAnchor.constraint(equalToConstant: 90),
            accountImageView.heightAnchor.constraint(equalToConstant: 90),
            accountImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            accountImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            
            accountFullnameLabel.topAnchor.constraint(equalTo: accountImageView.bottomAnchor, constant: 15),
            accountFullnameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            accountFullnameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            accountEmailLabel.topAnchor.constraint(equalTo: accountFullnameLabel.bottomAnchor, constant: 8),
            accountEmailLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            accountEmailLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            accountEmailLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
        ])
        
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200)
    }

    func configure(with user: User) {
        accountFullnameLabel.text = user.fullName
        accountEmailLabel.text = user.email
        if let imageURL = user.imageURL {
            accountImageView.setImage(imageURL: imageURL)
        } else {
            accountImageView.image = UIImage(named: "mock-profile")
        }
    }
}
