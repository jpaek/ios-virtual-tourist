//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Jae Paek on 11/24/20.
//

import Foundation
import UIKit

struct FlickrPhoto: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}
