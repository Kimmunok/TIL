//
//  DaumAPI.swift
//  DaumAPI
//
//  Created by ByoungHoon Yun on 20/07/2019.
//  Copyright © 2019 ByoungHoon. All rights reserved.
//

import Foundation

public typealias SearchParameters = (query: String, sort:String?, page: UInt16, size: UInt16?)

public enum API {
    case searchForImage(parameters:SearchParameters)
    case searchForVideo(parameters:SearchParameters)
}

extension API: APIType {
    
    public var host: String {
        return DaumAPIResources.host
    }
    
    public var path: String {
        switch self {
        case .searchForImage:
            return "/v2/search/image"
        case .searchForVideo:
            return "/v2/search/vclip"
        }
    }
    
    public var method: String {
        switch self {
        case .searchForImage,
             .searchForVideo:
            return "GET"
        }
    }
    
    public var headers: [String : String]? {
        return ["Authorization":"KakaoAK d008716ce9b2495626e4831190a44e21"] //
    }
    
    public var parameters: [String : Any]? {
        
        switch self {
        case .searchForVideo(let parameters),
             .searchForImage(let parameters):
        
            var params = [String: Any]()
            
            params["query"] = parameters.query
            params["page"] = parameters.page
            
            if let sort = parameters.sort {
                params["sort"] = sort
            }
            
            if let size = parameters.size {
                params["size"] = size
            }
            
            return params
        }
        
    }
    
}

