//
//  ViewController.swift
//  GenericTable
//
//  Created by Lucas Araujo on 22/02/20.
//  Copyright © 2020 costa. All rights reserved.
//

import UIKit

protocol ExampleStoryboardPresenter {
    var controller: BaseViewController? { get set }
    func getCountries() -> [String]
    func selectCountry(country: String) -> Void
    func loadInfo() -> Void
}

class ExamplePresenter: ExampleStoryboardPresenter {
    var controller: BaseViewController?
    
    func getCountries() -> [String] {
        return ["🇧🇷Brazil🇧🇷 \n 👌\n", "UK", "Chile", "Australia", "Japan", "China"]
    }
    
    func loadInfo() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.controller?.reloadView()
        }
    }
    
    func selectCountry(country: String) {
        let detailController = ExampleViewController(title: country)
        controller?.navigationController?.pushViewController(detailController, animated: true)
    }
}

class ExampleStoryboardViewController: BaseViewController {

    var presenter: ExampleStoryboardPresenter = ExamplePresenter()
    
    override func viewDidLoad() {
        presenter.controller = self
        presenter.loadInfo()
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "Example Generic Table"
    }
    
    override func setupView() {
        
        add(cell: HeaderCell.self) { cell in
            cell.setupView(title: "MUSSUM IPSUM", subtitle: "Mussum Ipsum, cacilds vidis litro abertis. Praesent vel viverra nisi. Mauris aliquet nunc non turpis scelerisque, eget")
        }
        
        add(cell: BodyTextCell.self) { cell in
            cell.setupView(text: "One text body")
        }
        
        let countries = presenter.getCountries()
        
        // Conditional presentation
        if countries.isEmpty == false {
            addSection(title: "Countries", height: 40)
            
            addTable(cell: BodyTextCell.self, count: countries.count) { (indexPath, cell) in
                cell.selectionStyle = .default
                
                let text = countries[indexPath.row]
                
                cell.setupView(text: text)
                cell.didClick = { indexPath in
                    cell.setSelected(false, animated: true)
                    self.presenter.selectCountry(country: text)
                }
            }
        }
    }
    
    override func setupPlaceholder() {
        addPlaceholder(HeaderCell.self)
        addPlaceholder(BodyTextCell.self)
    }
}

