//
//  String+Extentions.swift
//  SerialChat
//
//  Created by Timofei Sikorski on 12/6/19.
//  Copyright © 2019 SikorskiIT. All rights reserved.
//

import Foundation

// MARK: - CRC String extentions
extension String {
    mutating func removeFirstZeros() -> String {
        while true {
            guard self.count > 8 else {
                return self
            }
            
            if self[startIndex] == "0" {
                self.removeFirst()
            } else {
                return self
            }
        }
    }
    
    // TODO: Can return string without removing smt
    mutating func removeFirstEight() -> String {
        guard let endIndex = self.index(startIndex, offsetBy: 8, limitedBy: self.endIndex) else { return self }
        let substring = String(self[..<endIndex])
        self.removeFirst(8)
        
        return substring
    }
    
    mutating func removeFirstK(_ k: Int) -> String {
        guard let endIndex = self.index(startIndex, offsetBy: k, limitedBy: self.endIndex) else { return self }
        let substring = String(self[..<endIndex])
        self.removeFirst(k)
        
        return substring
    }
    
    var xoredWithPolynomial: String {
        let byte = UInt8(self, radix: 2)!
        let polynomial = UInt8(131)
        
        let xored = byte ^ polynomial
        
        return xored.binaryRepresentation
    }
    
    //TODO: it shold not be 4
    mutating func makeRandomError() {
        let errorIndex = Int.random(in: 25..<self.count - 8)
        
        var startingString = self.removeFirstK(errorIndex)
        
        if startingString.removeFirst() == "0" {
            self = startingString + "1" + self
        } else {
            self = startingString + "0" + self
        }
    }
    
    mutating func swapChar(at index: Int) {
        let stringIndex = self.index(self.startIndex, offsetBy: index)
        
        if self.remove(at: stringIndex) == "0" {
            self.insert("1", at: stringIndex)
        } else {
            self.insert("0", at: stringIndex)
        }
    }
    
    mutating func fixError(checkSum: String) {
        
        var currentIndex = 0
        for char in self {
            self.swapChar(at: currentIndex)
            let crc = CRCService.calculateCRC(for: self)
            
            if crc == checkSum {
                return
            } else {
                self.swapChar(at: currentIndex)
            }
            
            currentIndex += 1
        }
    }
}

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
