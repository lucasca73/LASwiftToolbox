//
//  BaseGenericCell.swift
//  facturation
//
//  Created by Lucas Araujo on 16/06/21.
//  Copyright © 2021 Guarana Technologies Inc. All rights reserved.
//

import UIKit

open class STBaseGenericCell: UITableViewCell, STCustomDidSelectRowAt {

    open var didClick: ((IndexPath) -> Void)?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
        selectionStyle = .none
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        didClick = nil
    }
    
    open func configureLayout() { }
    
    open func didSelectRowAt(indexPath: IndexPath) {
        didClick?(indexPath)
    }
}
