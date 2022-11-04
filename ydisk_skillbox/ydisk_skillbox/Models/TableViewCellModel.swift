//
//  TableViewCellViewModel.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 26.09.2022.
//

import Foundation

struct TableViewCellModel {
    let preview: Data?
    var name: String
    let date: String?
    let time: String?
    let size: Int?
    let type: String
    let mediaType: String?
    let mimeType: String?
    let path: String
}
