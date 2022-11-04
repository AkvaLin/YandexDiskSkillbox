//
//  UserDefaultsExtension.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 15.09.2022.
//

import Foundation

extension UserDefaults {
    private enum UserDefaultsKeys: String {
        case hasOnboarded
        case token
        case freeSpace
        case usedSpace
        case totalSpace
    }
    
    var hasOnboarded: Bool {
        get {
            bool(forKey: UserDefaultsKeys.hasOnboarded.rawValue)
        }
        
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.hasOnboarded.rawValue)
        }
    }
    
    var token: String? {
        get {
            string(forKey: UserDefaultsKeys.token.rawValue)
        }
        
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.token.rawValue)
        }
    }
    
    var freeSpace: Double? {
        get {
            double(forKey: UserDefaultsKeys.freeSpace.rawValue)
        }
        
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.freeSpace.rawValue)
        }
    }
    
    var usedSpace: Double? {
        get {
            double(forKey: UserDefaultsKeys.usedSpace.rawValue)
        }
        
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.usedSpace.rawValue)
        }
    }
    
    var totalSpace: Int? {
        get {
            integer(forKey: UserDefaultsKeys.totalSpace.rawValue)
        }
        
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.totalSpace.rawValue)
        }
    }
}
