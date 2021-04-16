//
//  Category.swift
//  Todoey
//
//  Created by James  Farrell on 08/04/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colourHex: String = ""
    let items = RealmSwift.List<Item>()
}
