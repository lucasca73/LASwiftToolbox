//
//  DoubleTextInputFormCell.swift
//  FGTS
//
//  Created by Lucas Araujo on 19/06/20.
//  Copyright © 2020 CAIXA. All rights reserved.
//

import UIKit

class DoubleTextInputFormCell: UITableViewCell {

    @IBOutlet weak var leftTitle: UILabel!
    @IBOutlet weak var leftText: UITextField!
    @IBOutlet weak var leftErrorMessage: UILabel!
    
    @IBOutlet weak var rightTitle: UILabel!
    @IBOutlet weak var rightText: UITextField!
    @IBOutlet weak var rightErrorMessage: UILabel!
    
    @IBOutlet weak var leftForm: FormTextViewHandler!
    @IBOutlet weak var rightForm: FormTextViewHandler!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leftForm.validator = nil
        rightForm.validator = nil
        
        leftTitle.text = nil
        leftText.text = nil
        leftErrorMessage.text = nil
        
        rightTitle.text = nil
        rightText.text = nil
        rightErrorMessage.text = nil
    }
}
