import UIKit

public class STSectionBuilder {
    
    public var height: CGFloat = 0
    public var title: String?
    public var viewBuilder: STSectionViewBuilder?
    public var builders = [STBuilderProtocol]()
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
    
    public func getTable() -> STBuilderProtocol? {
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
