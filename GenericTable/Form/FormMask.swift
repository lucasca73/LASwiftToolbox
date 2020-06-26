//
//  FormMask.swift
//  FGTS
//
//  Created by Lucas Araujo on 18/06/20.
//  Copyright © 2020 CAIXA. All rights reserved.
//

import Foundation

class FormMask {
    var masks = [FormMask]()
    func mask(text: String) -> String {
        
        var newText = text
        for m in masks {
            newText = m.mask(text: newText)
        }
        
        return newText
    }
    
    @discardableResult
    func add(_ mask: FormMask) -> FormMask {
        masks.append(mask)
        return self
    }
}

class FormMaskClearSpace: FormMask {
    override func mask(text: String) -> String {
        return super.mask(text: text).replacingOccurrences(of: " ", with: "")
    }
}

//class FormMaskCPF: FormMask {
//    override func mask(text: String) -> String {
//        return super.mask(text: text).toCpfFormat()
//    }
//}
