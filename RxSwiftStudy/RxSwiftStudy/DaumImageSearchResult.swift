//
//  DaumImageSearchResult.swift
//  DaumAPI
//
//  Created by 김문옥 on 28/08/2019.
//  Copyright © 2019 ByoungHoon. All rights reserved.
//

import Foundation

// MARK: - Welcome
class DaumImageSearchResult: Codable {
    let meta: Meta
    let documents: [Document]
    
    init(meta: Meta, documents: [Document]) {
        self.meta = meta
        self.documents = documents
    }
}

// MARK: - Document
class Document: Codable {
    let title, contents: String
    let url: String
    let blogname: String
    let thumbnail: String
    let datetime: String
    
    init(title: String, contents: String, url: String, blogname: String, thumbnail: String, datetime: String) {
        self.title = title
        self.contents = contents
        self.url = url
        self.blogname = blogname
        self.thumbnail = thumbnail
        self.datetime = datetime
    }
}

// MARK: - Meta
class Meta: Codable {
    let totalCount, pageableCount: Int
    let isEnd: Bool
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case pageableCount = "pageable_count"
        case isEnd = "is_end"
    }
    
    init(totalCount: Int, pageableCount: Int, isEnd: Bool) {
        self.totalCount = totalCount
        self.pageableCount = pageableCount
        self.isEnd = isEnd
    }
}
