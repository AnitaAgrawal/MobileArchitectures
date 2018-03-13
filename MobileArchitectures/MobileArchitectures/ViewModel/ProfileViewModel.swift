//
//  ProfileViewModel.swift
//  MobileArchitectures
//
//  Created by Anita Agrawal on 13/03/18.
//  Copyright © 2018 Anita Agarwal. All rights reserved.
//

import Foundation
import UIKit

protocol ContactInfoDelegate: class {
    func areContactInfoValid(isValid: Bool) -> Void
}

protocol ContactInfoProtocol {
    var firstName: String {get set}
    var lastName: String {get set}
    var dateOfBirth: String {get set}
    var phoneText: String {get set}
    var emailText: String {get set}
    var isPhoneValid: Bool {get}
    var isEmailValid: Bool {get}
    var areContactInfoValid: Bool {get}
}

extension ContactInfoProtocol {
    
    var areContactInfoValid: Bool {
        return isPhoneValid && isEmailValid && !firstName.isEmpty && !lastName.isEmpty && !dateOfBirth.isEmpty
    }
    var isPhoneValid: Bool {
        return !phoneText.isEmpty && phoneText.isValidPhoneNumber()
    }
    var isEmailValid: Bool {
        return !emailText.isEmpty && emailText.isValidEmailID()
    }
}

protocol ProfileViewModelProtocol: ContactInfoProtocol {
    var profileImage: UIImage? {get set}
    func getUserProfileDetails()
    func updateUserProfileAPICallFor(completionHandler: @escaping (_ isSuccess: Bool) -> Void)
}

class ProfileViewModel: ProfileViewModelProtocol {
    var userDetails: UserProfile?
    var profileImage: UIImage?
    
    func getUserProfileDetails() {
        UserProfile.getUserProfileDetails { (profileDetails, error) in
            guard let profileData = profileDetails else {
                print(error ?? "Some error occurred")
                return
            }
            self.userDetails = profileData
        }
    }
    
    func updateUserProfileAPICallFor(completionHandler: @escaping (Bool) -> Void) {
        if areContactInfoValid {
            userDetails?.updateUserProfileDetails(completionHandler: { (message) in
                Utility.showAlert(title: "Success", messageBody: message, andActions: [UIAlertAction(title: "OK", style: .default)])
            })
        }else {
            print("Invalid fields")
        }
    }
    
    var firstName: String {
        get {
            return userDetails?.firstName ?? ""
        }
        set {
            userDetails?.firstName = newValue
        }
    }
    
    var lastName: String {
        get {
            return userDetails?.lastName ?? ""
        }
        set {
            userDetails?.lastName = newValue
        }
    }
    
    var dateOfBirth: String {
        get {
            return userDetails?.dateOfBirth ?? ""
        }
        set {
            userDetails?.dateOfBirth = newValue
        }
    }
    
    var phoneText: String {
        get {
            return userDetails?.phone ?? ""
        }
        set {
            userDetails?.phone = newValue
        }
    }
    
    var emailText: String {
        get {
            return userDetails?.email ?? ""
        }
        set {
            userDetails?.email = newValue
        }
    }
    
    
}
