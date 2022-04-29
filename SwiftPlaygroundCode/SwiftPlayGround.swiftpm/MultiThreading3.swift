//
//  MultiThreading3.swift
//  SwiftPlayGround
//
//  Created by Gawade, Amar on 4/28/22.
// NSOperation and Operation Queue
// https://medium.com/geekculture/threads-in-ios-part-2-c4f44e885f5f
// Part 4: https://manasaprema04.medium.com/multithreading-in-ios-part-4-4-27632d180f39

import Foundation
// MARK: - One: NSOperation
/**
 Another way to create thread is using operation. After you have created instances of your operations, submit the operations to OperationQueue.
 The OperationQueue will manage the threads and also responsible for running the operations that you have provided to it.
 
 What is operation - An abstract class that represents the code and data associated with a single task.
 
 Operation States:- Operation object maintain states internally to determine when it is safe to execute and also to notify external clients of the progress through the operation’s life cycle.
    isReady: It informs client when an operation is ready to execute. This returns true when the operation is ready to execute now or false if there are still unfinished operations on which it is dependent.
    isExecuting: This tells us whether the operation is executing the assigned task. isExecuting returns true if the operation is working on its task or false if it is not.
    isFinished: It informs that an operation finished its task successfully or was cancelled. Operation queue does not dequeue an operation or operation object will not clear until the isFinished value changes to true.
    isCancelled: This inform clients that the cancellation of an operation was requested.
 
 How can you cancel operation? - using cancel()
 Effect of cancel()
     Your operation is already finished. In that case, the cancel method has no effect.
     Your operation is already being executing. In that case, system will NOT force your operation code to stop but instead, cancelled property will be set to true.
     Your operation is still in the queue waiting to be executed. In that case, your operation will not be executed.
 
 How can we create operation?
 Developer no need to use this directly. Foundation provides two system-defined sub classes InvocationOperation and BlockOperation to execute task.
 There are mainly three ways to create operations:-
     BlockOperation
     InvocationOperation
     Custom Operations
 
 1.BlockOperation :- An operation that manages the concurrent execution of one or more blocks.
 BlockOperation class extends from Operation class. You can use this object to execute several blocks at once without having to create separate operation objects for each.
 When executing more than one block, the operation itself is considered finished only when all blocks have finished executing.
 
 2. InvocationOperation:- In objective C, we can create NSInvocationOperation while it’s not available in Swift.
 
 3. Custom Operations:-
 Subclassing Operation gives you complete control over the implementation of your own operations which includes the ability to alter the default way in which your operation executes and reports its status.
 */

class BlockOperationTest {
    
    private func testBlockOperation() {
        // MARK: - Create a block opeartion and Add to operation queue
        // Create block operation
        let aBlockOperation = BlockOperation() {
            for count in 0...3 {
                MultiThreadingTest.log("Current count in block is \(count)")
            }
        }
        // Create operation queue
        let queue = OperationQueue()
        // Add block opeartion to queue
        queue.addOperation(aBlockOperation)
        
        // MARK: -  Adding the block directly on the operation queue
        OperationQueue().addOperation {
            for count in 0...3 {
                MultiThreadingTest.log("Current count in directly added block is \(count)")
            }
        }
    }
    
    // Create multiple block operation and start. Concurrent execution of block operation.
    private func testMultipleBlockOpeartion() {
        // Create block operation
        let aBlockOperation = BlockOperation()
        // Add a block
        aBlockOperation.addExecutionBlock {
            for count in 1...3 {
                MultiThreadingTest.log("Current count in block one is \(count)")
            }
        }
        
        // Add another block
        aBlockOperation.addExecutionBlock {
            for count in 4...6 {
                MultiThreadingTest.log("Current count in block two is \(count)")
            }
        }
        aBlockOperation.start()
    }
    
    func testWorkflow() {
        testBlockOperation()
        testMultipleBlockOpeartion()
    }
}

// Subclassing Operation to create Custom Operation
class CustomOperationTest {
    private func testCustomOperation() {
        // Declare custom operation by subclassing Operation and Override main
        class CustomOperation: Operation {
            override func main() {
                for count in 1...3 {
                    MultiThreadingTest.log("Current count in custom block is \(count)")
                }
            }
        }
        // Create and Start
        let aCustomOperation = CustomOperation()
        // Main thread blocked here and operation started
        aCustomOperation.start()
        MultiThreadingTest.log("This block is executed at end after operation block executed")
    }
    
    private func testCustomConcurrentOperation() {
        // Declare custom operation by subclassing Operation and Override main, start
        class CustomConcurrentOperation: Operation {
            override func main() {
                for count in 1...3 {
                    MultiThreadingTest.log("Current count in custom concurrent block is \(count)")
                }
            }
            
            override func start() {
                Thread.init(block: main).start()
            }
        }
        // Create and Start
        let aCustomConcurrentOperation = CustomConcurrentOperation()
        // Non blocking call to start
        aCustomConcurrentOperation.start()
        MultiThreadingTest.log("Control returned from here and then operation code executed concurrently")
    }
    
