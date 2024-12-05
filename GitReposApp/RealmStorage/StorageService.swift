//
//  StorageService.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 01.12.2024.
//

import Foundation
import RealmSwift

protocol StorageService {
    func fetch<T: Object>(_ type: T.Type) -> Result<[T], Error>
    func saveOrUpdate<T: Object>(_ object: T, _ additionalTransactions: (()  -> ())?) -> Result<Void, Error>
}


