//
//  File.swift
//  SwiftPlayGround
//
//  Created by Gawade, Amar on 4/28/22.
//

import Foundation
class CodeRunner {
    func invoke() -> String {
        let test = MultiThreadingTest()
        test.invokeThreading1Test()
        test.invokeThreading2Test()
        test.invokeThreading3Test()
        return "Success"
    }
}

class MultiThreadingTest {
    static var output = ""
    static let canPrint = true
    
    func invokeThreading1Test() {
        // Thread basics and creation
        ManualThreadTest().testWorkflow()
        
        // Main, Global, Private
        GCDTest().testWorkflow()
        
        // qos properties
        QualityOfService().testWorkflow()
        
        // Print or Write output
        writeLogToFile()
    }
    
    func invokeThreading2Test() {
        // Dispatch Work Item
        DispatchWorkItemTest().testWorkflow()

        // Dispatch Group
        DispatchGroupTest().testWorkflow()

        // Dispatch Barrier
        DispatchBarrierTest().testWorkflow()
        
        // Dispatch Semaphore
        DispatchSemaphoreTest().testWorkflow()
        
        // Dispatch Source
        DispatchSourcesTest().testWorkflow()
        
        // Print or Write output
        writeLogToFile()
    }
    
    func invokeThreading3Test() {
        // Block Operation
        BlockOperationTest().testWorkflow()
        
        // Custom Operation
        CustomOperationTest().testWorkflow()
        
        // Opeartion Queue
        OperationQueueTest().testWorkflow()
    }
    
    func writeLogToFile() {
        // Write to file
        let fileUtil = FileManagerUtil()
        fileUtil.createOrUpdateFile(fileName: "Output", fileType: "txt", text: MultiThreadingTest.output)
        MultiThreadingTest.output = ""
    }
    
    static func log(_ text: String) {
        if MultiThreadingTest.canPrint {
            print(text)
        } else {
            output += text + "\n"
        }
    }
}