    private func testCancelOperation() {
        // Declare custom operation by subclassing Operation and Override main, start
        class CustomConcurrentOperation: Operation {
            override func main() {
                for count in 1...3000000 {
                    if isCancelled {
                        MultiThreadingTest.log("Current count in custom concurrent block when operation is cancelled \(count)")
                        break
                    }
                    MultiThreadingTest.log("Current count in custom concurrent block is \(count), isMainThread: \(Thread.isMainThread)")
                }
            }
            
            override func start() {
                Thread.init(block: main).start()
            }
        }
        // Create and Start
        let aCustomConcurrentOperation = CustomConcurrentOperation()
        // Non blocking call to start
        aCustomConcurrentOperation.start()
        // Sleep to cancel aCustomConcurrentOperation
        sleep(1)
        // Cancel aCustomConcurrentOperation
        aCustomConcurrentOperation.cancel()
    }
    
    func testWorkflow() {
        testCustomOperation()
        testCustomConcurrentOperation()
        testCancelOperation()
    }
}

// MARK: - Two: Operational Queue
/**
 Operations Queues are Cocoa’s high-level abstraction on GCD. Instead of starting operation by yourself, you give to operation queue. It then handle the scheduling and execution.
 An operation queue executes its queued Operation objects based on their priority and in FIFO order.
 An operation queue executes its operations either directly, by running them on secondary threads, or indirectly using the libdispatch library (i.e. Grand Central Dispatch)
 */

class OperationQueueTest {
    private func testOperationQueue() {
        let queue = OperationQueue()
        MultiThreadingTest.log("Getting Operation Queue...")
        for count in 1...5 {
            // Add operations to queue
            queue.addOperation {
                process(count)
            }
        }
        
        // A function for doing a task
        func process(_ count: Int) {
            for subCount in 1...5 {
                MultiThreadingTest.log("Total count is \(count + subCount)")
            }
        }
        queue.waitUntilAllOperationsAreFinished()
        MultiThreadingTest.log("Finished running all in Operation Queue")
    }
    
    private func operationQueueMethods() {
        let queue = OperationQueue()
        
        /**
         Example for cancelling all operation in queue
         Operation queues retain operations until they’re finished. Suspending an operation queue with operations that aren’t finished can result in a memory leak.
         */
        queue.cancelAllOperations()
        
        /**
         maxConcurrentOperationCount help us to set max concurrent operation but it’s recommended not to set.
         The maxConcurrentOperationCount is set to 1 to allow operations finishing one by one. it act as serial queue
         
         How does the queue decide how many operations it can run at once?
            It depends on the hardware. By default, OperationQueue does some calculation behind the scenes and decides the maximum possible number of threads depending on platform it’s running on
         */
        queue.maxConcurrentOperationCount = 4   // by default value is -1 which means let the system decide
        
        /**
         In which order operation queue executes task?
         Operations within a queue are organised according to their readiness i.e. (isReady property returns true), priority level & dependencies, and are executed accordingly.
         If all of the queued operations have the same queuePriority and are ready to execute when they are put in the queue, they’re executed in the order in which they were submitted to the queue.
         Otherwise, the operation queue always executes the one with the highest priority relative to the other ready operations.
         An operation object will not be ready to execute until all of its dependent operations have finished executing.
         */
        
    }
    
    /**
     How to add dependency between operation?
     Consider a situation where you need to call two api after these api completion you need to parse a response then you need to use dependency manager to achieve this
     */
    private func addingOperationDependancy() {
        let aOperation = BlockOperation {
            for count in 1...3 {
                MultiThreadingTest.log("Current count in aOperation block is \(count)")
            }
        }
        
        let anotherOperation = BlockOperation {
            for count in 1...3 {
                MultiThreadingTest.log("Current count in anotherOperation block is \(count)")
            }
        }
        
        // Consider another operation is depndant on aOperation
        anotherOperation.addDependency(aOperation)
        //
        let queue = OperationQueue()
        queue.addOperation(aOperation)
        queue.addOperation(anotherOperation)
        queue.maxConcurrentOperationCount = 2
    }
    
    /**
     we used GCD dispatch group feature to block a thread until one or more tasks finished executing.
     we implemented the same behaviour using Operation Queues by using dependencies. This is useful when you can’t do anything until all of the specified tasks are completed.
     In some situation you need to run concurrently and when all the tasks finished we need to call some method to indicate that all tasks has finished. this can be achieve by using waitUntilFinished
     */
    // Dispatch Group Implementation Using Operations Queue:-
    private func dispatchGroupLikeInOperationQueue() {
        DispatchQueue.global().async {
            let aOperation = BlockOperation {
                for count in 1...3 {
                    MultiThreadingTest.log("Current count in aOperation block is \(count)")
                }
            }
            
            let anotherOperation = BlockOperation {
                for count in 1...3 {
                    MultiThreadingTest.log("Current count in anotherOperation block is \(count)")
                }
            }
            
            let queue = OperationQueue()
            queue.addOperations([aOperation, anotherOperation], waitUntilFinished: true)
        }
    }
    
    /**
     Asynchronous Versus Synchronous Operations:-
     If you plan on executing an operation object manually, instead of adding it to a queue, you can design your operation to execute in a synchronous or asynchronous manner.
     Operation objects are synchronous by default. When you call the start() method of a synchronous operation directly from your code, the operation executes immediately in the current thread.
     When you call the start() method of an asynchronous operation, that method may return before the corresponding task is completed. An asynchronous operation object is responsible for scheduling its task on a separate thread.
     */
    
    func testWorkflow() {
        testOperationQueue()
        operationQueueMethods()
        addingOperationDependancy()
        dispatchGroupLikeInOperationQueue()
    }
}
