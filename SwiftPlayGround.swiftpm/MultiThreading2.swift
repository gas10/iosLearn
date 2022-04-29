//
//  File.swift
//  SwiftPlayGround
//
//  Created by Gawade, Amar on 4/28/22.
//

/**
 https://manasaprema04.medium.com/multithreading-in-ios-part-2-3-fe0116ffee5
 DispatchWorkItem
 DispatchGroup
 DispatchBarrier
 DispatchSemaphore
 DispatchSources
 */

import Foundation

// DispatchWorkItem
class DispatchWorkItemTest {
    
    // Create Work Item, Perform & Execute, Cancel
    func testWorkflow() {
        // Create work item
        let workItem = DispatchWorkItem() {
            for index in 0...5 {
                MultiThreadingTest.log(String(index))
            }
        }
        
        // Invoke work item using perform
        DispatchQueue.global().sync {
            workItem.perform()
        }
        
        // Invoke work item using execute
        DispatchQueue.global().sync(execute: workItem)
        
        // Cancel work Item
        // If the task has not yet started on the queue, it will be removed.
        // If the task is currently executing, the isCancelled property will be set to true
        workItem.cancel()
    }
}

/**
 Dispatch Group
 Call enter() to manually notify the group that a task has started. You must balance out the number of enter() calls with the number of leave() calls else your app will crash.
 You call wait() to block the current thread while waiting for tasks completion. You can use wait(timeout:) to specify a timeout and bail out on waiting after a specified time.
 Instead of wait() or wait(timeout:) you notify the group that this work is done.
 At this point, you are guaranteed that all tasks have either completed or timed out. You then make a call back to the main queue to run your completion closure.

 */
class DispatchGroupTest {
    // Create group, enter, leave, wait/notify
    func testGroup() {
        let useWait = arc4random() % 2 == 0
        MultiThreadingTest.log("Starting long running task...")
        let group = DispatchGroup()
        for index in 0...5 {
            // Let group know that new task will be added
            group.enter()
            // Run Task in Background
            DispatchQueue.global().async {
                // Perform long task
                sleep(arc4random() % 4)
                MultiThreadingTest.log("Long running task at \(index) is done")
                // Let group know that task is finished
                group.leave()
            }
        }
        
        if useWait {
            // You call wait() to block the current thread while waiting for tasks completion.
            // You can use wait(timeout:) to specify a timeout and bail out on waiting after a specified time.
            group.wait()
            MultiThreadingTest.log("All Long running task are finished")
        } else {
            // if you don’t want to wait for the groups to finish, but instead want to run a function once all the tasks have completed,
            // use the notify function in place of the group.wait()
            group.notify(queue: DispatchQueue.main) {
                MultiThreadingTest.log("All Long running task are finished")
            }
        }
    }
    
    func testGroupWithWorkItem() {
        let group = DispatchGroup()
        let workItem = DispatchWorkItem() {
            for index in 0...5 {
                MultiThreadingTest.log("Running work item task at \(index)")
            }
        }
        
        // Create two global queue
        let aGlobalQueue = DispatchQueue.global()
        let anotherGlobalQueue = DispatchQueue.global()
        
        aGlobalQueue.async(group: group, execute: workItem)
        aGlobalQueue.async(group: group) {
            workItem.perform()
        }
        
        anotherGlobalQueue.async(group: group) {
            MultiThreadingTest.log("Within group of another queue")
        }
        
        group.notify(queue: DispatchQueue.main) {
            MultiThreadingTest.log("All work item task are finished")
        }
    }
    
    func testDelayedExecution() {
        // Add dispatch time
        let dispatchTime: DispatchTime = .init(uptimeNanoseconds: 1)
        DispatchQueue.global().asyncAfter(deadline: dispatchTime) {
            MultiThreadingTest.log("Execute task with delay")
        }
        
        // Add dispatch time interval to current time
        let additionalTime: DispatchTimeInterval = .seconds(2)
        DispatchQueue.global().asyncAfter(deadline: .now() + additionalTime) {
            MultiThreadingTest.log("Execute task with delay")
        }
        
        // Dispatch Time Interval - second, nano, micro, milli
        let timeSecond: DispatchTimeInterval = .seconds(2)
        let timeNanoSecond: DispatchTimeInterval = .nanoseconds(2)
        let timeMicroSecond: DispatchTimeInterval = .microseconds(2)
        let timeMilliSecond: DispatchTimeInterval = .milliseconds(2)
    }
    
    func testWorkflow() {
        testGroup()
        testGroupWithWorkItem()
    }
}

/**
 Dispatch Barrier
 Thread safe code can be called safely from multiple threads without causing any problem such as data corruption or app crash.
 When we use singleton or code that is not thread safe then we face problem like data corruption. We can avoid this issue by using dispatch barrier.
 */
class DispatchBarrierTest {
    func testWorkflow() {
        let concurrentQueue = DispatchQueue(label: "A Concurrent Queue", attributes: .concurrent)
        for index in 0...3 {
            concurrentQueue.async {
                MultiThreadingTest.log("Async \(index)")
            }
        }
        
        for index in 4...6 {
            concurrentQueue.async(flags: .barrier) {
                MultiThreadingTest.log("Barrier \(index)")
            }
        }
        
        for index in 7...10 {
            concurrentQueue.async {
                MultiThreadingTest.log("Async \(index)")
            }
        }
    }
}

