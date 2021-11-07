//
//  SpacingCell.swift
//  facturation
//
//  Created by Lucas Araujo on 16/06/21.
//  Copyright © 2021 Guarana Technologies Inc. All rights reserved.
//

import UIKit

class SpacingCell: BaseGenericCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.text = ""
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = ""
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
