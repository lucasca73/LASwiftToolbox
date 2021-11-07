import UIKit

public class TableBuilder<T>: BuilderProtocol where T: UITableViewCell {
    
    public typealias BuildTable = ((IndexPath, T) -> Void)
    public typealias SetupEdit = ((IndexPath) -> UISwipeActionsConfiguration?)
    
    public var builder: BuildTable?
    public var rows: Int = 1
    public var type: T.Type
    public var counter: (() -> Int)?
    public var cellId: String?
    public var rowHeight: CGFloat = UITableViewAutomaticDimension
    public var leadingEdit: SetupEdit?
    public var trailingEdit: SetupEdit?
    
    public init(type: T.Type, builder: BuildTable?, cellId: String?) {
        self.builder = builder
        self.type = type
        self.cellId = cellId
    }
    
    public func callBuilder(path: IndexPath, cell: UITableViewCell) {
        // swiftlint:disable:next force_cast
        builder?(path, cell as! T)
    }
    
    public func getType<U>() -> U.Type where U: UITableViewCell {
        // swiftlint:disable:next force_cast
        return type as! U.Type
    }
    
    public func getCount() -> Int {
        if let counter = counter {
            return counter()
        }
        return rows
    }
    
    public func isTable() -> Bool {
        return true
    }
    
    public func shouldReload(id: String) -> Bool {
        return cellId?.contains(id) ?? false
    }
    
    public func getHeight() -> CGFloat {
        return rowHeight
    }
    
    public func setupLeadingEdit(index: IndexPath) -> UISwipeActionsConfiguration? {
        leadingEdit?(index)
    }
    
    public func setupTrailingEdit(index: IndexPath) -> UISwipeActionsConfiguration? {
        trailingEdit?(index)
    }
    
}
