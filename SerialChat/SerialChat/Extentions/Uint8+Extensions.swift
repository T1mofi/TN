//
//  Uint8+Extensions.swift
//  SerialChat
//
//  Created by Timofei Sikorski on 12/6/19.
//  Copyright © 2019 SikorskiIT. All rights reserved.
//

import Foundation

extension UInt8 {
    var binaryRepresentation: String {
        let binaryString = String(self, radix: 2)
    
        let zerosString = String(repeating: "0", count: (8 - binaryString.count))

        return zerosString + binaryString
    }
}
