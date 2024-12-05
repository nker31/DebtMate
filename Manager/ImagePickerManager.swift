//
//  ImagePickerManager.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/5/24.
//

import UIKit
import AVFoundation
import Photos
import PhotosUI

protocol ImagePickerManagerControllerDelegate: AnyObject {
    func imagePicked(_ image: UIImage)
}

class ImagePickerManagerController: UIViewController {
    // MARK: - Varibles
    weak var delegate: ImagePickerManagerControllerDelegate?

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Class Methods
    func presentImagePicker(viewController: UIViewController, sourceType: UIImagePickerController.SourceType) {
        guard sourceType == .camera || sourceType == .photoLibrary else {
            print("Unsupported source type.")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if sourceType == .camera {
                self?.checkCameraPermission { access in
                    if access {
                        self?.presentCameraImagePickerController(viewController: viewController)
                    } else {
                        self?.showPermissionAlert(viewController: viewController)
                    }
                }
            } else {
                self?.presentPhotoPickerController(viewController: viewController)
            }
        }
    }
    
    private func presentPhotoPickerController(viewController: UIViewController) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        viewController.present(picker, animated: true)
    }
    
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { access in
                if access {
                    completion(access)
                }
            }
        case .restricted, .denied:
            completion(false)
        case .authorized:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    private func presentCameraImagePickerController(viewController: UIViewController) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        viewController.present(imagePickerController, animated: true)
    }

    private func showPermissionAlert(viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Permission Required",
            message: "Please enable camera or photo library access in your device settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        viewController.present(alert, animated: true)
    }
}

extension ImagePickerManagerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            delegate?.imagePicked(selectedImage)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ImagePickerManagerController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }
        
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.delegate?.imagePicked(image)
                }
            }
        }
    }
}
