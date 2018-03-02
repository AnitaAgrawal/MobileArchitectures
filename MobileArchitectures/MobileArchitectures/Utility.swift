//
//  Utility.swift
//  MobileArchitectureMVC
//
//  Created by Anita Agarwal on 2/28/18.
//  Copyright © 2018 Anita Agarwal. All rights reserved.
//

import Foundation
import UIKit

class Utility {
    /**
     This funtion is used to display an alert on keyWindow.
     
     - parameter title : Alert title, pass nil for no title
     - parameter messate : Alert Message
     - parameter actions : An array containing all alert actions to be performed on the alert. Each action will have title, style and completion handler block if needed to execute when tapped on.
     */
    static func showAlert(title : String?,
                          messageBody message : String,
                          andActions actions : [UIAlertAction]) -> Void {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            for alertAction in actions {
                alert.addAction(alertAction)
                alertAction.setValue(alertAction.style == .destructive ? #colorLiteral(red: 0.6666666667, green: 0.1529411765, blue: 0.1843137255, alpha: 1) : #colorLiteral(red: 0.01176470588, green: 0.4470588235, blue: 0.5333333333, alpha: 1)
                    , forKey: "titleTextColor")
            }
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    /**
     This funtion is used to display an actionsheet on keyWindow.
     
     - parameter actions : An array containing all alert actions to be performed on the actionsheet. Each action will have title, style(pass .destructive for red color button) and completion handler block if needed to execute when tapped on.
     */
    static func showActionSheet(withActions actions : [UIAlertAction], title:String?) -> Void {
        let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        for alertAction in actions {
            actionSheet.addAction(alertAction)
            alertAction.setValue(alertAction.style == .destructive ? #colorLiteral(red: 0.6666666667, green: 0.1529411765, blue: 0.1843137255, alpha: 1) : #colorLiteral(red: 0.01176470588, green: 0.4470588235, blue: 0.5333333333, alpha: 1)
                , forKey: "titleTextColor")
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(actionSheet, animated: true, completion: nil)
    }
    //Get documentsDirectory path
    static func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
}

extension String {
    func containsOnlyChactersIn(matchCharacters : String) -> Bool {
        let disallowedCharacterSet = CharacterSet(charactersIn: matchCharacters).inverted
        return rangeOfCharacter(from: disallowedCharacterSet) == nil
    }
    // email validation
    func isValidEmailID() -> Bool {
        let emailTest = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        return emailTest.evaluate(with: self, substitutionVariables: nil)
    }
    
    func isValidPhoneNumber() -> Bool {
        return self.count == 10
    }
    // Phone number validation
    func formatPhoneNumber() -> String {
        return self.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "$1-$2-$3", options: .regularExpression, range: nil)
    }
}
