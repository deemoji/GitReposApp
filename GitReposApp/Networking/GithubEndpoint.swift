//
//  Endpoint.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 29.11.2024.
//

import Foundation


enum GithubEndpoint: EndpointType {
    enum SearchParameter: String {
        case query = "q"
        case perPage = "per_page"
        case page = "page"
        case sort = "sort"
        case order = "order"
    }
    
    enum SortType: String {
        case stars
        case updated
    }
    
    enum Order: String {
        case asc
        case desc
    }
    
    case searchRepos(parameters: [SearchParameter: Any])
    
    var baseUrl: String {
        "https://api.github.com"
    }
    
    var path: String {
        switch self {
        case .searchRepos:
            return "/search/repositories"
        }
    }
    
    var token: String {
        "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"
    }
    var parameters: [String: Any] {
        switch self {
        case .searchRepos(let parameters):
            var params = parameters.reduce(into: [:]) { result, pair in
                result[pair.key.rawValue] = pair.value
            }
            params["Authorization"] = token
            return params
        }
    }
}

