//
//  Repository.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 01.12.2024.
//

import Foundation

struct Repository {
    let id: Int
    var name: String
    var details: String
    var userImageUrl: String
    var isFavorite: Bool = false
}
