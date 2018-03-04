//
//  ContactInfoView.swift
//  MobileArchitectures
//
//  Created by Anita Agrawal on 03/03/18.
//  Copyright © 2018 Anita Agarwal. All rights reserved.
//

import UIKit

class ContactInfoView: UIStackView {

    @IBOutlet weak var firstNameTF: CustomTextField!
    @IBOutlet weak var laseNameTf: CustomTextField!
    @IBOutlet weak var dobTF: CustomTextField!
    @IBOutlet weak var emailTF: CustomTextField!
    @IBOutlet weak var phoneTF: CustomTextField!
    var activeTFTag = 0
    
    //MARK:- Keyboard Accessory button actions
    @IBAction func previousButtonTapped(){
        if activeTFTag > TextFieldTypes.firstName.rawValue {
            let viewWithTag = self.viewWithTag(activeTFTag - 1)
            viewWithTag?.becomeFirstResponder()
        }
    }
    @IBAction func nextButtonTapped(){
        if activeTFTag < TextFieldTypes.phoneNumberTF.rawValue {
            let viewWithTag = self.viewWithTag(activeTFTag + 1)
            viewWithTag?.becomeFirstResponder()
        } else {
            endEditing(true)
        }
    }
    @IBAction func doneButtonTapped(){
        endEditing(true)
    }
    
    //MARK:- Text fields validations
    func areAllFieldsValid()-> Bool{
        if (emailTF.text?.isEmpty ?? false) || (phoneTF.text?.isEmpty ?? false) || (firstNameTF.text?.isEmpty ?? false) || (laseNameTf.text?.isEmpty ?? false) || (dobTF.text?.isEmpty ?? false) || !(emailTF.text?.isValidEmailID() ?? true) || !(phoneTF.text?.isValidPhoneNumber() ?? true) {
            return false
        }
        return true
    }
}

extension ContactInfoView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTFTag = textField.tag
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.count ?? 0) + string.count - range.length
        if !string.isEmpty, let textField = (textField as? CustomTextField), let allowedChar = textField.allowedCharacters, !string.containsOnlyChactersIn(matchCharacters: allowedChar ) || newLength > textField.maxLength {
            return false
        }
        switch TextFieldTypes(rawValue: textField.tag) ?? TextFieldTypes.defalut {
        case TextFieldTypes.phoneNumberTF:
            if let text = textField.text {
                if (!string.isEmpty && (newLength == 4 || newLength == 8)), let textField = (textField as? CustomTextField) {
                    textField.text  = "\(text)" + "\(textField.ignoredCharacter)"
                }
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
        if textField.tag == TextFieldTypes.phoneNumberTF.rawValue {
            textField.text = textField.text?.formatPhoneNumber()
        }
    }
}
