//
//  File.swift
//  SwiftPlayGround
//
//  Created by Gawade, Amar on 4/28/22.
//

import Foundation
class FileManagerUtil {
    let defaultFileType = "txt"
    func createOrUpdateFile(fileName: String, fileType: String?, text: String) {
        let fileURL = getFile(fileName: fileName, fileType: fileType ?? defaultFileType)
        // Delete File if exists
        deleteFile(filePath: fileURL.path)
        
        // Write to file
        do {
            try text.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print (error)
        }
    }
    
    func getFile(fileName: String, fileType: String) -> URL {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = URL(fileURLWithPath: fileName, relativeTo: directoryURL).appendingPathExtension(fileType)
        print("File path \(fileURL.path)")
        return fileURL
    }
    
    func deleteFile(filePath: String) {
        guard FileManager.default.fileExists(atPath: filePath) else { return }
        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch let error {
            print("error occurred, here are the details:\n \(error)")
        }
    }
}
