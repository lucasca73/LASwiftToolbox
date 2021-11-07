import UIKit

public class SectionBuilder {
    
    public var height: CGFloat = 0
    public var title: String?
    public var viewBuilder: SectionViewBuilder?
    public var builders = [BuilderProtocol]()
    public var sectionId: String?
    
    public func isTable() -> Bool {
        
        if builders.isEmpty {
            return false
        }
        
        if let builder = builders.first {
            if builder.isTable() {
                return true
            }
        }
        
        return false
    }
    
    public func getTable() -> BuilderProtocol? {
        if isTable() {
            return builders[0]
        }
        
        return nil
    }
    
    public func getNumberOfRows() -> Int {
        
        var count = 0
        for builder in builders {
            count += builder.getCount()
        }
        
        return count
    }
    
    public func hasBuilders() -> Bool {
        return builders.isEmpty == false
    }
}
