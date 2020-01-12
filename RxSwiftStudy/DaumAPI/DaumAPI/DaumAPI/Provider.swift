//
//  Provider.swift
//  DaumAPI
//
//  Created by ByoungHoon Yun on 20/07/2019.
//  Copyright © 2019 ByoungHoon. All rights reserved.
//

import Foundation

public typealias APIResponse = (data: Data, urlResponse: URLResponse)

public typealias Completion = (_ result: Result<APIResponse, APIError>) -> Void

public protocol ProviderType: AnyObject {
    
    associatedtype API: APIType
    var session: URLSessionDataTask? { get set }
    func request(_ api: API, complete: @escaping Completion)
}

open class Provider<API: APIType>: NSObject {
    
    public weak var session: URLSessionDataTask?
    
    private func createURLRequest(_ api: API) -> URLRequest? {
        
        guard var urlComponents = URLComponents(string: "\(api.host)\(api.path)") else {
            return nil
        }
        
        if let parameters = api.parameters {
            let query = parameters.compactMap { "\($0)=\($1)&" }.joined()
            urlComponents.query = query
        }
        
        var request = URLRequest(url: (urlComponents.url)!)
        request.httpMethod = api.method
        
        api.headers?
            .compactMap{ ($0,$1) }
            .forEach { request.setValue($1, forHTTPHeaderField: $0) }

        return request
    }
    
}

extension Provider: ProviderType {
    
    //MARK: Request
    public func request(_ api: API, complete: @escaping Completion) {
        
        guard let urlRequest = createURLRequest(api) else {
            complete(.failure(.invalidURL))
            return
        }
        
        let defaultSession = URLSession.shared
        
        session = defaultSession.dataTask(with: urlRequest, completionHandler: { (data, urlResponse, error) in
            if let error = error {
                complete(.failure(.unknowned(error.localizedDescription)))
            }
            
            guard let urlResponse = urlResponse else {
                complete(.failure(.unknowned("")))
                return
            }
            
            if let response = urlResponse as? HTTPURLResponse,
                response.statusCode != 200 {
                complete(.failure(.failCode(response.statusCode)))
                return
            }

            guard let data = data else {
                complete(.failure(.dataEmpty))
                return
            }
            
            complete(.success((data, urlResponse)))
        })
        session?.resume()
    }

}
