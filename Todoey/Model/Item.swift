//
//  Item.swift
//  Todoey
//
//  Created by James  Farrell on 08/04/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    //specifies type of link and name of the relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
 
