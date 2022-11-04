//
//  FilesDataModel.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 17.09.2022.
//

import Foundation

struct FilesData: Decodable {
    let items: [FileData]
    let type: String?
    let limit: Int
    let offset: Int?
    let total: Int?
}

struct FileData: Decodable {
    let publicKey: String?
    let publicUrl: String?
    let name: String
    let preview: String?
    let created: String
    let modified: String
    let path: String
    let md5: String?
    let type: String
    let mediaType: String?
    let mimeType: String?
    let size: Int?
    
    enum CodingKeys: String, CodingKey {
        case publicKey = "public_key"
        case publicUrl = "public_url"
        case mediaType = "media_type"
        case mimeType = "mime_type"
        
        case name
        case preview
        case created
        case modified
        case path
        case md5
        case type
        case size
    }
}

struct AllFilesData: Decodable {
    let publicKey: String?
    let embedded: FilesData
    let name: String
    let created: String
    let customProperties: [String: String]?
    let publicUrl: String?
    let modified: String
    let path: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case publicKey = "public_key"
        case embedded = "_embedded"
        case customProperties = "custom_properties"
        case publicUrl = "public_url"
        
        case name
        case created
        case modified
        case path
        case type
    }
}
