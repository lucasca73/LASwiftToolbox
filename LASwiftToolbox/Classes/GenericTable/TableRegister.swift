import UIKit

public extension UITableView {
    
    var maximumIndexPath: IndexPath {
        let lastSection = max(0, numberOfSections - 1)
        let lastRow = max(0, numberOfRows(inSection: lastSection) - 1)
        return IndexPath(row: lastRow, section: lastSection)
    }
    
    func register<T: UITableViewCell>(cellType: T.Type, bundle: Bundle? = nil) {
        let className = cellType.className
        register(cellType, forCellReuseIdentifier: className)
    }
    
    func register<T: UITableViewCell>(cellTypes: [T.Type], bundle: Bundle? = nil) {
        cellTypes.forEach { register(cellType: $0, bundle: bundle) }
    }
    
    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        // swiftlint:disable force_cast
        return self.dequeueReusableCell(withIdentifier: type.className, for: indexPath) as! T
        // swiftlint:enable force_cast
    }
    
    func scrollToBottom(animated: Bool = true) {
        guard maximumIndexPath != IndexPath(row: 0, section: 0) else { return }
        scrollToRow(at: maximumIndexPath, at: .bottom, animated: animated)
    }
    
}
