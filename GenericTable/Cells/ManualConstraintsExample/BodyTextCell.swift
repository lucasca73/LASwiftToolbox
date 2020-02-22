//
//  BodyTextCell.swift
//  GenericTable
//
//  Created by Lucas Araujo on 22/02/20.
//  Copyright © 2020 costa. All rights reserved.
//

import UIKit

class BodyTextCell: BaseCell {
    
    var bodyLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(bodyLabel)
        
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.numberOfLines = 0
        
        bodyLabel.setAllConstraints(on: self.contentView, padding: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        bodyLabel.text = ""
    }
    
    func setupView(text: String) {
        bodyLabel.text = text
    }
    
}
