import UIKit

class TableBuilder<T>: BuilderProtocol where T: UITableViewCell {
    
    typealias buildTable = ((IndexPath, T) -> Void)
    
    var builder: buildTable?
    var rows: Int = 1
    var type: T.Type
    var counter: (() -> Int)?
    var cellId: String?
    var rowHeight: CGFloat = UITableView.automaticDimension
    
    init(type: T.Type, builder: buildTable?, cellId: String?) {
        self.builder = builder
        self.type = type
        self.cellId = cellId
    }
    
    func callBuilder(path: IndexPath, cell: UITableViewCell) {
        builder?(path, cell as! T)
    }
    
    func getType<U>() -> U.Type where U: UITableViewCell {
        return type as! U.Type
    }
    
    func getCount() -> Int {
        if let counter = counter {
            return counter()
        }
        return rows
    }
    
    func isTable() -> Bool {
        return true
    }
    
    func shouldReload(id: String) -> Bool {
        return cellId?.contains(id) ?? false
    }
    
    func getHeight() -> CGFloat {
        return rowHeight
    }
}