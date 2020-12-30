//
//  FormRule.swift
//  FGTS
//
//  Created by Lucas Araujo on 18/06/20.
//  Copyright © 2020 CAIXA. All rights reserved.
//

import Foundation

class FormRule: NSObject {
    var formId: String?
    func check(text: String) -> FormFieldError? {
        return nil
    }
}

class FormRuleFieldEmpty: FormRule {
    override func check(text: String) -> FormFieldError? {
        if text.isEmpty {
            let err = FormFieldError()
            err.description = "Campo não pode ser vazio"
            err.senderFormId = formId
            return err
        }
        
        return nil
    }
}

class FormRuleFieldZero: FormRule {
    override func check(text: String) -> FormFieldError? {
        
        if let numero = Int(text), numero == 0 {
            let err = FormFieldError()
            err.description = "Campo não pode estar zerado"
            err.senderFormId = formId
            return err
        }
        
        return nil
    }
}

class FormRuleExactLenght: FormRule {
    
    var exactLength: Int
    
    required init(exactLength: Int) {
        self.exactLength = exactLength
        super.init()
    }
    
    override func check(text: String) -> FormFieldError? {
        
        if text.count != self.exactLength {
            let err = FormFieldError()
            err.description = "Campo deve ter \(exactLength) caracteres"
            err.senderFormId = formId
            return err
        }
        
        return nil
    }
}
