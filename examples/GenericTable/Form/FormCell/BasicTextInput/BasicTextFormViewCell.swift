//
//  BasicTextFormViewCell.swift
//  FGTS
//
//  Created by Lucas Araujo on 18/06/20.
//  Copyright © 2020 CAIXA. All rights reserved.
//

import UIKit

class BasicTextFormViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    var validator: FormField?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textField.delegate = self
        validator = nil
        title.text = ""
        errorMessage.text = ""
        errorMessage.isHidden = true
        textField.text = ""
    }
}

extension BasicTextFormViewCell: FormFieldCell {
    
    func setInput(text: String) {
        self.textField.text = text
    }
    
    func setValidator(_ validator: FormField) {
        self.validator = validator
        validator.inputDelegate = self
    }
    
    func notifyState(errors: [FormFieldError]) {
        var resultMessage: String = ""
        var shouldSetHidden = true
        
        for err in errors {
            if let message = err.description {
                shouldSetHidden = false
                resultMessage += "\(message)\n"
            }
        }
        
        errorMessage.isHidden = shouldSetHidden
        errorMessage.text = resultMessage
    }
}

extension BasicTextFormViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
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
