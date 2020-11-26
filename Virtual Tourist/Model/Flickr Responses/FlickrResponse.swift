//
//  FlickrResponse.swift
//  Virtual Tourist
//
//  Created by Jae Paek on 11/24/20.
//

import Foundation

struct FlickrResponse: Codable {
    let stat: String
    let code: Int
    let message: String
    
}

extension FlickrResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
