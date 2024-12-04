//
//  ReposListInteractorTests.swift
//  GitReposAppTests
//
//  Created by Дмитрий Мартьянов on 04.12.2024.
//

import XCTest
import Combine
import RealmSwift
@testable import GitReposApp


final class ReposListInteractorTests: XCTestCase {
    
    var mockRemoteManager: MockRemoteManager!
    var mockStorageManager: MockStorageManager!
    
    var sut: ReposListInteractorImpl!

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockRemoteManager = MockRemoteManager()
        mockStorageManager = MockStorageManager()
        sut = ReposListInteractorImpl(mockRemoteManager, mockStorageManager)
        cancellables = .init()
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        mockStorageManager = nil
        mockRemoteManager = nil
        super.tearDown()
    }

    func testInteractor_shouldSwitchFilterSuccessfully() {
        let expectedFilter = ReposFilter.lastUpdated
        sut.switchFilter(expectedFilter)
        XCTAssertEqual(expectedFilter, sut.currentFilter)
        XCTAssertEqual(sut.currentPage, 0)
    }

    func testInteractor_fetchingRepos_shouldMergeResponsesSuccessfully() {
        let expectation = self.expectation(description: #function)
        let remoteResponse = [
            RemoteRepository(id: 1, full_name: "Repo", description: "", owner: .init(avatar_url: "")),
            RemoteRepository(id: 2, full_name: "Repo", description: "", owner: .init(avatar_url: "")),
            RemoteRepository(id: 3, full_name: "Repo", description: "", owner: .init(avatar_url: "")),
            RemoteRepository(id: 4, full_name: "Repo", description: "", owner: .init(avatar_url: "")),
            RemoteRepository(id: 5, full_name: "Repo", description: "", owner: .init(avatar_url: ""))
        ]
        mockRemoteManager.response = remoteResponse

        let favoriteId = 2
        let deletedIds = [3,4]
        let localResponse = StorageResponse()
        localResponse.favoriteIds = MutableSet<Int>()
        localResponse.favoriteIds.insert(objectsIn: [favoriteId])
        localResponse.deletedIds = MutableSet<Int>()
        localResponse.deletedIds.insert(objectsIn: deletedIds)
        mockStorageManager.response = localResponse
        sut.nextRepos().sink(
            receiveCompletion: {
                if case .failure(let error) = $0 {
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                }
            },
            receiveValue: { [unowned self] in
                XCTAssertEqual($0.count, remoteResponse.count - deletedIds.count)
                XCTAssertTrue($0[1].isFavorite)
                XCTAssertEqual(remoteResponse.last?.id, $0.last?.id)
                XCTAssertEqual(sut.currentPage, 1)
                expectation.fulfill()
            }
        ).store(in: &cancellables)
        waitForExpectations(timeout: 2.0)
    }

    func testInteractor_fetchingRepos_shouldFetchRemoteError() {
        let expectation = self.expectation(description: #function)
        mockRemoteManager.error = MockError.mock
        let localResponse = StorageResponse()
        mockStorageManager.response = localResponse

        sut.nextRepos().sink(
            receiveCompletion: {
                if case .failure(let error) = $0 {
                    if let _ = error as? MockError {
                        XCTAssertTrue(true)
                    } else {
                        XCTFail("Error has a wrong type")
                    }
                    expectation.fulfill()
                }
            },
            receiveValue: { _ in
                XCTFail("Value shouldn't have been recieved")
                expectation.fulfill()
            }
        ).store(in: &cancellables)

        waitForExpectations(timeout: 2.0)
    }

    func testInteractor_fetchingRepos_shouldFetchStorageError() {
        let expectation = self.expectation(description: #function)
        mockRemoteManager.response = []
        mockStorageManager.error = MockError.mock

        sut.nextRepos().sink(
            receiveCompletion: {
                if case .failure(let error) = $0 {
                    if let _ = error as? MockError {
                        XCTAssertTrue(true)
                    } else {
                        XCTFail("Error has a wrong type")
                    }
                    expectation.fulfill()
                }
            },
            receiveValue: { _ in
                XCTFail("Value shouldn't have been recieved")
                expectation.fulfill()
            }
        ).store(in: &cancellables)

        waitForExpectations(timeout: 2.0)
    }

    func testInteractor_savingFavorite_shouldSaveSuccessfully() {
        let expectation = self.expectation(description: #function)
        sut.saveFavorite(withId: 1).sink(
            receiveCompletion: {
                if case .failure(let error) = $0 {
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                }
            },
            receiveValue: { [unowned self] in
                XCTAssertEqual(mockStorageManager.response.favoriteIds.count, 1)
                XCTAssertTrue(mockStorageManager.response.favoriteIds.contains(1))
                expectation.fulfill()
            }
        ).store(in: &cancellables)
        waitForExpectations(timeout: 2.0)
    }

    func testInteractor_savingFavorite_shouldFetchError() {
        let expectation = self.expectation(description: #function)
        mockStorageManager.error = MockError.mock
        sut.saveFavorite(withId: 1).sink(
            receiveCompletion: {
                if case .failure(let error) = $0 {
                    if let _ = error as? MockError {
                        XCTAssertTrue(true)
                    } else {
                        XCTFail("Error has a wrong type")
                    }
                    expectation.fulfill()
                }
            },
            receiveValue: {
                XCTFail("Value shouldn't have been recieved")
                expectation.fulfill()
            }
        ).store(in: &cancellables)
        waitForExpectations(timeout: 2.0)
    }

    func testInteractor_removingFavorite_shouldRemoveSuccessfully() {
        let expectation = self.expectation(description: #function)
        mockStorageManager.response.favoriteIds = MutableSet<Int>()
        mockStorageManager.response.favoriteIds.insert(objectsIn: [1,2])
        sut.removeFavorite(withId: 1).sink(
            receiveCompletion: {
                if case .failure(let error) = $0 {
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                }
            },
            receiveValue: { [unowned self] in
                XCTAssertEqual(mockStorageManager.response.favoriteIds.count, 1)
                XCTAssertTrue(mockStorageManager.response.favoriteIds.contains(2))
                expectation.fulfill()
            }
        ).store(in: &cancellables)
        waitForExpectations(timeout: 2.0)
    }

    func testInteractor_removingFavorite_shouldFetchError() {
        let expectation = self.expectation(description: #function)
        mockStorageManager.error = MockError.mock
        sut.removeFavorite(withId: 1).sink(
            receiveCompletion: {
                if case .failure(let error) = $0 {
                    if let _ = error as? MockError {
                        XCTAssertTrue(true)
                    } else {
                        XCTFail("Error has a wrong type")
                    }
                    expectation.fulfill()
                }
            },
            receiveValue: {
                XCTFail("Value shouldn't have been recieved")
                expectation.fulfill()
            }
        ).store(in: &cancellables)
        waitForExpectations(timeout: 2.0)
    }

    func testInteractor_settingItemDeleted_shouldSetSuccessfully() {
        let expectation = self.expectation(description: #function)
        mockStorageManager.response.favoriteIds.insert(1)
        sut.setDeleted(withId: 1).sink(
            receiveCompletion: {
                if case .failure(let error) = $0 {
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                }
            },
            receiveValue: { [unowned self] in
                
                XCTAssertEqual(mockStorageManager.response.favoriteIds.count, 0)
                XCTAssertEqual(mockStorageManager.response.deletedIds.count, 1)
                XCTAssertTrue(mockStorageManager.response.deletedIds.contains(1))
                expectation.fulfill()
            }
        ).store(in: &cancellables)
        waitForExpectations(timeout: 2.0)
    }

    func testInteractor_settingItemDeleted_shouldFetchError() {
        let expectation = self.expectation(description: #function)
        mockStorageManager.error = MockError.mock
        sut.setDeleted(withId: 1).sink(
            receiveCompletion: {
                if case .failure(let error) = $0 {
                    if let _ = error as? MockError {
                        XCTAssertTrue(true)
                    } else {
                        XCTFail("Error has a wrong type")
                    }
                    expectation.fulfill()
                }
            },
            receiveValue: {
                XCTFail("Value shouldn't have been recieved")
                expectation.fulfill()
            }
        ).store(in: &cancellables)
        waitForExpectations(timeout: 2.0)
    }
}
