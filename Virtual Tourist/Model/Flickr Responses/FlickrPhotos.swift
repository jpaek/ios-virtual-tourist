//
//  Photos.swift
//  Virtual Tourist
//
//  Created by Jae Paek on 11/24/20.
//

import Foundation

struct FlickrPhotos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [FlickrPhoto]
}
