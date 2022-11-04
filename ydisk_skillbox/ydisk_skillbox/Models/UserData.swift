//
//  ProfileDataModel.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 06.09.2022.
//

import Foundation

struct UserData: Decodable {
    let maxFileSize: Int
    let paidMaxFileSize: Int
    let totalSpace: Int
    let trashSize: Int
    let isPaid: Bool
    let usedSpace: Int
    let systemFolders: [String: String]
    let user: [String: String]
    let unlimitedAutouploadEnabled: Bool
    let revision: Int
    
    enum CodingKeys: String, CodingKey {
        case maxFileSize = "max_file_size"
        case paidMaxFileSize = "paid_max_file_size"
        case totalSpace = "total_space"
        case trashSize = "trash_size"
        case isPaid = "is_paid"
        case usedSpace = "used_space"
        case systemFolders = "system_folders"
        case user = "user"
        case unlimitedAutouploadEnabled = "unlimited_autoupload_enabled"
        case revision = "revision"
    }
}
