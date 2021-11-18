import Foundation

open class STCompletionObject: NSObject {
    
    open var name: String = ""
    open var closureID: Int?
    open var manager: STCompletionManager?
    open var finished = false
    open var endCompletion: (() -> Void)?
    
    init(name: String) {
        self.name = name
    }
    
    convenience init(manager: STCompletionManager) {
        self.init(name: "")
        self.manager = manager
        manager.addCompletion(self)
    }
    
    open func end() {
        if let manag = manager, finished == false {
            manag.updatePartialProgress(closure: self)
        }
        
        endCompletion?()
        endCompletion = nil
        finished = true
    }
    
    open func setManager(_ manager: STCompletionManager) {
        manager.addCompletion(self)
    }
    
    open override var description: String {
        return "\(closureID ?? -1) \(name)"
    }
}

open class STCompletionManager {
    
    private static let threadCompletionHandler = DispatchQueue(label: "com.completion.manager", attributes: .concurrent)

    open var completions = [STCompletionObject]()
    private var _endCompletion: (() -> Void)?
    
    private var counter = 0
    private var completed = 0
    private var total = 0
    private var finished = false
    
    public init() {}
    
    open func newCompletion() -> STCompletionObject {
        let obj = STCompletionObject(name: "")
        addCompletion(obj)
        return obj
    }
    
    open func endCompletion(_ completion: @escaping (() -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if self.completions.isEmpty || self.finished {
                completion()
            } else {
                self._endCompletion = completion
            }
        }
    }
    
    open func addCompletion(_ closure: STCompletionObject) {
        
        if closure.finished {
            return
        }
        
        STCompletionManager.threadCompletionHandler.async(flags: .barrier) {
            self.counter += 1
            
            closure.manager = self
            closure.closureID = self.counter
            
            self.completions.append(closure)
            
            self.total = self.completions.count
        }
    }
    
    open func clearFinishedCompletions() {
        completions = completions.filter({ (obj) -> Bool in
            return obj.finished == false
        })
    }
    
    func updatePartialProgress(closure: STCompletionObject) {
        
        STCompletionManager.threadCompletionHandler.async(flags: .barrier) {
            var removeIndex = 0
            self.completed += 1
            
            if self.completions.isEmpty {
                self.dispatchCompletion()
                return
            }
            
            for index in 0..<self.completions.count {
                let obj = self.completions[index]
                if obj.closureID == closure.closureID {
                    removeIndex = index
                    break
                }
            }
            
            self.completions.remove(at: removeIndex)
            
            if self.completions.isEmpty {
                self.dispatchCompletion()
            }
        }
    }
    
    private func dispatchCompletion() {
        if !self.finished {
            
            let localRef = _endCompletion
            
            self._endCompletion = nil
            DispatchQueue.main.async {
                localRef?()
                self._endCompletion = nil
                self.finished = true
                self.clearFinishedCompletions()
            }
        }
    }
}
