//
//  File.swift
//  ProgrammingSwift
//
//  Created by Amar Gawade on 3/16/22.
//

import Foundation

// MARK: BFS
class SolutionBFS {
    // Level order BST traversal
    func levelOrder(_ root: TreeNode?) -> [[Int]] {
        var ans = [[Int]]()
        var queue = QueueArray<TreeNode>()
        guard let root = root else { return ans }
        queue.enqueue(root)
        while(!queue.isEmpty) {
            var levelAns = [Int]()
            let size = queue.size
            for _ in 0..<size {
                guard let node = queue.dequeue() else { fatalError() }
                if let left = node.left {
                    queue.enqueue(left)
                }
                if let right = node.right {
                    queue.enqueue(right)
                }
                levelAns.append(node.val)
            }
            ans.append(levelAns)
        }
        return ans
    }
}

public class TreeNode {
    public var val: Int
    public var left: TreeNode?
    public var right: TreeNode?
    public init() { self.val = 0; self.left = nil; self.right = nil; }
    public init(_ val: Int) { self.val = val; self.left = nil; self.right = nil; }
    public init(_ val: Int, _ left: TreeNode?, _ right: TreeNode?) {
        self.val = val
        self.left = left
        self.right = right
    }
}

// MARK: DFS
class SolutionDFS {
    // is valid parenthesis
    func isValid(_ s: String) -> Bool {
        var stack = StackArray<Character>()
        let str = Array(s)
        let map:[Character: Character] = [")": "(", "]": "[", "}": "{"]
        for ch in str {
            if let mapVal = map[ch] {
                guard let stackTop = stack.pop() else { return false }
                if(mapVal != stackTop ) { return false }
            } else {
                stack.push(ch)
            }
        }
        return stack.isEmpty
    }
}
