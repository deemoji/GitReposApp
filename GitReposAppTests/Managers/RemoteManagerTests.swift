//
//  RemoteManagerTests.swift
//  GitReposAppTests
//
//  Created by Дмитрий Мартьянов on 30.11.2024.
//

import Foundation
import XCTest
import Combine
@testable import GitReposApp

final class RemoteManagerTests: XCTestCase {
    
    var sut: RemoteManager!
    var mockNetwork: MockNetworkService!
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockNetwork = MockNetworkService()
        sut = GithubRemoteManager(network: mockNetwork)
        cancellables = .init()
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        mockNetwork = nil
        super.tearDown()
    }
    
    func testRemoteManager_FetchReposShouldSuccess() {
        let expectedRepositories = [
            RemoteRepository(id: 1, full_name: "First", description: "", owner: RemoteRepository.Owner(avatar_url: "url")),
            RemoteRepository(id: 2, full_name: "Second", description: "", owner: RemoteRepository.Owner(avatar_url: "url"))]
        let mockResponse = RemoteResponse(items: expectedRepositories)
        mockNetwork.fetchResponse = mockResponse
        
        let expectation = XCTestExpectation(description: #function)
        
        sut.repos(query: "swift", page: 1, filter: .mostStars)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected success, got failure")
                }
            }, receiveValue: { repositories in
                XCTAssertEqual(repositories, expectedRepositories)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRemoteManager_FetchReposShouldFail() {
        let expectation = XCTestExpectation(description: #function)
        let mockError = URLError(.badServerResponse)
        mockNetwork.mockedError = mockError
        
        sut.repos(query: "swift", page: 1, filter: .fewestStars)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error as? URLError, mockError)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure, got success")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRemoteManager_ShouldCancelFetching() {
        let expectation = XCTestExpectation(description: #function)
        sut.repos(query: "swift", page: 1, filter: .fewestStars)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                }
            }, receiveValue: {
                XCTAssertEqual($0, [])
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        sut.cancel()
        wait(for: [expectation], timeout: 1.0)
    }
}
