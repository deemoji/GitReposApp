//
//  StorageResponse.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 01.12.2024.
//

import Foundation
import RealmSwift

final class StorageResponse: Object {
    @Persisted(primaryKey: true) var id: Int = 1
    var favoriteIds: MutableSet<Int> = .init()
    var deletedIds: MutableSet<Int> = .init()
}

final class LocalRepository: Object {
    @Persisted(primaryKey: true) var id: Int = 0
    @Persisted var name: String = ""
    @Persisted var details: String = ""
    @Persisted var userImageUrl: String = ""
    
    convenience init(id: Int, name: String, details: String, userImageUrl: String) {
        self.init()
        self.id = id
        self.name = name
        self.details = details
        self.userImageUrl = userImageUrl
    }
}
