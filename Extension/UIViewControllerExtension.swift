//
//  UIViewControllerExtension.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/4/24.
//

import Foundation
import UIKit

extension UIViewController {
    func createTextFieldRow(title: String, field: UITextField) -> UIStackView {
        let label: UILabel = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .debtMateBlack
        
        let labelStackView = UIStackView(arrangedSubviews: [label, field])
        labelStackView.axis = .vertical
        labelStackView.spacing = 10
        
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        
        return labelStackView
    }
    
    func setRootViewController(_ rootViewController: UIViewController) {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()

            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setupImagePickerMenu(button: UIButton,
                              imagePickerManager: ImagePickerManagerController,
                              delegate: ImagePickerManagerControllerDelegate) {
        imagePickerManager.delegate = delegate
        
        let chooseFromLibraryAction = UIAction(title: String(localized: "image_picker_menu_choose_from_library"), image: UIImage(systemName: "photo.on.rectangle.angled")) { _ in
            imagePickerManager.presentImagePicker(viewController: self, sourceType: .photoLibrary)
        }
        
        let takePhotoAction = UIAction(title: String(localized: "image_picker_menu_take_photo"), image: UIImage(systemName: "camera")) { _ in
            imagePickerManager.presentImagePicker(viewController: self, sourceType: .camera)
        }
        
        let menu = UIMenu(title: String(localized: "image_picker_menu_title"), children: [chooseFromLibraryAction, takePhotoAction])
        
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
    }
    
    func navigateToSystemSettings() {
        guard let appSetting = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(appSetting)
    }
    
    func presentDeleteItemAlert(completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: String(localized: "alert_delete_item_title"),
                                      message: String(localized: "alert_delete_item_message"),
                                      preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: String(localized: "alert_delete_item_delete_button"), style: .destructive) { _ in
            completion(true)
        }

        let cancelAction = UIAlertAction(title: String(localized: "alert_delete_item_cancel_button"), style: .cancel) { _ in
            completion(false)
        }

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}
