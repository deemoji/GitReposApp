//
//  NetworkServiceTests.swift
//  GitReposAppTests
//
//  Created by Дмитрий Мартьянов on 30.11.2024.
//

import XCTest
@testable import GitReposApp

final class NetworkServiceTests: XCTestCase {
    
    var sut: NetworkService!
    
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        sut = NetworkServiceImpl(urlSession: session)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testNetworkService_ShouldFetchSuccess() async throws {
        let expectedModel = MockModel(id: 1, name: "Test")
        let responseData = try! JSONEncoder().encode(expectedModel)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, responseData)
        }
        
        let recievedModel: MockModel = try await sut.fetch(MockEndpoint())
        XCTAssertEqual(recievedModel, expectedModel)
    }
    
    func testNetworkService_ShouldFetchServerError() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 404,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }
        do {
            let _: MockModel = try await sut.fetch(MockEndpoint())
            XCTFail("Data shouldn't have been recieved")
        } catch {
            XCTAssertTrue(error is URLError, error.localizedDescription)
        }
    }
    
    func testNetworkService_ShouldCancelRequest() async {
        let expectation = XCTestExpectation(description: #function)
        
        MockURLProtocol.requestHandler = { _ in
            sleep(2)
            return (HTTPURLResponse(), Data())
        }
        
        Task {
            do {
                let _: MockModel = try await sut.fetch(MockEndpoint())
                XCTFail("The request isnt cancelled as expected")
            } catch let error as URLError {
                XCTAssertEqual(error.code, .cancelled, "Error should be URLError.cancelled")
                expectation.fulfill()
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.sut.cancel()
        }
        
        await fulfillment(of: [expectation], timeout: 3.0)
    }
    
}
