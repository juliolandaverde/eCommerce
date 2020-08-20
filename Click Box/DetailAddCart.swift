//
//  DetailAddCart.swift
//  Click Box
//
//  Created by Julio Landaverde
//  Copyright © 2020 Facebook. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

struct DetailAddCart: View {
    let product: Productos
    
    @State var cantidad: String = ""
    @State private var showal = false
    @State private var enableAirplaneMode = false
    @State private var selectedMode = 0
    @Environment(\.managedObjectContext) var moc
    
    
    
    
    var notificationMode = ["Lock Screen", "Notification Centre", "Banners"]
    var body: some View {
        Form{
            Section(header: Text("Variaciones")){
                Text("Aqui se van a mostrar las variaciones")
//                Toggle(isOn: $enableAirplaneMode) {
//                    Text("Airplane Mode")
//                }
                
//                Picker(selection: $selectedMode, label: Text("Notifications")) {
//                    ForEach(0..<notificationMode.count) {
//                        Text(self.notificationMode[$0])
//                    }
//                }
            }
        Section(header: Text("Cantidad")){
        TextField("Cantidad", text: $cantidad)
            Button(action:{
                if (retrieve(idpro: self.product.id) ){
                    update(idpro: self.product.id, cant: 1)
                    self.showal.toggle()
                    }else{
                    let total = Double(self.product.price)! * Double(self.cantidad)!
                    print(total)

                    let newCarrito = Carrito(context: self.moc)
                        newCarrito.idproducto = Int64(self.product.id)
                        newCarrito.nombreproducto = self.product.name
                        newCarrito.imageurl = self.product.images[0].src
                        newCarrito.price =  self.product.price
                        newCarrito.regular_price = self.product.regular_price
                        newCarrito.descripcion = self.product.description
                        newCarrito.cantidad = Int64(self.cantidad) ?? 1
                        newCarrito.total = total

                        try? self.moc.save()

                        self.showal.toggle()
                    }
                //self.showal.toggle()
            }){
                HStack(alignment: .center, spacing: 5.0) {
                    Image(uiImage: UIImage(named: "carrito-1")!)
                            .resizable()
                            .frame(width: 30,height: 30)
                            .padding(.leading,10.0)
                                            
                    Text("Agregar")
                        .fontWeight(.bold)
                        .font(.custom("GothamRounded-Book", size: 13))
                        .padding(.all, 4)
                                            
                }
            }.alert(isPresented: $showal){Alert(title: Text("Agregaste al carrito"),message: Text("Agregaste \(cantidad)"),
            dismissButton: .default(Text("OK")))
            }
        }
      }
    }
}


