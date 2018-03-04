//
//  CustomTextField.swift
//  MobileArchitectures
//
//  Created by Anita Agrawal on 03/03/18.
//  Copyright © 2018 Anita Agarwal. All rights reserved.
//

import UIKit

enum TextFieldTypes: Int {
    case firstName = 1
    case lastName = 2
    case dateOfBirth = 3
    case emailIdIF = 4
    case phoneNumberTF = 5
    case defalut
}

@IBDesignable class CustomTextField: UITextField {
    @IBInspectable var maxLength : Int = 0
    @IBInspectable var ignoredCharacter : String = ""
    @IBInspectable var allowedCharacters : String?
    @IBOutlet weak var keyboardAccessoryView: UIToolbar!
    var stringValue : String {return text ?? ""}
    var filteredString : String? {
        return stringValue.components(separatedBy: CharacterSet(charactersIn: ignoredCharacter)).joined()
    }
    override func awakeFromNib() {
        self.inputAccessoryView = keyboardAccessoryView
    }

}
