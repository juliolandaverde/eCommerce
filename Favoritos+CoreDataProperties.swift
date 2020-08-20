//
//  Favoritos+CoreDataProperties.swift
//  Click Box
//
//  Created by Julio Landaverde
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import CoreData


extension Favoritos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favoritos> {
        return NSFetchRequest<Favoritos>(entityName: "Favoritos")
    }

    @NSManaged public var idproducto: Int64
    @NSManaged public var nombreproducto: String
    @NSManaged public var price: String
    @NSManaged public var regular_price: String
    @NSManaged public var descripcion: String
    @NSManaged public var imageurl: String

}
