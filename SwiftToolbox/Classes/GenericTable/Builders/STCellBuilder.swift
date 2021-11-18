import UIKit

public class STCellBuilder<T>: STBuilderProtocol where T: UITableViewCell {
    
    public typealias BuildCell = ((T) -> Void)
    public typealias SetupEdit = (() -> UISwipeActionsConfiguration?)
    
    public var buildCell: BuildCell?
    public var type: T.Type
    public var cellId: String?
    public var height: CGFloat = UITableViewAutomaticDimension
    public var leadingEdit: SetupEdit?
    public var trailingEdit: SetupEdit?
    
    public init(type: T.Type, builder: BuildCell?, cellId: String?) {
        self.buildCell = builder
        self.type = type
        self.cellId = cellId
    }
    
    // swiftlint:disable force_cast
    public func callBuilder(path: IndexPath, cell: UITableViewCell) {
        buildCell?(cell as! T)
    }
    
    public func getType<U>() -> U.Type where U: UITableViewCell {
        return type as! U.Type
    }
    // swiftlint:enable force_cast
    
    public func getCount() -> Int {
        return 1
    }
    
    public func isTable() -> Bool {
        return false
    }
    
    public func shouldReload(id: String) -> Bool {
        return cellId?.contains(id) ?? false
    }
    
    public func getHeight() -> CGFloat {
        return height
    }
    
    public func setupLeadingEdit(index: IndexPath) -> UISwipeActionsConfiguration? {
        leadingEdit?()
    }
    
    public func setupTrailingEdit(index: IndexPath) -> UISwipeActionsConfiguration? {
        trailingEdit?()
    }
}
