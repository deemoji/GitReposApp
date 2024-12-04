//
//  ReposFilter.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 01.12.2024.
//

import Foundation

enum ReposFilter: String, CaseIterable {
    case mostStars = "Most Stars"
    case lastUpdated = "Last Updated"
    case fewestStars = "Fewest Stars"
}
