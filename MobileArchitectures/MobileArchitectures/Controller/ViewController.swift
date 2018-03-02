//
//  ViewController.swift
//  MobileArchitectureMVC
//
//  Created by Anita Agarwal on 2/27/18.
//  Copyright © 2018 Anita Agarwal. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var backgroundScrollView: UIScrollView!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var laseNameTf: UITextField!
    @IBOutlet weak var dobTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    let imageVC = UIImagePickerController()
    var userDetails: UserProfile? {
        didSet {
           updateUserProfileUI()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageVC.delegate = self
        UserProfile.getUserProfileDetails { (profileDetails, error) in
            guard let profileData = profileDetails else {
                print(error ?? "Some error occurred")
                return
            }
            self.userDetails = profileData
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateUserProfileUI() {
        guard let profileData = userDetails else { return }
        firstNameTF.text = profileData.firstName
        laseNameTf.text = profileData.lastName
        emailTF.text = profileData.email
        phoneTF.text = profileData.phone
        dobTF.text = profileData.dateOfBirth
        guard let image = UIImage(contentsOfFile: Utility.getDocumentsDirectory().appendingPathComponent(profileData.pictureUrl)) else {return}
        profileButton.setImage(image, for: .normal)
    }
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
        if areAllFieldsValid() {
           userDetails?.firstName = firstNameTF.text ?? ""
            userDetails?.lastName = laseNameTf.text ?? ""
            userDetails?.email = emailTF.text ?? ""
            userDetails?.phone = phoneTF.text ?? ""
            userDetails?.dateOfBirth = dobTF.text ?? ""
            userDetails?.updateUserProfileDetails(completionHandler: { (message) in
                print(message)
            })
        }else {
            print("Invalid fields")
        }
    }
    
    @IBAction func profileButtonAction(_ sender: UIButton) {
        let takePhoto = UIAlertAction(title: NSLocalizedString("Take Photo", comment: "Take Photo"), style: .default) { (_) in
            self.takePhotoAction()
        }
        let uploadPhoto = UIAlertAction(title: NSLocalizedString("Upload Photo", comment: "Upload Photo"), style: .default) { (_) in
            self.uploadPhotoAction()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        
        Utility.showActionSheet(withActions: [takePhoto, uploadPhoto, cancel], title: nil)
    }
    
    //MARK:- Text fields validations
    func areAllFieldsValid()-> Bool{
        if (emailTF.text?.isEmpty ?? false) || (phoneTF.text?.isEmpty ?? false) || (firstNameTF.text?.isEmpty ?? false) || (laseNameTf.text?.isEmpty ?? false) || (dobTF.text?.isEmpty ?? false) || !(emailTF.text?.isValidEmailID() ?? true) || !(phoneTF.text?.isValidPhoneNumber() ?? true) {
            return false
        }
        return true
    }
    func takePhotoAction() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch authStatus {
            case .authorized:
                self.imageVC.sourceType = .camera
                self.present(self.imageVC, animated: true, completion: nil)
            case .denied: self.alertPromptToAllowCameraAccessViaSettings()
            default: self.permissionPrimeCameraAccess()
            }
            
        }else {
            let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK button title"), style: .default, handler: nil)
            Utility.showAlert(title: NSLocalizedString("Error", comment: "Error alert title"), messageBody: NSLocalizedString("Device has no camera", comment: "No camera alert body"), andActions: [defaultAction])
        }
    }
    func uploadPhotoAction()  {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            self.imageVC.allowsEditing = false
            self.imageVC.sourceType = .photoLibrary
            self.present(self.imageVC, animated: true, completion: nil)
        }
    }
    
    //MARK:- Camera related permissions
    func alertPromptToAllowCameraAccessViaSettings() {
        let alert = UIAlertController(title: NSLocalizedString("We Would Like To Access the Camera", comment: "Allow camera alert title"), message: NSLocalizedString("Please grant permission to use the Camera so that you can update profile pic. Please navigate to Settings -> Privacy -> Camera -> MobileArchitectureMVC and turn switch on.", comment: "Allow camera alert message"), preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { alert in
            self.openSettingsAction()
        })
        alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
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
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileButton.setImage(pickedImage, for: .normal)
            let filePath = Utility.getDocumentsDirectory().appendingPathComponent("ProfileImage.jpg")
            do {
                try UIImageJPEGRepresentation(pickedImage, 1.0)?.write(to: NSURL.fileURL(withPath: filePath), options: .atomic)
            } catch {
                print(error)
                print("file cant not be save at path \(filePath), with error : \(error)");
            }
            userDetails?.pictureUrl = "ProfileImage.jpg"
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil)
    }
}

enum TextFieldType : Int{
    case firstName = 1
    case lastName = 2
    case dateOfBirth = 3
    case phoneNumberTF = 5
    case emailIdIF = 4
}

extension ViewController: UITextFieldDelegate {
    // textField validation
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField.tag {
        case TextFieldType.phoneNumberTF.rawValue:
            if let text = textField.text {
                let newLength = text.count + string.count - range.length
                if !string.isEmpty, !string.containsOnlyChactersIn(matchCharacters: "1234567890-" ) || newLength > 12 {
                    return false
                }
                if !string.isEmpty && (newLength == 4 || newLength == 8) {
                    textField.text  = "\(text)" + "-"
                }
            }
        case TextFieldType.emailIdIF.rawValue:
            let newLength = (textField.text?.count ?? 0) + string.count - range.length
            if !string.isEmpty, !string.containsOnlyChactersIn(matchCharacters: "[A-Z0-9a-z._%+-@]") || (newLength > 200) {
                return false
            }
        default:
            break
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField.tag == TextFieldType.phoneNumberTF.rawValue {
            textField.text = textField.text?.formatPhoneNumber()
        }
    }
}