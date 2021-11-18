//
//  ViewModel.swift
//  SwiftToolbox_Example
//
//  Created by Lucas Costa Araujo on 17/11/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import SwiftToolbox

class ViewModel {
    weak var controller: ViewController?
    
    var messages = [String]()
    
    var isTurnedOn: Bool = false
    
    func loadInfo() {
        
        // Example to use completion manager
        let manager = STCompletionManager()
        
        let simpleTask = manager.newCompletion()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.messages.append("This is the first message :)")
            simpleTask.end()
        }
        
        let otherTask = manager.newCompletion()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            self.messages.append("Second message :D")
            self.messages.append("A Third message 8)")
            self.messages.append("Another one *_*")
            self.messages.append("As the cells are being reused all the time, you can implement prepareForReuse method on every TableViewCell to handle it properly")
            otherTask.end()
        }
        
        // When all the tasks are finished
        manager.endCompletion {
            debugPrint("[DEBUG] finished loading messages")
            // update all the data
            self.controller?.buildTable()
        }
        
    }
    
    
    
}
