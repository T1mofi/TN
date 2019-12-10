//
//  String+Extentions.swift
//  SerialChat
//
//  Created by Timofei Sikorski on 12/6/19.
//  Copyright © 2019 SikorskiIT. All rights reserved.
//

import Foundation

extension String {
    func getBytesRepresentation() -> [UInt8] {
        var bytes: [UInt8] = []
        var index = self.startIndex

        while let next = self.index(index, offsetBy: 8, limitedBy: self.endIndex) {
            let range = index..<next
            let asciiCode = UInt8(self[range], radix: 2)!
            bytes.append(asciiCode)
            index = next
        }
        
        return bytes
    }
    
    func getAdress() -> UInt8 {
        let startIndex = self.startIndex
        guard let endIndex = self.index(startIndex, offsetBy: 8, limitedBy: self.endIndex) else { return 0 }
        let range = startIndex..<endIndex
        let substring = String(self[range])
        let adress = UInt8(substring, radix: 2)!
        
        return adress
    }
    
    func getCheckSum() -> UInt8 {
        let endIndex = self.endIndex
        guard let startIndex = self.index(endIndex, offsetBy: -8, limitedBy: self.startIndex) else { return 0 }
        let range = startIndex..<endIndex
        let substring = String(self[range])
        let checkSum = UInt8(substring, radix: 2)!
        
        return checkSum
    }
    
    func getAsciiStringRepresentation() -> String {
        let bytes = self.getBytesRepresentation()
        
        var asciiString = ""
        
        for byte in bytes {
            asciiString += String(UnicodeScalar(byte))
        }
        
        return asciiString
    }
}

extension String {
    var stuffed: String {
        return self.replacingOccurrences(of: "0000111", with: "00001111")
    }
}

extension String {
    var unstuffed: String {
        return self.replacingOccurrences(of: "00001111", with: "0000111")
    }
}
