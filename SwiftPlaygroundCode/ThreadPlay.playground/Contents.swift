import PlaygroundSupport;
defer{ PlaygroundPage.current.finishExecution() }

import UIKit
/**
 Creating multiple thread can be achieved by bellow three ways in iOS
 1) Creating and managing threads manually
 2) Using GCD (Grand Central Dispatch):
 3) Operations and queues (NSOperation)
 */

class ManualThreadTest {
    func threadBasics() {
        // Main Thread
        let current = Thread.current
        print("Current Thread", current, current.stackSize)
        
        let aThread = Thread()
        aThread.name = "Thread 1"
        print("Thread 1", aThread, aThread.stackSize)
        
        let anotherThread = Thread()
        anotherThread.name = "Thread 2"
        
        // Stack Size: Each thread has its own stack size. Main thread has 1MB stack size it can be less than that depending on use.
        // secondary thread is allocated with ~524KB of stack space by default.
        // Full stack is not created immediately. Actual stack size grows with use
        // You can set default stack size before the start of thread using stackSize
        anotherThread.stackSize = 4096 * 512
        print("Thread 2", anotherThread, anotherThread.stackSize)
    }
    
    // There are two ways of creating threads manually
    func createThreads() {
        // Create using detach - Thread will start running immediately
        Thread.detachNewThreadSelector(#selector(runningMessage), toTarget: self, with: nil)
        
        // Create using init - explicityly need to call start to run thread
        let newThread = Thread(target: self, selector: #selector(runningMessage), object: nil)
        newThread.start()
    }
    
    @objc func runningMessage() {
        print("Running thread...")
    }
    
    func testWorkflow() {
        let test = ManualThreadTest()
        test.threadBasics()
        test.createThreads()
    }
}

/**
 GCD is the abstract away for thread management code and makes working with threads easier and more efficient.
 It moves all thread creation and management work down to the system level.
 GCD manages a collection of dispatch queues. They are usually referred as queues. The work submitted to these dispatch queues is executed on a pool of threads
 */
class GCDTest {
    func dispatchQueueTest() {
        let dispatchQueue = DispatchQueue(label: "Amar's Dispatch Queue")
    }
}


