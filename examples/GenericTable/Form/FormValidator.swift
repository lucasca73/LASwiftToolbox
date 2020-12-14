//
//  FormValidator.swift
//  FGTS
//
//  Created by Lucas Araujo on 17/06/20.
//  Copyright © 2020 CAIXA. All rights reserved.
//

import Foundation

protocol FormValidator: FormDelegate {
    var parent: FormDelegate? { get set }
    func isValid() -> Bool
    func clear()
    func hasError() -> [FormFieldError]
    func setParent(_ parent: FormDelegate)
    var formId: String { get }
}

extension FormValidator {
    mutating func setParent(_ parent: FormDelegate) {
        self.parent = parent
    }
}

protocol FormDelegate {
    func notifyState(errors: [FormFieldError])
}
