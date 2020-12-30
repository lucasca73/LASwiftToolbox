//
//  FormField.swift
//  FGTS
//
//  Created by Lucas Araujo on 18/06/20.
//  Copyright © 2020 CAIXA. All rights reserved.
//

import Foundation

class FormField: FormValidator {
    
    var parent: FormDelegate?
    var inputDelegate: FormFieldCell?
    var updateListener: ((String) -> Void)?
    var infos: [String: String]
    var defaultValueIfEmpty: String?
    
    private var rules = [FormRule]()
    var formId: String
    var formInput: String? {
        didSet {
            if let text = self.formInput {
                inputDelegate?.setInput(text: text)
                if text != oldValue {
                    updateListener?(text)
                }
            }
        }
    }
    var reloader: (() -> Void)?
    var formMask = FormMask()
    var recoveredPool = false
    
    var errorsFound = [FormFieldError]()
    
    init(fieldId: String) {
        self.formId = fieldId
        self.infos = [:]
    }
    
    func shouldEdit(text: String) -> Bool {
        return true
    }
    
    func setParent(_ parent: FormDelegate) {
        self.parent = parent
    }
    
    func addRule<T: FormRule>(_ rule: T) {
        if rules.filter({ $0.className == rule.className }).isEmpty {
            rule.formId = formId
            self.rules.append(rule)
        } else {
            // has already
        }
    }
    
    func removeRule<T: FormRule>(_ rule: T) {
        rules.removeAll(where: {$0.className == rule.className})
    }
    
    func isValid() -> Bool {
        return hasError().isEmpty
    }
    
    func clear() {
        parent = nil
        inputDelegate = nil
        rules.removeAll()
        formInput = nil
        errorsFound.removeAll()
        reloader = nil
        updateListener = nil
        infos.removeAll()
    }
    
    func hasError() -> [FormFieldError] {
        
        var errors = [FormFieldError]()
        
        for r in rules {
            
            var text = self.formInput ?? ""
            if let defaultValue = self.defaultValueIfEmpty, text.isEmpty {
                text = defaultValue
            }
            
            if let err = r.check(text: text) {
                errors.append(err)
            }
        }
        
        return errors
    }
    
    func updateFieldInput() {
        if let input = formInput {
            inputDelegate?.setInput(text: input)
        }
    }
    
    func notifyState(errors: [FormFieldError]) {
        var errors = [FormFieldError]()
        
        for r in rules {
            
            var text = self.formInput ?? ""
            if let defaultValue = self.defaultValueIfEmpty, text.isEmpty {
                text = defaultValue
            }
            
            if let err = r.check(text: text) {
                errors.append(err)
            }
        }
        
        updateFieldInput()
        errorsFound = errors
        parent?.notifyState(errors: errors)
        inputDelegate?.notifyState(errors: errors)
        reloader?()
    }
}
