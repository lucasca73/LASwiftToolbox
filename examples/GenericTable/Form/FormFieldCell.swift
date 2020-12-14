//
//  FormFieldCell.swift
//  FGTS
//
//  Created by Lucas Araujo on 18/06/20.
//  Copyright © 2020 CAIXA. All rights reserved.
//

import Foundation

protocol FormFieldCell: FormDelegate {
    func setInput(text: String)
    func setValidator(_ validator: FormField)
}
