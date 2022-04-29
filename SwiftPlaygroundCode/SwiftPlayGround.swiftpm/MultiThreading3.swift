//
//  MultiThreading3.swift
//  SwiftPlayGround
//
//  Created by Gawade, Amar on 4/28/22.
//

import Foundation
/**
 https://medium.com/geekculture/threads-in-ios-part-2-c4f44e885f5f
 NSOperation, advantage of NSOperation, operation

 NSOperation queue:-
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
 BlockOperation class extends from Operation class. You can use this object to execute several blocks at once without having to create separate operation objects for each. When executing more than one block, the operation itself is considered finished only when all blocks have finished executing.
 
 2. InvocationOperation:- In objective C, we can create NSInvocationOperation while it’s not available in Swift.
 
 3. Custom Operations:-
 Subclassing Operation gives you complete control over the implementation of your own operations which includes the ability to alter the default way in which your operation executes and reports its status.
 
 
 Operation Queues:-
 Operations Queues are Cocoa’s high-level abstraction on GCD. Instead of starting operation by yourself, you give to operation queue. It then handle the scheduling and execution.
 An operation queue executes its queued Operation objects based on their priority and in FIFO order.
 An operation queue executes its operations either directly, by running them on secondary threads, or indirectly using the libdispatch library (i.e. Grand Central Dispatch)
 
 */

class BlockOperationTest {
