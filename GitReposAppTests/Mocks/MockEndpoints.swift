//
//  MockEndpoints.swift
//  GitReposAppTests
//
//  Created by Дмитрий Мартьянов on 30.11.2024.
//

import Foundation
@testable import GitReposApp

struct MockEndpoint: EndpointType {
    var baseUrl: String = "https://test.com"
    
    var path: String = "/api/data"
    
    var parameters: [String : Any] = [:]
    
}

struct InvalidEndpoint: EndpointType {
    var baseUrl: String = "ht tp"
    
    var path: String = "path"
    
    var parameters: [String : Any] = [:]
    
}
