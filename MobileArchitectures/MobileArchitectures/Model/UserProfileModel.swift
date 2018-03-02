//
//  UserProfileModel.swift
//  MobileArchitectureMVC
//
//  Created by Anita Agarwal on 2/28/18.
//  Copyright © 2018 Anita Agarwal. All rights reserved.
//

import Foundation

struct UserProfile {
    var firstName :     String
    var lastName :      String
    var pictureUrl :    String
    var phone :         String
    var email :         String
    var dateOfBirth:    String
    
    init(profileDic : Dictionary<String, Any>) {
        firstName       = profileDic["FirstName"] as? String ?? ""
        lastName        = profileDic["LastName"] as? String ?? ""
        pictureUrl      = profileDic["PictureUrl"] as? String ?? ""
        phone           = profileDic["Phone"] as? String ?? ""
        email           = profileDic["Email"] as? String ?? ""
        dateOfBirth     = profileDic["DateOfBirth"] as? String ?? ""
    }
    
    func getDictionary() -> NSDictionary {
        var userDetailsDict = [String: Any]()
        userDetailsDict["FirstName"] = firstName
        userDetailsDict["LastName"] = lastName
        userDetailsDict["PictureUrl"] = pictureUrl
        userDetailsDict["Phone"] = phone
        userDetailsDict["Email"] = email
        userDetailsDict["DateOfBirth"] = dateOfBirth
        
        return NSDictionary(dictionary: userDetailsDict)
    }
    
    static func getUserProfileDetails(completionHandler: @escaping (_ profileDetails: UserProfile?, _ error: String?) -> Void) {
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
        let dictionary = getDictionary()
        
        let filePath = Utility.getDocumentsDirectory().appendingPathComponent("UserDetails.plist")
       let success = dictionary.write(toFile: filePath, atomically: true)
        print(success)
        completionHandler( "User profile updated successfully.")
    }
    
}
