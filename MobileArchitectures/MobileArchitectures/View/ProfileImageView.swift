//
//  ProfileImageView.swift
//  MobileArchitectures
//
//  Created by Anita Agrawal on 03/03/18.
//  Copyright © 2018 Anita Agarwal. All rights reserved.
//

import UIKit

@objc protocol ProfileImageViewProtocols {
    func takePhotoAction()
    func uploadPhotoAction()
    func dismissPicker()
}

class ProfileImageView: UIView {
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var delegate: ProfileImageViewProtocols?
    var profileURL: String = "" {
        didSet {
            if !self.profileURL.isEmpty, let image = UIImage(contentsOfFile: Utility.getDocumentsDirectory().appendingPathComponent(profileURL)) {
                profileButton.setImage(image, for: .normal)
            }
        }
    }
    override func awakeFromNib() {
        layer.cornerRadius = frame.height/2
    }
    @IBAction func editProfileButtonAction(_ sender: Any) {
        
        let takePhoto = UIAlertAction(title: NSLocalizedString("Take Photo", comment: "Take Photo"), style: .default) { (_) in
            self.delegate?.takePhotoAction()
        }
        let uploadPhoto = UIAlertAction(title: NSLocalizedString("Upload Photo", comment: "Upload Photo"), style: .default) { (_) in
            self.delegate?.uploadPhotoAction()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        
        Utility.showActionSheet(withActions: [takePhoto, uploadPhoto, cancel], title: nil)
    }
}

extension ProfileImageView : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        }
        self.delegate?.dismissPicker()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.delegate?.dismissPicker()
    }
}
