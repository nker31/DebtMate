//
//  PersonHeaderView.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/13/24.
//

import UIKit

class PersonHeaderView: UIView {
    private let personImageView: UIImageView = {
        let imageView = CircularImageView(cornerRadius: 45)
        imageView.image = UIImage(named: "mock-profile")
        return imageView
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
        
        self.addSubview(personImageView)

        NSLayoutConstraint.activate([
            personImageView.widthAnchor.constraint(equalToConstant: 90),
            personImageView.heightAnchor.constraint(equalToConstant: 90),
            personImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            personImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
        
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120)
    }
    
    func configure(imageURL: String?) {
        personImageView.setImage(imageURL: imageURL,
                                 placeholder: UIImage(named: "mock-profile"))
    }
}
