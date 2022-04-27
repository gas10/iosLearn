//
//  File.swift
//  ProgrammingSwift
//
//  Created by Amar Gawade on 3/16/22.
//

import Foundation
class Runner {
    func test() -> String {
        executeQueue()
        return "Test"
    }
    
    func executeQueue() {
        var queue = QueueArray<String>()
        print(queue.enqueue("Ray"))
        print(queue.enqueue("Brian"))
        print(queue.enqueue("Eric"))
        print(queue)
        print(queue.dequeue() ?? "[]")
        print(queue)
        print(queue.peek ?? "[]")
    }
}
