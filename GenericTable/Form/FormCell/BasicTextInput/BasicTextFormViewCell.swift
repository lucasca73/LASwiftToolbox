//
//  BasicTextFormViewCell.swift
//  FGTS
//
//  Created by Lucas Araujo on 18/06/20.
//  Copyright © 2020 CAIXA. All rights reserved.
//

import UIKit

class BasicTextFormViewCell: BaseTableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    // Form
    var validator: FormField?
    
    // Picker
    var picker: UIPickerView?
    var pickerOptions: [String]?
    var pickerSelection: ((Int) -> String?)?
    var toolbarForPicker: UIToolbar {
        let toolbar = UIToolbar()
        toolbar.backgroundColor = .white
        
        toolbar.sizeToFit()
        
        let flexBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Confirmar", style: .plain, target: self, action: #selector(dismissKeyboard))
        
        toolbar.setItems([flexBtn, doneBtn], animated: true)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }
    
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
        textField.placeholder = nil
        
        // Removendo dados do picker
        pickerSelection = nil
        picker = nil
        pickerOptions = nil
        textField.inputView = nil
        textField.inputAccessoryView = toolbarForPicker
    }
    
    func bindTitle(title: String) {
        self.title.attributedText = NSMutableAttributedString().normal(title, size: 16, color: Colors.outerSpace)
    }
    
    func setupPicker(options: [String], selection: @escaping ((Int) -> String?) ) {
        
        picker = UIPickerView()
        
        pickerOptions = options
        self.pickerSelection = selection
        
        textField.shouldResignOnTouchOutsideMode = .enabled
        
        picker?.delegate = self
        picker?.dataSource = self
        picker?.shouldResignOnTouchOutsideMode = .enabled
        
        textField.inputView = picker
        
        self.didClick = { [weak self] in
            self?.textField.becomeFirstResponder()
        }
    }
    
    @objc fileprivate func dismissKeyboard() {
        if let row = picker?.selectedRow(inComponent: 0) {
            let text = self.pickerSelection?(row) ?? ""
            validator?.formInput = validator?.formMask.mask(text: text)
            textField.text = validator?.formInput
        }
        
        textField.endEditing(true)
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
        let resultMessage = NSMutableAttributedString()
        var shouldSetHidden = true
        
        for err in errors {
            if let message = err.description {
                shouldSetHidden = false
                resultMessage.normal("\(message)\n",
                    size: 12,
                    color: Colors.redStatement.withAlphaComponent(0.7))
            }
        }
        
        errorMessage.isHidden = shouldSetHidden
        errorMessage.attributedText = resultMessage
    }
}

extension BasicTextFormViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        validator?.infos["Editado"] = "Sim"
        
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

extension BasicTextFormViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions?[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let text = self.pickerSelection?(row) ?? ""
        validator?.formInput = validator?.formMask.mask(text: text)
        textField.text = validator?.formInput
    }
}
