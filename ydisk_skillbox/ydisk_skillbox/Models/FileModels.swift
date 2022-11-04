//
//  FileModel.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 04.10.2022.
//

import Foundation

struct FileModel: Decodable {
    let href: String
}

struct PublishedFileModel: Decodable {
    let publicUrl: String
    
    enum CodingKeys: String, CodingKey {
        case publicUrl = "public_url"
    }
}
