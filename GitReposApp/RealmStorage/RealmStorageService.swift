//
//  RealmStorageService.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 03.12.2024.
//

import Foundation
import RealmSwift

enum RealmStorageError: Error {
    case objectNotFound
    case initializationFailed
}

final class RealmStorageService: StorageService {
    
    private let configuration: Realm.Configuration
    
    init(configuration: Realm.Configuration = .defaultConfiguration) {
        self.configuration = configuration
    }
    
    private var realm: Realm? {
        do {
            return try Realm(configuration: configuration)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func fetch<T>(_ type: T.Type) -> Result<[T], Error> where T: Object {
        guard let realm = realm else {
            return .failure(RealmStorageError.initializationFailed)
        }
        let objects = realm.objects(T.self).map { $0 }
        return .success(Array(objects))
    }
    
    func saveOrUpdate<T>(_ object: T, _ additionalTransactions: (()  -> ())?) -> Result<Void, Error> where T: Object {
        guard let realm = realm else {
            return .failure(RealmStorageError.initializationFailed)
        }
        do {
            try realm.write {
                additionalTransactions?()
                realm.add(object, update: .modified)
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
