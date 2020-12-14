//
//  FormManager.swift
//  FGTS
//
//  Created by Lucas Araujo on 17/06/20.
//  Copyright © 2020 CAIXA. All rights reserved.
//

import Foundation

class FormManager: FormValidator {
    
    var forms = [FormValidator]()
    var parent: FormDelegate?
    var formId: String
    
    init(formId: String) {
        self.formId = formId
    }
    
    func recoverForm(by formId: String) -> FormManager {
        for form in forms {
            if let manager = form as? FormManager {
                if manager.formId == formId {
                    return manager
                } else {
                    return manager.recoverForm(by: formId)
                }
            }
        }
        
        let validator = FormManager(formId: formId)
        add(validator)
        
        return validator
    }
    
    func recoverField(by fieldId: String) -> FormField {
        for form in forms {
            if let field = form as? FormField {
                if field.formId == fieldId {
                    field.recoveredPool = true
                    return field
                }
            } else if let manager = form as? FormManager {
                return manager.recoverField(by: fieldId)
            }
        }
        
        let validator = FormField(fieldId: fieldId)
        add(validator)
        
        return validator
    }
    
    func add(_ validator: FormValidator) {
        
        for form in forms {
            if form.formId == validator.formId {
                return
            }
        }
        
        validator.setParent(self)
        forms.append(validator)
    }
    
    func setParent(_ parent: FormDelegate) {
        self.parent = parent
    }
    
    func isValid() -> Bool {
        
        var result = true
        
        for form in forms {
            if form.isValid() == false {
                result = false
            }
        }
        
        return result
    }
    
    func clear() {
        for form in forms {
            form.clear()
        }
        forms.removeAll()
    }
    
    func hasError() -> [FormFieldError] {
        
        var errors = [FormFieldError]()
        
        for form in forms {
            errors += form.hasError()
        }
        
        return errors
    }
    
    func checkAndTriggerErrorInFields() {
        for form in forms {
            if let field = form as? FormField {
                let errors = field.hasError()
                field.updateFieldInput()
                field.errorsFound = errors
                field.inputDelegate?.notifyState(errors: errors)
                field.reloader?()
            } else {
                if let manager = form as? FormManager {
                    manager.checkAndTriggerErrorInFields()
                }
            }
        }
    }
    
    func formValue() -> [String: Any] {
        var dictionary = [String: Any]()
        
        for form in forms {
            if let field = form as? FormField {
                dictionary[field.formId] = field.formInput
            } else {
                if let manager = form as? FormManager {
                    dictionary[manager.formId] = manager.formValue()
                }
            }
        }
        
        return dictionary
    }
    
    /// The monkey is climbing the tree
    func notifyState(errors: [FormFieldError]) {
        let errors = hasError() + errors
        parent?.notifyState(errors: errors)
    }
}
