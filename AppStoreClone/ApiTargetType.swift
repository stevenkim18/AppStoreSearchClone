//
//  ApiTargetType.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/11/02.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
}

protocol ApiTargetType {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var mehtod: HttpMethod { get }
    var parameters : [String: Any] { get }
}

extension ApiTargetType {
    
    var scheme : String {
        return "https"
    }
    
    var method: HttpMethod {
        return .get
    }
    
    var parameters: [String: Any] {
        return [:]
    }
    
    func createURL(_ url: URL) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
    
    func createCompmnents() -> URLRequest? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        
        let queryItem = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)")}
        components.queryItems = queryItem
        
        guard let url = components.url else { return nil }
        print("request url = \(url.absoluteString)")
        
        return createURL(url)
    }
}
