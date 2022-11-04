//
//  Units.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 27.09.2022.
//

import Foundation

public struct Units {
    
    public let bytes: Int64
    
    public var kilobytes: Double {
        return Double(bytes) / 1_024
    }
    
    public var megabytes: Double {
        return kilobytes / 1_024
    }
    
    public var gigabytes: Double {
        return megabytes / 1_024
    }
    
    public init(bytes: Int64) {
        self.bytes = bytes
    }
    
    public func getReadableUnit() -> String {
        
        switch bytes {
        case 0..<1_024:
            return "\(bytes) " + "бт".localized
        case 1_024..<(1_024 * 1_024):
            return "\(String(format: "%.2f", kilobytes)) " + "кб".localized
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "\(String(format: "%.2f", megabytes)) " + "мб".localized
        case (1_024 * 1_024 * 1_024)...Int64.max:
            return "\(String(format: "%.2f", gigabytes)) " + "гб".localized
        default:
            return "\(bytes) bytes"
        }
    }
    
    public func getDouble() -> Double {
        
        switch bytes {
        case 0..<1_024:
            return ("\(bytes)" as NSString).doubleValue
        case 1_024..<(1_024 * 1_024):
            return ("\(String(format: "%.1f", kilobytes))" as NSString).doubleValue
        case 1_024..<(1_024 * 1_024 * 1_024):
            return ("\(String(format: "%.1f", megabytes))" as NSString).doubleValue
        case (1_024 * 1_024 * 1_024)...Int64.max:
            return ("\(String(format: "%.1f", gigabytes))" as NSString).doubleValue
        default:
            return ("\(bytes)" as NSString).doubleValue
        }
    }
}
