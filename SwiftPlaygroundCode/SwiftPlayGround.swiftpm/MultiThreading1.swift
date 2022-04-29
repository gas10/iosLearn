import UIKit
/**
 https://medium.com/geekculture/threads-in-ios-gcd-nsoperation-part-1-64e460c0bdea
 
 Creating multiple thread can be achieved by bellow three ways in iOS
 1) Creating and managing threads manually
 2) Using GCD (Grand Central Dispatch):
 3) Operations and queues (NSOperation)
 */

class ManualThreadTest {
    private func threadBasics() {
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
    private func createThreads() {
        // Create using detach - Thread will start running immediately
        Thread.detachNewThreadSelector(#selector(runningMessage), toTarget: self, with: nil)
        
        // Create using init - explicityly need to call start to run thread
        let newThread = Thread(target: self, selector: #selector(runningMessage), object: nil)
        newThread.start()
    }
    
    @objc private func runningMessage() {
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
 
 4 cases - sync, async,       serial, concurrent
 
 1. Serial Queue/Synchronous queue: It helps to execute synchronous task i.e one at a time.
 It means that the thread that initiated that operation will wait for the task to finish before continuing.
 2. Concurrent Queue/Asynchronous queue: Allows us to execute multiple task at a time.
 Task will start in the order they’re added but they can finish in any order as they can be executed in parallel.
 
 GCD provides three kinds of queues which are available to you:
 1. The Main dispatch queue (serial, pre-defined)
 2. Global queues (concurrent, pre-defined)
 3. Private queues (can be serial or concurrent, you create them) -
 
 async — concurrent: the code runs on a background thread. Control returns immediately to the main thread. It will not block any updates to the UI.
 The block can’t assume that it’s the only block running on that queue
 sync — concurrent: the code runs on a background thread but the main thread waits for it to finish, blocking any updates to the UI.
 The block can’t assume that it’s the only block running on that queue.
 
 async — serial: the code runs on a background thread. Control returns immediately to the main thread. It will not block any updates to the UI.
 The block can assume that it’s the only block running on that queue
 sync — serial: the code runs on a background thread but the main thread waits for it to finish, blocking any updates to the UI.
 The block can assume that it’s the only block running on that queue.
 
 In case of async, control is always returned back from function. Async task will be executed later
 
 */
class GCDTest {
    private func invokeWorkflow() {
        // 1. Sync and ASync task Test for main Queue
        mainQueueTest()
        
        // 2. running global queue
        globalQueueTest()
        
        // 3. Creating private queue
        /**
         // Creating a dispatch queue object
        let dispatchQueue = DispatchQueue(label: "Amar's Dispatch Queue",
                                          qos: DispatchQoS,
                                          attributes: DispatchQueue.Attributes,
                                          autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency,
                                          target: DispatchQueue?)
         */
        // create private serial and concurrent queue
        privateQueueTest()
    }
    
    
    // MARK: - Main Queue (Serial)
    // Never us sync on main queue as it will cause deadlock
    private func mainQueueTest() {
        print("Synchronous Line 1")
        // Running task asynchronously. Order of Line 2 is random.
        DispatchQueue.main.async {
            print("ASynchronous Line 2")
        }
        print("Synchronous Line 3")
    }
    
    // MARK: - Global Queue (concurrent)
    // Global queue are always concurrent.
    private func globalQueueTest() {
        // Method will return and below code block will be run at any time
        // Async - Concurrent
        DispatchQueue.global().async {
            print("ASynchronous Global Dispatach Queue")
        }
        
        // Method won't return unless below codeblack is executed
        // Sync - Concurrent
        DispatchQueue.global().sync {
            print("Synchronous Global Dispatach Queue")
        }
    }
    
    // MARK: - Private Queue (Serial and Concurrent)
    private func privateQueueTest() {
        // Blocking queue
        serailQueueTest()
        // Non blocking queue
        concurrentQueueTest()
    }
    
    // Serial Queue
    private func serailQueueTest() {
        // create a queue that is ordered(serial).
        let serialQueue = DispatchQueue(label: "Serial Queue")
        
        print("Started Serial Queue Async Operation")
        // Called asynchronously. Task will be run in fix order
        // Async - Serial
        serialQueue.async {
            for index in 0...5 {
                print("Serial Queue Async Statement \(index)")
            }
        }
        print("Finished Serial Queue Async Operation")
        
        print("Started Serial Queue Sync Operation")
        // Called in synch with the flow. Task will be run in fix order
        // Sync - Serial
        serialQueue.sync {
            for index in 0...5 {
                print("Serial Queue sync Statement \(index)")
            }
        }
        print("Finished Serial Queue Sync Operation")
    }
    
    // Concurrent Queue
    private func concurrentQueueTest() {
        // create a concurrent that is unordered(concurrent).
        let concurrentQueue = DispatchQueue(label: "Concurrent Queue", attributes: .concurrent)
        
        print("Started Concurrent Queue Async Operation")
        // Called asynchronously. Task will be run in random order
        // Async - Concurrent
        concurrentQueue.async {
            for index in 0...5 {
                print("Concurrent Queue Async Statement \(index)")
            }
        }
        print("Finished Concurrent Queue Async Operation")
        
        
        print("Started Concurrent Queue Sync Operation")
        // Called in synch with the flow. Task will be run in random order
        // Sync - Concurrent
        concurrentQueue.sync {
            for index in 0...5 {
                print("Concurrent Queue sync Statement \(index)")
            }
        }
        print("Finished Concurrent Queue Sync Operation")
    }
    
    func testWorkflow() {
        let test = GCDTest()
        test.invokeWorkflow()
    }
}

/**
 qos (quality of service) : This value determines the priority at which the system schedules tasks for execution.
 Types are User-interactive,User-initiated, Utility, Background. Higher the priority, higher will be the allocation of resources to that queue.
 */
class QualityOfService {
    /**
     let dispatchQueue = DispatchQueue(label: "Amar's Dispatch Queue",
                                       qos: DispatchQoS,
                                       attributes: DispatchQueue.Attributes,
                                       autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency,
                                       target: DispatchQueue?)
     */
    private func qosWorkflow() {
        // MARK: -  qos (quality of service)
        // User Interactive - Run only on main thread. Super fast, low latency task (main Thread)
        let userInteractiveQueue = DispatchQueue(label: "UserInteractive", qos: .userInteractive)
        
        // User Initiated - tasks that are initiated from the UI and can be performed asynchronously.
        let userInitiatedQueue = DispatchQueue(label: "userInitiated", qos: .userInitiated)
        
        // Default - The priority level of this QoS falls between user-initiated and utility. GCD global queue runs at this level.
        let defaultQueue = DispatchQueue(label: "default", qos: .default)
        
        // Utility -  long-running tasks, typically with a user-visible progress indicator
        let utilityQueue = DispatchQueue(label: "utility", qos: .utility)
        
        // Background -  prefetching, maintenance, and other tasks that don’t require user interaction i.e. user unaware
        let backgroundQueue = DispatchQueue(label: "background", qos: .background)
        
        // Unspecified- This represents the absence of QoS information
        let unspecifiedQueue = DispatchQueue(label: "unspecified", qos: .unspecified)
    
        // Priority Values - This value determines the priority at which the system schedules tasks for execution.
        // From high to low
        /**
         MainThread                                                                              .userInteractive
         DISPATCH_QUEUE_PRIORITY_HIGH                                   .userInititated
         DISPATCH_QUEUE_PRIORITY_DEFAULT                            .default
         DISPATCH_QUEUE_PRIORITY_LOW                                    .utility
         DISPATCH_QUEUE_PRIORITY_BACKGROUND                  .background
         */
        
        
        // MARK: - Attributes
        // It include the concurrent attribute to create a dispatch queue that executes tasks concurrently or
        // it has value of initiallyInactive which says queue is initially inactive.
        let attributesTestQueue = DispatchQueue(label: "Test", attributes: .initiallyInactive)
        /**
         .concurrent
         .InitiallyActive  - It will become active once active() is called
         */
        
        // MARK: - Auto Release Frequency
        // The frequency with which to autorelease objects created by the blocks that the queue schedules.
        let autoReleaseTestQueue = DispatchQueue(label: "Test", autoreleaseFrequency: .inherit)
        /**
         .inherit           - inherit auto release frequency from target
         .workItem      - configure auto release pool before execution of block and release object in that pool after the block finishes executing
         .never            - doesn't not setup autorelease pool around executed blocks. default value for global queues.
         */
        
        // MARK: - Target
        // The target queue on which to execute blocks. A dispatch queue’s priority is inherited from its target queue.
        let targetTestQueue = DispatchQueue(label: "Test", target: .main)
        /**
         .main          - main will run on the main thread. The main thread is used primarily for UI work. This queue has the highest priority.
         .global()      - primarily used for work that is not UI related.three priorities Low, Default & High. This queue has the second highest priority.
         nil               - nil is the lowest priority and will be lower than any global queue. It has no priority, it just needs to get done.
         */
    }
    
    func testWorkflow() {
        let test = QualityOfService()
        test.qosWorkflow()
    }
}
