//
//  SQLiteHelper.swift
//  Click Box
//
//  Created by Javier Lopez on 1/2/20.
//  Copyright © 2020 Javier Lopez. All rights reserved.
//

import Foundation
import SQLite

class DataModel{
    static let instance = DataModel()
    private var db: Connection? = nil
    
    private let carrito = Table("Carrito")
    private let id = Expression<Int64>("id")
    private let idpro = Expression<Int>("idpro")
    private let Nombrepro = Expression<String>("nombrepro")
    private let cantidad = Expression<Int>("cantidad")
    private let precio = Expression<String>("precio")
    private let imagen = Expression<String>("imagen")
    private let descripcion=Expression<String>("descripcion")
    
    
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!

        do {
            db = try Connection("\(path)/Database.sqlite3")
        } catch {
            db = nil
            print ("Unable to open database")
        }

        createTableCarrito()
    }

    func createTableCarrito() {
        do {
            try db!.run(carrito.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(idpro)
            table.column(Nombrepro)
            table.column(descripcion)
            table.column(imagen)
            table.column(cantidad)
            table.column(precio)
            })
        } catch {
            print("Unable to create table")
        }
    }
    
    func AddCarrito(cidpro: Int,cNombrepro:String,cdescripcion:String,cimagen:String,ccantidad:Int,cprecio:String) -> Int64? {
        do {
            let insert = carrito.insert(idpro <- cidpro,Nombrepro<-cNombrepro,descripcion<-cdescripcion,imagen<-cimagen,cantidad<-ccantidad,precio<-cprecio)
               let id = try db!.run(insert)
                print(insert.asSQL())
               return id
           } catch {
               print("Insert failed")
               return -1
           }
    }
    
    func getContacts() -> [Carrito] {
        var carritos = [Carrito]()

        do {
            for carrito in try db!.prepare(self.carrito) {
                carritos.append(Carrito(id: carrito[id], idproducto: carrito[idpro], Nombrepro: carrito[Nombrepro], imagen: carrito[imagen], cantidad: carrito[cantidad], precio: carrito[precio], idvariable: 0, descripcion: carrito[descripcion]))
            }
        } catch {
            print("Select failed")
        }

        return carritos
    }
    
    func getContactsByProduct(idproducto1:Int) -> Int {
        var idcart:Int=0
        let cart = carrito.filter(idpro == idproducto1)
        do {
            for carrito in try db!.prepare(cart) {
                idcart=Int(carrito[id])
            }
        } catch {
            print("Select failed")
            return -1
        }

        return idcart
    }
    
    func getCantProduct(idproducto1:Int) -> Int {
        var cantidad1:Int=0
        let cart = carrito.filter(idpro == idproducto1)
        do {
            for carrito in try db!.prepare(cart) {
                cantidad1=Int(carrito[cantidad])
            }
        } catch {
            print("Select failed")
            return -1
        }

        return cantidad1
    }
    
    func updateCantCarrito(cid:Int, cant:Int) -> Bool {
        //let cart = carrito.filter(idpro == cid)
        let cart = carrito.filter(idpro == cid)
        //let canti=getCantProduct(idproducto1: cid)
       // let suma = canti + cant
        var bole = false
        do {
            if try db!.run(cart.update(cantidad += 1)) > 0 {
                print("updated alice")
                bole = true
            } else {
                print("alice not found")
                bole = false
            }
        } catch {
            print("update failed: \(error)")
            bole = false
        }
        return bole
    }

}
    
