//
//  File 2.swift
//  ProgrammingSwift
//
//  Created by Amar Gawade on 3/16/22.
//

import Foundation
// MARK: - Queue implementation using array
protocol QueueImpl {
    associatedtype Element
    mutating func enqueue(_ value: Element) -> Bool
    mutating func dequeue() -> Element?
    var isEmpty: Bool { get }
    var peek: Element? { get }
    var size: Int { get }
}

public struct QueueArray<T>: QueueImpl {
    var queue = [T]()
    init() {}
    
    @discardableResult
    public mutating func enqueue(_ value: T) -> Bool {
        queue.append(value)
        return true
    }
    
    public mutating func dequeue() -> T? {
        guard !isEmpty else { return nil }
        return queue.removeFirst()
    }
    
    public var isEmpty: Bool {
        queue.isEmpty
    }
    
    public var peek: T? {
        return queue.first
    }
    
    public var size: Int {
        queue.count
    }
}

extension QueueArray: CustomStringConvertible {
  public var description: String {
    String(describing: queue)
  }
}

// MARK: - Stack implementation using array
protocol Stack {
    associatedtype Element
    mutating func pop() -> Element?
    mutating func push(_ value: Element)
    var isEmpty: Bool { get }
}

struct StackArray<T>: Stack {
    init() { }
    private var stack = [T]()
    
    mutating func push(_ value: T) {
        stack.append(value)
    }
    
    mutating func pop() -> T? {
        guard !isEmpty else { return nil }
        return stack.removeLast()
    }
    
    var isEmpty: Bool {
        stack.count == 0 ? true : false
    }
}
