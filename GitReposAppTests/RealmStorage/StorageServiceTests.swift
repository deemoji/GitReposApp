//
//  StorageServiceTests.swift
//  GitReposAppTests
//
//  Created by Дмитрий Мартьянов on 01.12.2024.
//

import XCTest
import RealmSwift
@testable import GitReposApp

final class StorageServiceTests: XCTestCase {

    var service: StorageService!
    var testRealm: Realm!
    
    override func setUpWithError() throws {
            try super.setUpWithError()

            let configuration = Realm.Configuration(
                inMemoryIdentifier: "TestRealm",
                schemaVersion: 1,
                deleteRealmIfMigrationNeeded: true
            )
            testRealm = try Realm(configuration: configuration)
            service = RealmStorageService(configuration: configuration)
        }

        override func tearDownWithError() throws {
            try testRealm.write {
                testRealm.deleteAll()
            }
            testRealm = nil
            service = nil
            try super.tearDownWithError()
        }

    func testStorage_ShouldSaveOrUpdateSuccess() {
        let object = TestObject(id: 1, name: "Test Name")
        
        let result = service.saveOrUpdate(object)
        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure(let error):
            XCTFail("Save failed with error: \(error)")
        }

        
        let storedObject = testRealm.object(ofType: TestObject.self, forPrimaryKey: 1)
        XCTAssertNotNil(storedObject)
        XCTAssertEqual(storedObject?.name, "Test Name")
    }

    func testStorage_ShouldSaveOrUpdateOverwrite() {
        let object = TestObject(id: 1, name: "Test Name")
        try! testRealm.write {
            testRealm.add(object)
        }
        
        let updatedObject = TestObject(id: 1, name: "Updated Name")
        let result = service.saveOrUpdate(updatedObject)
        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure(let error):
            XCTFail("Save failed with error: \(error)")
        }
        
        let storedObject = testRealm.object(ofType: TestObject.self, forPrimaryKey: 1)
        XCTAssertEqual(storedObject?.name, updatedObject.name)
    }

    func testStorage_ShouldFetchSuccess() {
        let object = TestObject(id: 1, name: "Test Name")
        try! testRealm.write {
            testRealm.add(object)
        }
        
        let result = service.fetch(TestObject.self)
        switch result {
        case .success(let objects):
            XCTAssertEqual(objects.count, 1)
            XCTAssertEqual(objects.first?.name, "Test Name")
        case .failure:
            XCTFail("Fetching should succeed")
        }
    }

}
