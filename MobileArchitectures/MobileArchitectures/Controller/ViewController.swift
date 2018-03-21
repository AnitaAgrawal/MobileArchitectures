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
    //MARK:- IBOutlets
    @IBOutlet weak var backgroundScrollView: UIScrollView!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var laseNameTf: UITextField!
    @IBOutlet weak var dobTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var keyboardAccessoryView: UIToolbar!
    
    //MARK:- Properties
    let imageVC = UIImagePickerController()
    var userDetails: UserProfile? {
        didSet {
           updateUserProfileUI()
        }
    }
    var activeTFTag = 0
    var tapGest: UITapGestureRecognizer?
    var datePicker: UIDatePicker!
    
    //MARK:- View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageVC.delegate = self
        registerKeyboardNotification()
        getUserData()
        profileButton.layer.cornerRadius = profileButton.frame.width/2
        submitButton.layer.cornerRadius = submitButton.frame.height/2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getUserData() {
        self.getUserProfileDetails { (profileDetails, error) in
            guard let profileData = profileDetails else {
                print(error ?? "Some error occurred")
                return
            }
            self.userDetails = profileData
        }
    }
    func updateUserProfileUI() {
        guard let profileData = userDetails else { return }
        firstNameTF.text = profileData.firstName
        laseNameTf.text = profileData.lastName
        emailTF.text = profileData.email
        phoneTF.text = profileData.phone.formatPhoneNumber()
        dobTF.text = profileData.dateOfBirth
        guard let image = UIImage(contentsOfFile: Utility.getDocumentsDirectory().appendingPathComponent(profileData.pictureUrl)) else {return}
        profileButton.setImage(image, for: .normal)
    }
    
    //MARK:- IBAction methods
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
        if areAllFieldsValid() {
           userDetails?.firstName = firstNameTF.text ?? ""
            userDetails?.lastName = laseNameTf.text ?? ""
            userDetails?.email = emailTF.text ?? ""
            userDetails?.phone = phoneTF.text ?? ""
            userDetails?.dateOfBirth = dobTF.text ?? ""
            self.updateUserProfileDetails(completionHandler: { (message) in
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
    
    //MARK:- Keyboard Accessory button action methods
    @IBAction func previousButtonTapped(){
        if activeTFTag > TextFieldTypes.firstName.rawValue {
            let viewWithTag = view.viewWithTag(activeTFTag - 1)
            viewWithTag?.becomeFirstResponder()
        }
    }
    @IBAction func nextButtonTapped(){
        if activeTFTag < TextFieldTypes.phoneNumberTF.rawValue {
            let viewWithTag = view.viewWithTag(activeTFTag + 1)
            viewWithTag?.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
    }
    @IBAction func doneButtonTapped(){
        view.endEditing(true)
    }
    
    //MARK:- Text fields validations
    func areAllFieldsValid()-> Bool{
        if (emailTF.text?.isEmpty ?? false) || (phoneTF.text?.isEmpty ?? false) || (firstNameTF.text?.isEmpty ?? false) || (laseNameTf.text?.isEmpty ?? false) || (dobTF.text?.isEmpty ?? false) || !(emailTF.text?.isValidEmailID() ?? true) || !(phoneTF.text?.isValidPhoneNumber() ?? true) {
            return false
        }
        return true
    }
    
    //MARK:- Profile pic selection methods
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
        let alert = UIAlertController(title: NSLocalizedString("We Would Like To Access the Camera", comment: "Allow camera alert title"), message: NSLocalizedString("Please grant permission to use the Camera so that you can update profile pic. Please navigate to Settings -> Privacy -> Camera -> MobileArchitectures and turn switch on.", comment: "Allow camera alert message"), preferredStyle: .alert )
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

//MARK:- API Calls
extension ViewController {
    func getUserProfileDetails(completionHandler: @escaping (_ profileDetails: UserProfile?, _ error: String?) -> Void) {
        let filePath = Utility.getDocumentsDirectory().appendingPathComponent("UserDetails.plist")
        if FileManager.default.fileExists(atPath: filePath), let dictionary = NSDictionary(contentsOfFile: filePath) as? Dictionary<String, Any> {
            let userDetails = UserProfile(profileDic: dictionary)
            completionHandler(userDetails, nil)
        }else {
            guard let file = Bundle.main.path(forResource: "UserDetails", ofType: "plist"), let dictionary = NSDictionary(contentsOfFile: file) as? Dictionary<String, Any> else {return completionHandler(nil, "User is not found.")}
            let userDetails = UserProfile(profileDic: dictionary)
            completionHandler(userDetails, nil)
        }
    }
    
    func updateUserProfileDetails(completionHandler: @escaping (_ message: String) -> Void) {
        let dictionary = userDetails?.getDictionary()
        
        let filePath = Utility.getDocumentsDirectory().appendingPathComponent("UserDetails.plist")
        let success = dictionary?.write(toFile: filePath, atomically: true)
        print(success ?? false)
        completionHandler( "User profile updated successfully.")
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
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == TextFieldTypes.dateOfBirth.rawValue {
            self.pickUpDate(textField)
        }else {
            textField.inputAccessoryView = keyboardAccessoryView
        }
        activeTFTag = textField.tag
        return true
    }
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
        nextButtonTapped()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField.tag == TextFieldType.phoneNumberTF.rawValue {
            textField.text = textField.text?.formatPhoneNumber()
        }
    }
}

//MARK:- Date Picker

extension ViewController {
    func pickUpDate(_ textField : UITextField){
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePickerMode.date
        textField.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ViewController.doneClick))
        let prevButton = UIBarButtonItem(title: "Prev", style: .plain, target: self, action: #selector(ViewController.previousButtonTapped))
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(ViewController.nextButtonTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(ViewController.cancelClick))
        toolBar.setItems([prevButton, nextButton, cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    @objc func doneClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.dateFormat = "dd.MM.yyyy"
        dobTF.text = dateFormatter1.string(from: datePicker.date)
        dobTF.resignFirstResponder()
    }
    @objc func cancelClick() {
        dobTF.resignFirstResponder()
    }
}

//MARK:- Keyboard handling methods
extension ViewController {
    func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    @objc private func keyboardDidShow(notification : NSNotification) {
        if let kbSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0)
            backgroundScrollView.contentInset = contentInset
        }
        dismissKeyboardGesture()
    }
    @objc private func keyboardWillHide(notification : NSNotification) {
        backgroundScrollView.contentInset = UIEdgeInsets.zero
    }
    
    private func dismissKeyboardGesture() {
        if tapGest == nil {
            tapGest = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        }
        tapGest?.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGest!)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        if tapGest != nil {
            view.removeGestureRecognizer(tapGest!)
        }
    }
}
