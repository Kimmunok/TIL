//
//  URL+Extension.swift
//  DaumAPI
//
//  Created by ByoungHoon Yun on 20/07/2019.
//  Copyright © 2019 ByoungHoon. All rights reserved.
//

import Foundation

extension URL {
    
    public var queryParameters: [String: Any]? {
        
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else {
                return nil
        }

        return queryItems.reduce(into: [String: Any]()){ $0[$1.name] = $1.value }
    }
}

