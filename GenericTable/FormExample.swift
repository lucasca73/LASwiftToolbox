//
//  FormExample.swift
//  GenericTable
//
//  Created by Lucas Araujo on 26/06/20.
//  Copyright © 2020 costa. All rights reserved.
//

import Foundation
import UIKit

class FormExample {
    
    let manager = FormManager(formId: "MainForm")
    
    func setupFields() {
        
        // Field side
        let firstNameField = manager.recoverField(by: "firstName")
        firstNameField.addRule(FormRuleFieldEmpty())
        
        let lastNameField = manager.recoverField(by: "lastName")
        lastNameField.formMask.add(FormMaskClearSpace())
        
        // View side
        let firstNameCell = BasicTextFormViewCell()
        firstNameCell.setValidator(firstNameField)
        
        let lastNameCell = BasicTextFormViewCell()
        lastNameCell.setValidator(lastNameField)
    }
    
    func checkValue() {
        
        // Returns a dictionary with field values
        let formValue = manager.formValue()
        debugPrint(formValue)
        
        let errors = manager.hasError()
        if errors.isEmpty {
            debugPrint("Form is ok, all input passed")
        } else {
            debugPrint("Some field is not right")
            
            // Notify delegate to handle field errors
            manager.parent?.notifyState(errors: errors)
        }
    }
    
    
}