/**
 
 Dispatch Semaphore

 In multithread, threads must wait for exclusive access to a resource. this is the one way to make threads wait and put them to sleep inside the kernel so that they no longer take any CPU time.
 It gives us the ability to control access to shared resource by multiple threads.
 A semaphore consist of a threads queue and a counter value (type Int).
 Threads queue is used by the semaphore to keep track on waiting threads in FIFO order.
 Counter value is used by the semaphore to decide if a thread should get access to a shared resource or not. The counter value changes when we call signal() or wait() functions.
 
 call wait() each time before using the shared resource. Here we are asking semaphore whether shared resource is available or not
 call signal() each time after using the shared resource. Signalling the semaphore that we are done interacting with the shared resource.
 
 Calling wait() -
 Decrement semaphore counter by 1.
 If the resulting value is less than zero, thread is blocked and will go into waiting state.
 If the resulting value is equal or bigger than zero, code will get executed without waiting.
 
 Calling signal() -
 Increment semaphore counter by 1.
 If the previous value was less than zero, this function unblock the thread currently waiting in the thread queue.
 If the previous value is equal or bigger than zero, it means thread queue is empty that means no one is waiting.
 
 never run semaphore wait() function on main thread as it will freeze your app.
 Wait() function allows us to specify a timeout. Once timeout reached, wait will finish regardless semaphore count value.
 
*/
class DispatchSemaphoreTest {
    // Each time we get different output
    func testConcurrentQueue() {
        let queue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
        var sharedResource = [Int]()
        
        queue.async {
            for index in 0...5 {
                sharedResource.append(index)
            }
        }
        
        queue.async {
            for index in 6...10 {
                sharedResource.append(index)
            }
        }
        
        queue.async {
            for index in 11...15 {
                sharedResource.append(index)
            }
        }
        
        MultiThreadingTest.log("Resources:\(sharedResource)")
    }
    
    // Using semaphore provides us consistent output.
    func testSemaphore() {
        let queue = DispatchQueue(label: "dispatchSemaphore", attributes: .concurrent)
        let semaphore = DispatchSemaphore(value: 0)
        var sharedResource = [Int]()
        
        queue.async {
            for index in 0...5 {
                sharedResource.append(index)
            }
            semaphore.signal()
        }
        semaphore.wait()
        
        queue.async {
            for index in 6...10 {
                sharedResource.append(index)
            }
            semaphore.signal()
        }
        semaphore.wait()
        
        queue.async {
            for index in 11...15 {
                sharedResource.append(index)
            }
            semaphore.signal()
        }
        semaphore.wait()
        
        MultiThreadingTest.log("Resources:\(sharedResource)")
    }
    
    func testWorkflow() {
        testConcurrentQueue()
        testSemaphore()
    }
}

/**
 Dispatch Source
 The DispatchSource contains a series of objects that are capable of monitoring OS-related events.
 Dispatch Sources are a convenient way to handle system level asynchronous events like kernel signals or system, file and socket related events using event handlers.
 
 Dispatch sources can be used to monitor the following types of system events:
    . Timer Dispatch Sources (DispatchSourceTimer): Used to generate periodic notifications.
    . Signal Dispatch Sources (DispatchSourceSignal): Used to handle UNIX signals.
    . Memory Dispatch Sources (DispatchSourceMemoryPressure): Used to register for notifications related to the memory usage status .
    . Descriptor Dispatch Sources (DispatchSourceFileSystemObject, DispatchSourceRead, DispatchSourceWrite): Descriptor sources sends notifications related to a various file- and socket-based operations, such as:
         1. signal when data is available for reading
         2. signal when it is possible to write data
         3. files delete, move, or rename
         4. files meta information change
         This enables us to easily build developer tools that have “live editing” features.
    . Process dispatch sources (DispatchSourceProcess): Used to monitor external process for some events related to their execution state. Process-related events, such as
         1. a process exits
         2. a process issues a fork or exec type of call
         3. a signal is delivered to the process.

 */
class DispatchSourcesTest {
    /**
     Timer runs on main thread which needs main run loop to execute. If you want to execute Timer on background thread,
     you can’t because Timer requires an active run loop which is not always readily available on background queues.
     In this situation DispatchSourceTimer could be used. A dispatch timer source, fires an event when the time interval has been completed, which then fires a pre-set callback all on the same queue.
     */
    func dispatchSourceTimerTest() {
        var count = 0
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now(), repeating: 1)
        timer.setEventHandler(handler: {
            if count == 4 {
                timer.suspend()
            }
            count = count + 1
            MultiThreadingTest.log("isMainThread: \(Thread.isMainThread)")
        })
        timer.resume()
    }
    
    // File logging in Swift (DispatchSourceFileSystemObject, DispatchSourceRead, DispatchSourceWrite) use case:
    // Every app will print debug logs to the developer console and its good practice to save these logs somewhere.
    // OSLog automatically saves your logs to the system but developer can also save these logs somewhere.
    func descriptorDispatchSourcesTest() {
        let fileHandle: FileHandle = try! FileHandle(forReadingFrom: URL(string: "This is data within file")!)
        
        let source: DispatchSourceFileSystemObject = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileHandle.fileDescriptor,
            eventMask: .extend,
            queue: DispatchQueue.main)
        
        source.setEventHandler(handler: {
            // Logic to process DispatchSource.FileSystemEvent
        })
        
        source.setCancelHandler(handler: {
            // Close fileHandle
        })
        
        fileHandle.seekToEndOfFile()
        
        source.resume()
    }
    
    func testWorkflow() {
        dispatchSourceTimerTest()
        descriptorDispatchSourcesTest()
    }
}
