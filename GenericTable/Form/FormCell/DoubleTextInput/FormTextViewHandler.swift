//
//  FormTextViewHandler.swift
//  FGTS
//
//  Created by Lucas Araujo on 19/06/20.
//  Copyright © 2020 CAIXA. All rights reserved.
//

import UIKit

class FormTextViewHandler: UIView {
    
    var toolbarForPicker: UIToolbar {
        let toolbar = UIToolbar()
        toolbar.backgroundColor = .white
        
        toolbar.sizeToFit()
        
        let flexBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Confirmar", style: .plain, target: self, action: #selector(dismissKeyboard))
        
        toolbar.setItems([flexBtn, doneBtn], animated: true)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }
    
    @objc fileprivate func dismissKeyboard() {
        textField?.endEditing(true)
    }
    
    var validator: FormField? {
        didSet {
            self.textField?.delegate = self
            if validator?.recoveredPool ?? false {
                validator?.inputDelegate = self
                validator?.updateFieldInput()
                // last seen errors in this field
                notifyState(errors: validator?.errorsFound ?? [])
            }
        }
    }
    
    var textField: UITextField? {
        for view in self.subviews {
            if let field = view as? UITextField {
                field.inputAccessoryView = toolbarForPicker
                return field
            }
        }
        return nil
    }
    
    var errorMessage: UILabel? {
        for view in self.subviews {
            if let label = view as? UILabel, label.tag == 3 {
                return label
            }
        }
        return nil
    }
    
}

extension FormTextViewHandler: FormFieldCell {
    
    func setInput(text: String) {
        self.textField?.text = text
    }
    
    func setValidator(_ validator: FormField) {
        self.validator = validator
        validator.inputDelegate = self
    }
    
    func notifyState(errors: [FormFieldError]) {
        let resultMessage = NSMutableAttributedString()
        var shouldSetHidden = true
        
        for err in errors {
            if let message = err.description {
                shouldSetHidden = false
                resultMessage.normal("\(message)\n",
                    size: 12,
                    color: Colors.redStatement.withAlphaComponent(0.7))
            }
        }
        
        errorMessage?.isHidden = shouldSetHidden
        errorMessage?.attributedText = resultMessage
    }
}

extension FormTextViewHandler: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        validator?.infos["Editado"] = "Sim"
        
        let totalText = (textField.text ?? "") + string
        validator?.formInput = validator?.formMask.mask(text: totalText)
        
        // Erasing all characters
        if (textField.text ?? "").count == 1 && string.isEmpty {
            validator?.formInput = ""
        }
        
        if validator?.shouldEdit(text: string) ?? true && string != "" {
            textField.text = validator?.formInput
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validator?.formInput = validator?.formMask.mask(text: textField.text ?? "")
        validator?.notifyState(errors: [])
    }
}
