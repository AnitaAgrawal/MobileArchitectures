//
//  BaseViewController.swift
//  MobileArchitectures
//
//  Created by Anita Agrawal on 03/03/18.
//  Copyright © 2018 Anita Agarwal. All rights reserved.
//

import UIKit
import AVFoundation

class BaseViewController: UIViewController {
    @IBOutlet weak var profileBGView: ProfileImageView!
    let imageVC = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageVC.delegate = profileBGView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func takePhotoActionWithCameraPermission(message: String) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch authStatus {
            case .authorized:
                self.presentCamera()
            case .denied: self.alertPromptToAllowCameraAccessViaSettings(message: message)
            default: self.permissionPrimeCameraAccess()
            }
            
        }else {
            let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK button title"), style: .default, handler: nil)
            Utility.showAlert(title: NSLocalizedString("Error", comment: "Error alert title"), messageBody: NSLocalizedString("Device has no camera", comment: "No camera alert body"), andActions: [defaultAction])
        }
    }
    func alertPromptToAllowCameraAccessViaSettings(message: String) {
        let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default) { alert in
            self.openSettingsAction()
        }
        let notNowAction = UIAlertAction(title: "Not Now", style: .cancel, handler: nil)
        Utility.showAlert(title: NSLocalizedString("We Would Like To Access the Camera", comment: "Allow camera alert title"), messageBody: message, andActions: [openSettingsAction, notNowAction])
    }
    func openSettingsAction() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
    }
    func permissionPrimeCameraAccess() {
        if (AVCaptureDevice.default(for: .video) != nil) {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted in
                DispatchQueue.main.async {
                    if granted == true {
                        self.imageVC.sourceType = .camera
                        self.present(self.imageVC, animated: true, completion: nil)
                    }
                }
            })
        }
    }
    func presentCamera() {
        self.imageVC.sourceType = .camera
        self.present(self.imageVC, animated: true, completion: nil)
    }
}

extension BaseViewController: ProfileImageViewProtocols {
    func dismissPicker() {
        dismiss(animated: true, completion:nil)
    }
    func takePhotoAction() {
        self.takePhotoActionWithCameraPermission(message: "Please grant permission to use the Camera so that you can update profile pic. Please navigate to Settings -> Privacy -> Camera -> MobileArchitectures and turn switch on.")
    }
    func uploadPhotoAction() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            self.imageVC.allowsEditing = false
            self.imageVC.sourceType = .photoLibrary
            self.present(self.imageVC, animated: true, completion: nil)
        }
    }
}
