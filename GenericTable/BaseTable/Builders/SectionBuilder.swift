import UIKit

class SectionBuilder {
    
    var height: CGFloat = 0
    var title: String?
    var viewBuilder: SectionViewBuilder?
    var builders = [BuilderProtocol]()
    var sectionId: String?
    
    func isTable() -> Bool {
        
        if builders.isEmpty {
            return false
        }
        
        if let b = builders.first {
            if b.isTable() {
                return true
            }
        }
        
        return false
    }
    
    func getTable() -> BuilderProtocol? {
        if isTable() {
            return builders[0]
        }
        
        return nil
    }
    
    func getNumberOfRows() -> Int {
        
        var count = 0
        for i in builders {
            count += i.getCount()
        }
        
        return count
    }
    
    func hasBuilders() -> Bool {
        return builders.isEmpty == false
    }
}
