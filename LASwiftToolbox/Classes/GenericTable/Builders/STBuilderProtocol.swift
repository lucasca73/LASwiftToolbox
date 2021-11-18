import UIKit

public protocol STBuilderProtocol {
    func callBuilder(path: IndexPath, cell: UITableViewCell)
    func getType<U>() -> U.Type where U: UITableViewCell
    func getCount() -> Int
    func isTable() -> Bool
    func shouldReload(id: String) -> Bool
    func getHeight() -> CGFloat
    func setupLeadingEdit(index: IndexPath) -> UISwipeActionsConfiguration?
    func setupTrailingEdit(index: IndexPath) -> UISwipeActionsConfiguration?
}
