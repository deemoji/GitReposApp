//
//  ReposListItem.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 02.12.2024.
//

import Foundation

struct ReposListItem: Hashable {
    let id: Int
    let name: String
    let details: String
    let iconUrl: String
    let isFavorite: Bool
    
}

