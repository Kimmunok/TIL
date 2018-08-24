//
//  DemoURL.swift
//  Cassini
//
//  Created by 김문옥 on 2018. 2. 3..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import Foundation

struct DemoURL
{
    static let Stanford = "https://gsa.kaist.ac.kr/files/attach/images/2946/967/042/3961beab55ae215aaa98f8abf0b4d63d.png"
    
    static let NASA = [
        "Cassini" : "http://www.jpl.nasa.gov/images/cassini/20090202/pia03883-full.jpg", "Earth" : "http://www.nasa.gov/sites/default/files/wave_earth_mosaic_3.jpg", "Saturn" : "http://www.nasa.gov/sites/default/files/saturn_collage.jpg"
    ]
    
    static func NASAImageNamed(imageName: String?) -> NSURL? {
        if let urlstring = NASA[imageName ?? ""] {
            return NSURL(string: urlstring)
        } else {
            return nil
        }
    }
}

