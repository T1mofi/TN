//
//  CRCService.swift
//  SerialChat
//
//  Created by Timofei Sikorski on 12/20/19.
//  Copyright © 2019 SikorskiIT. All rights reserved.
//

import Foundation

class CRCService {
    static let polynomial = "10000011"
    
    static func calculateCRC(with binaryString: String) -> String {
        var remainder = binaryString
        
        while true {
            _ = remainder.removeFirstZeros()
            
            let firstByte = remainder.removeFirstEight()
            remainder = firstByte.xoredWithPolynomial + remainder
            
            if remainder.count == 8 {
                //TODO: should write >=
                if UInt8(remainder, radix: 2)! > 131 {
                    remainder = remainder.xoredWithPolynomial
                    break
                } else {
                    break
                }
            }
            
            
        }
        
        return remainder
    }
}
