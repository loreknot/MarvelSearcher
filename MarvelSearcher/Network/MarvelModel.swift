//
//  MarvelModel.swift
//  MarvelSearcher
//
//  Created by subError on 4/25/24.
//

import Foundation

struct HeroData: Codable {
    var data: HeroResult
}

struct HeroResult: Codable {
    var results: [HeroInfo]
}

struct HeroInfo: Codable {
    var thumbnail: HeroThumbnail
    var name: String?
    var description: String?
    
    func toDisplayInfo() -> HeroDisplayInfo {
        return HeroDisplayInfo(imageUrl: thumbnail.fullPath, name: name, description: description)
    }
}

struct HeroThumbnail: Codable {
    var path: String?
    var fileExtension: String?
    
    var fullPath: String? {
        guard let path = path, let fileExtension = fileExtension else { return nil }
        return "\(path).\(fileExtension)"
    }
    
    enum CodingKeys: String, CodingKey {
        case path
        case fileExtension = "extension"
    }
}

struct HeroDisplayInfo {
    var imageUrl: String?
    var name: String?
    var description: String?
}
