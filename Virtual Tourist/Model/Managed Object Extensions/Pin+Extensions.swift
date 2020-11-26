//
//  Pin+Extensions.swift
//  Virtual Tourist
//
//  Created by Paek, Jae on 11/25/20.
//

import Foundation
import CoreData

extension Pin {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
