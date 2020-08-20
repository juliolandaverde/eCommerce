//
//  Carrito+CoreDataProperties.swift
//  Click Box
//
//  Created by Julio Landaverde
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import CoreData


extension Carrito {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Carrito> {
        return NSFetchRequest<Carrito>(entityName: "Carrito")
    }

    @NSManaged public var descripcion: String
    @NSManaged public var idproducto: Int64
    @NSManaged public var imageurl: String
    @NSManaged public var nombreproducto: String
    @NSManaged public var price: String
    @NSManaged public var regular_price: String
    @NSManaged public var cantidad: Int64
    @NSManaged public var total: Double

}
