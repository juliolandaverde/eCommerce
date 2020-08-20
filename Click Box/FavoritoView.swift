//
//  FavoritoView.swift
//  Click Box
//
//  Created by Julio Landaverde
//  Copyright © 2020 Facebook. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

struct FavoritoView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
     @FetchRequest(entity: Favoritos.entity(), sortDescriptors: []) var favoritos: FetchedResults<Favoritos>
    //var favorite:Favoritos
    var body: some View {
        NavigationView{
        List{
            ForEach(favoritos, id: \.idproducto) { favorito in
            FavoritosRowView(favorito : favorito)
            
            }.onDelete(perform: removefav)
        }.navigationBarTitle(Text("Favoritos"))
            .navigationBarItems(trailing: EditButton())
        }.padding(.leading, -10)
        .padding(.trailing, -10)
            
        
    }
    func removefav(at offsets:IndexSet) {
        for index in offsets{
            let fav=favoritos[index]
            managedObjectContext.delete(fav)
            do {
                try managedObjectContext.save()
            } catch {
                // handle the Core Data error
            }
        }
    }
}

struct FavoritoView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritoView()
    }
}

struct FavoritosRowView:View{
    let favorito : Favoritos
        @State private var showingAlert = false

        var totalPrice: Double {
            guard let precio1 = Double(favorito.price) else { return 0.0 }
            return (precio1*1.13)
        }
        var totalPriceRegular: Double {
            guard let precio2 = Double(favorito.regular_price) else { return 0.0 }
            return (precio2*1.13)
        }
        var body: some View{
            HStack{
                ImageViewCustom(imageurl: favorito.imageurl)
    //            Image("blanco").resizable()
                Text(favorito.nombreproducto).frame(width: 150)
                VStack{
                    
                    Text("$\(totalPrice,specifier: "%.2f")").font(.system(size: 18))
                    if(totalPriceRegular>totalPrice){
                        Text("$\(totalPriceRegular,specifier: "%.2f")").strikethrough().font(.system(size: 14))
                    }
                    
    //                ImageButtonCarrito(idprod: self.product.id)
    //            Button(action: {
    //                self.showingAlert.toggle()
    //            },
    //                   label: {
    //                Text("Agregar carrito")
    //                    .foregroundColor(Color.white)
    //                    .fontWeight(.bold)
    //                    .padding(.all, 4)
    //                    .background(Color.blue)
    //                    .cornerRadius(5)
    //                    .font(.system(size: 14))
    //
    //            })
                }
                //ImageButtonCarrito(idprod: product.id)
                
            }.padding(.vertical, 6)
            
            
                               
    //            .frame(width: 150, height: 100, alignment: .center)
        }
}

class ImageLoaderFav: ObservableObject{
    let objectWillChange = PassthroughSubject<Data,Never>()
    
    var data = Data(){
        willSet{
            objectWillChange.send(data)
        }
    }
    init(imageUrl: String) {
            //fetch image data and call willchange
        guard let url=URL(string: imageUrl) else {return}
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else {return}
            
            DispatchQueue.main.async {
                self.data = data
                
            }
            
        }.resume()
        
    }
}

struct imageviewCustomfavorite:View{
    @ObservedObject var imageLoader:ImageLoaderCart
      
      init(imageurl: String) {
          imageLoader = ImageLoaderCart(imageUrl: imageurl)
      }
      
      var body: some View{
          Image(uiImage: (imageLoader.data.count == 0) ? UIImage(named: "blanco")! : UIImage(data: imageLoader.data)!)
          .resizable()
              .frame(width: 100,height: 120)
      }

      
}

func deletefavorito(idpro:Int){
    
    
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favoritos")
    fetchRequest.predicate = NSPredicate(format: "idproducto = @i", idpro)
    
    do{
        let test = try managedContext.fetch(fetchRequest)
        
        let objetoaborrar = test[0] as! NSManagedObject
        managedContext.delete(objetoaborrar)
        
        do{
            try managedContext.save()
        }catch{
            print(error)
        }
    }
    catch{
        print(error)
    }
    
}


