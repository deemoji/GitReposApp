//
//  RemoteResponse.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 30.11.2024.
//

import Foundation

struct RemoteResponse: Decodable {
    let items: [RemoteRepository]
}

struct RemoteRepository: Equatable, Decodable {
    struct Owner: Equatable, Decodable {
        let avatar_url: String
    }
    
    let id: Int
    let full_name: String
    let description: String?
    let owner: Owner
    
    static func == (lhs: RemoteRepository, rhs: RemoteRepository) -> Bool {
        return lhs.id == rhs.id &&
        lhs.full_name == rhs.full_name &&
        lhs.description == rhs.description &&
        lhs.owner == rhs.owner
    }

}
