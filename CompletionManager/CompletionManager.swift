// GLOBAL QUEUE THREAD
fileprivate let THREAD_COMPLETION_HANDLER = DispatchQueue(label: "com.completion.manager", attributes: .concurrent)

class CompletionObject: NSObject {
    
    var name: String = ""
    var closureID: Int?
    var manager: CompletionManager?
    var finished = false
    
    init(name: String) {
        self.name = name
    }
    
    convenience init(manager: CompletionManager) {
        self.init(name: "")
        self.manager = manager
        manager.addCompletion(self)
    }
    
    func end() {
        if let manag = manager, finished == false {
            manag.updatePartialProgress(closure: self)
        }
        
        finished = true
    }
    
    func setManager(_ manager: CompletionManager) {
        manager.addCompletion(self)
    }
    
    override var description: String {
        return "\(closureID ?? -1) \(name)"
    }
}

class CompletionManager {

    var completions = [CompletionObject]()
    private var _endCompletion: (() -> Void)?
    
    private var counter: Int = 0
    private var completed: Int = 0
    private var total: Int = 0
    private var finished = false
    
    func newCompletion() -> CompletionObject {
        let obj = CompletionObject(name: "")
        addCompletion(obj)
        return obj
    }
    
    func endCompletion(_ completion: @escaping (() -> Void)) {
        if completions.isEmpty || finished {
            completion()
        } else {
            _endCompletion = completion
        }
    }
    
    func addCompletion(_ closure: CompletionObject) {
        
        if closure.finished {
            return
        }
        
        THREAD_COMPLETION_HANDLER.async(flags: .barrier) {
            self.counter += 1
            
            closure.manager = self
            closure.closureID = self.counter
            
            self.completions.append(closure)
            
            self.total = self.completions.count
        }
    }
    
    func clearFinishedCompletions() {
        completions = completions.filter({ (obj) -> Bool in
            return obj.finished == false
        })
    }
    
    func updatePartialProgress(closure: CompletionObject) {
        
        THREAD_COMPLETION_HANDLER.async(flags: .barrier) {
            var removeIndex = 0
            self.completed += 1
            
            if self.completions.isEmpty {
                self.dispatchCompletion()
                return
            }
            
            for index in 0...(self.completions.count) - 1 {
                
                if let obj = self.completions[safe: index], obj.closureID == closure.closureID {
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
            
            // Em passagens muito rapidas, estava gerando dupla chamada do completion
            // Trazendo para uma variavel local que sera eliminado ao fim do main.async
            // e desalocando o completion na thread atual... parece corrigir o problema
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