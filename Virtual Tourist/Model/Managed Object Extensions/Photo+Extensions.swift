//
//  Photo+Extensions.swift
//  Virtual Tourist
//
//  Created by Paek, Jae on 11/25/20.
//

import Foundation
import CoreData

extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
