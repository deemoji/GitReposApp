//
//  TestObject.swift
//  GitReposAppTests
//
//  Created by Дмитрий Мартьянов on 01.12.2024.
//

import Foundation
import RealmSwift

class TestObject: Object {
        @Persisted(primaryKey: true) var id: Int
        @Persisted var name: String
        
        convenience init(id: Int, name: String) {
            self.init()
            self.id = id
            self.name = name
        }
}
