//
//  Photos.swift
//  TestAppBalinaUIKit
//
//  Created by Alexandr Filovets on 24.10.24.
//

import Foundation

struct Photos: Decodable {
    let content: [Content]
    let page: Int
    let pageSize: Int
    let totalElements: Int
    let totalPages: Int
}
