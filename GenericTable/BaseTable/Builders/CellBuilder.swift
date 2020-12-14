import UIKit

class CellBuilder<T>: BuilderProtocol where T: UITableViewCell {
    
    typealias BuildCell = ((T) -> Void)
    
    var buildCell: BuildCell?
    var type: T.Type
    var cellId: String?
    var height: CGFloat = UITableView.automaticDimension
    
    init(type: T.Type, builder: BuildCell?, cellId: String?) {
        self.buildCell = builder
        self.type = type
        self.cellId = cellId
    }
    
    func callBuilder(path: IndexPath, cell: UITableViewCell) {
        buildCell?(cell as! T)
    }
    
    func getType<U>() -> U.Type where U: UITableViewCell {
        return type as! U.Type
    }
    
    func getCount() -> Int {
        return 1
    }
    
    func isTable() -> Bool {
        return false
    }
    
    func shouldReload(id: String) -> Bool {
        return cellId?.contains(id) ?? false
    }
    
    func getHeight() -> CGFloat {
        return height
    }
}