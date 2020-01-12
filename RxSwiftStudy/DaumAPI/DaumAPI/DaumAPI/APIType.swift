//
//  SearchType.swift
//  DaumAPI
//
//  Created by ByoungHoon Yun on 20/07/2019.
//  Copyright © 2019 ByoungHoon. All rights reserved.
//

import Foundation

public protocol APIType {
    
    var host: String { get }
    
    var path: String { get }
    
    var method: String { get }
    
    var headers: [String: String]? { get }
    
    var parameters: [String: Any]? { get }
    
}
