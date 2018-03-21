//
//  ProfileMVVMViewController.swift
//  MobileArchitectures
//
//  Created by Anita Agrawal on 13/03/18.
//  Copyright © 2018 Anita Agarwal. All rights reserved.
//

import UIKit

class ProfileMVVMViewController: BaseViewController, KeyboardOnScrollView {
    @IBOutlet weak var contactInfoView: ContactInfoView!
    @IBOutlet weak var keyboardOnScrollView: UIScrollView!
    @IBOutlet weak var submitButton: UIButton!
    var userDetails: ProfileViewModelProtocol = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactInfoView.contactDetails = userDetails
        submitButton.layer.cornerRadius = submitButton.frame.height/2
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userDetails.getUserProfileDetails()
        contactInfoView.updateContactInfoUIWith(details: userDetails)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- IBAction methods
    @IBAction func submitButtonAction(_ sender: UIButton) {
        userDetails.updateUserProfileAPICallFor(completionHandler: { (isSuccess) in
            Utility.showAlert(title: isSuccess ? "Success" : "Error", messageBody: isSuccess ? "Updated profile successfully." : "Looks like something went wrong. Please try again later.", andActions: [UIAlertAction(title: "OK", style: .default)])
        })
    }
}
