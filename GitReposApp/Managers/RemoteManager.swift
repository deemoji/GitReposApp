//
//  RemoteManager.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 30.11.2024.
//

import Foundation
import Combine

protocol RemoteManager: AnyObject {
    func repos(query: String, page: Int, filter: ReposFilter) -> AnyPublisher<[RemoteRepository], Error>
    func cancel()
}
final class GithubRemoteManager: RemoteManager {
    
    private let network: NetworkService
    private let itemsPerPage = 30
    
    init(network: NetworkService) {
        self.network = network
    }
    
    func repos(query: String, page: Int, filter: ReposFilter) -> AnyPublisher<[RemoteRepository], Error> {
        let parameters = createParameters(query: query, page: page, filter: filter)
        let endPoint = GithubEndpoint.searchRepos(parameters: parameters)
        return Deferred {
            Future<[RemoteRepository], Error> { [unowned self] promise in
                Task {
                    do {
                        let responce: RemoteResponse = try await network.fetch(endPoint)
                        promise(.success(responce.items))
                    }
                    catch let error as URLError where error.code == .cancelled {
                        promise(.success([]))
                    }
                    catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .retry(3)
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    private func createParameters(query: String, page: Int, filter: ReposFilter) -> [GithubEndpoint.SearchParameter: Any] {
            var parameters: [GithubEndpoint.SearchParameter: Any] = [
                .query: query,
                .page: page,
                .perPage: itemsPerPage
            ]
            
            switch filter {
            case .mostStars:
                parameters[.sort] = GithubEndpoint.SortType.stars.rawValue
            case .lastUpdated:
                parameters[.sort] = GithubEndpoint.SortType.updated.rawValue
            case .fewestStars:
                parameters[.sort] = GithubEndpoint.SortType.stars.rawValue
                parameters[.order] = GithubEndpoint.Order.asc.rawValue
            }
            
            return parameters
        }
    
    func cancel() {
        network.cancel()
    }
}
