//
//  ProfileImprovedMVC.swift
//  MobileArchitectures
//
//  Created by Anita Agrawal on 02/03/18.
//  Copyright © 2018 Anita Agarwal. All rights reserved.
//

import UIKit

class ProfileImprovedMVC: BaseViewController, KeyboardOnScrollView {
    @IBOutlet weak var contactInfoView: ContactInfoView!
    @IBOutlet weak var keyboardOnScrollView: UIScrollView!
    @IBOutlet weak var submitButton: UIButton!
    
    var userDetails: UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.layer.cornerRadius = submitButton.frame.height/2
    }
    override func viewWillAppear(_ animated: Bool) {
        UserProfile.getUserProfileDetails { (profileDetails, error) in
            guard let profileData = profileDetails else {
                print(error ?? "Some error occurred")
                return
            }
            self.userDetails = profileData
            self.updateUserProfileUI()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUserProfileUI() {
        guard let profileData = userDetails else { return }
        contactInfoView.firstNameTF.text = profileData.firstName
        contactInfoView.laseNameTf.text = profileData.lastName
        contactInfoView.emailTF.text = profileData.email
        contactInfoView.phoneTF.text = profileData.phone.formatPhoneNumber()
        contactInfoView.dobTF.text = profileData.dateOfBirth
        profileBGView.profileURL = profileData.pictureUrl
    }
    
    //MARK:- IBAction methods
    @IBAction func submitButtonAction(_ sender: UIButton) {
        if contactInfoView.areAllFieldsValid() {
            userDetails?.firstName = contactInfoView.firstNameTF.text ?? ""
            userDetails?.lastName = contactInfoView.laseNameTf.text ?? ""
            userDetails?.email = contactInfoView.emailTF.text ?? ""
            userDetails?.phone = contactInfoView.phoneTF.text ?? ""
            userDetails?.dateOfBirth = contactInfoView.dobTF.text ?? ""
            userDetails?.updateUserProfileDetails(completionHandler: { (message) in
            Utility.showAlert(title: "Success", messageBody: message, andActions: [UIAlertAction(title: "OK", style: .default)])
            })
        }else {
            print("Invalid fields")
        }
    }
}
