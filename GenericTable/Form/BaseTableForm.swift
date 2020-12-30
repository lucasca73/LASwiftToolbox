//
//  BaseTableForm.swift
//  FGTS
//
//  Created by Lucas Araujo on 18/06/20.
//  Copyright © 2020 CAIXA. All rights reserved.
//

import UIKit

class BaseTableForm: BaseTableViewController {
    
    var formManager = FormManager(formId: "Form")
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        formManager.clear()
    }
    
    func addForm<T: UITableViewCell>(form: T.Type, formId: String, builder: ((T) -> Void)? = nil) {
        
        super.add(cell: form, reloadListener: formId) { cell in
            
            if let formCell = cell as? FormFieldCell {
                
                let reloader = {
                    self.reload(id: formId)
                }
                
                // Validator controll to not duplicate on form manager
                let validator = self.formManager.recoverField(by: formId)
                formCell.setValidator(validator)
                validator.reloader = reloader
                
                if validator.recoveredPool {
                    validator.updateFieldInput()
                    // last seen errors in this field
                    formCell.notifyState(errors: validator.errorsFound)
                }
            }
            
            builder?(cell)
        }
    }
    
}
