//
//  BaseGenericCell.swift
//  facturation
//
//  Created by Lucas Araujo on 16/06/21.
//  Copyright © 2021 Guarana Technologies Inc. All rights reserved.
//

import UIKit

class BaseGenericCell: UITableViewCell, CustomDidSelectRowAt {

    var didClick: ((IndexPath) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        didClick = nil
    }
    
    func configureLayout() { }
    
    func didSelectRowAt(indexPath: IndexPath) {
        didClick?(indexPath)
    }
}
