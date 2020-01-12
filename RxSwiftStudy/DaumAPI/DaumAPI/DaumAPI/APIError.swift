//
//  APIError.swift
//  DaumAPI
//
//  Created by ByoungHoon Yun on 20/07/2019.
//  Copyright © 2019 ByoungHoon. All rights reserved.
//

import Foundation

public enum APIError {
    
    // Request Error
    case invalidURL
    
    // Response Error
    case failCode(Int)
    case dataEmpty
    case invalidJSON
    
    // Unknowned
    case unknowned(String)
}

extension APIError: Error {}
