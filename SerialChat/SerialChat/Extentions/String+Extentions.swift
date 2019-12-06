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
}

extension String {
    var stuffed: String {
        let stuffedString = self.replacingOccurrences(of: "0000111", with: "00001111")

        let zerosString = String(repeating: "0", count: (8 - stuffedString.count % 8))
        
        return stuffedString + zerosString
    }
}

extension String {
    var unstuffed: String {
        return self.replacingOccurrences(of: "00001111", with: "0000111")
    }
}
