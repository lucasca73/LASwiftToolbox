//
//  FormMask.swift
//  FGTS
//
//  Created by Lucas Araujo on 18/06/20.
//  Copyright © 2020 CAIXA. All rights reserved.
//

import Foundation

class FormMask: ClassNameProtocol {
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
        let contains = masks.contains(where: { (otherMask) -> Bool in
            return otherMask.className == mask.className
        })
        if contains == false {
            masks.append(mask)
        }
        return self
    }
}

class FormMaskClearSpace: FormMask {
    override func mask(text: String) -> String {
        let newText = String(text.filter { !" \n\t\r".contains($0) })
        return super.mask(text: newText).remove(" ")
    }
}

class FormMaskNumber: FormMask {
    override func mask(text: String) -> String {
        let newText = String(text.filter { !" \n\t\r".contains($0) })
        return super.mask(text: newText).removeNonNumericCharacters() ?? ""
    }
}

class FormMaskToInteger: FormMask {
    override func mask(text: String) -> String {
        let superString = super.mask(text: text)
        if let integer = Int(superString) {
            return String(integer)
        }
        return superString
    }
}

class FormMaskCEP: FormMask {
    override func mask(text: String) -> String {
        return super.mask(text: text).toZipCodeFormat()
    }
}

class FormMaskCPF: FormMask {
    override func mask(text: String) -> String {
        return super.mask(text: text).toCpfFormat()
    }
}

class FormMaskNIS: FormMask {
    override func mask(text: String) -> String {
        let superText = super.mask(text: text)
        
        let nisNumber = superText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "***.*****.**-*"
        
        var result = ""
        var index = nisNumber.startIndex
        for ch in mask where index < nisNumber.endIndex {
            if ch == "*" {
                result.append(nisNumber[index])
                index = nisNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        
        return result
    }
}

class FormMaskMaxLength: FormMask {
    
    var maxLength: Int
    
    required init(_ maxLength: Int) {
        self.maxLength = maxLength
        super.init()
    }
    
    override func mask(text: String) -> String {
        let newText = String(text.filter { !"\n\t\r".contains($0) })
        
        if newText.count > maxLength {
            return super.mask(text: newText).replacing(range: maxLength...(newText.count - 1), with: "")
        } else {
            return super.mask(text: text)
        }
    }
}
