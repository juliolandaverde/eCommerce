//
//  HomeView.swift
//  Click Box
//
//  Created by Julio Landaverde
//  Copyright © 2020 Facebook. All rights reserved.
//

import SwiftUI
import Combine
import CoreData
import WebKit

//numeracion para poder controlar que alert se mostrara
enum ActiveAlert {
    case first, second
}
enum ActiveAlert2 {
    case first, second
}


//esta es la clase que traera los productos que vienen por la categoria seleccionada
class categoriesviewmodel: ObservableObject {
    @Published var idcategoria = 360
    
    let objectWillChange = PassthroughSubject<categoriesviewmodel,Never>()
    
    var productoslistcategorie = [SubCategoria](){
        willSet{
            objectWillChange.send(self)
        }
    }
    
    func changecategorie(idcat:Int){
       self.idcategoria = idcat
        //print(self.idcategoria)
        let urlcategorias = "http:clickbox.com.sv/clickbox/WebServices/subcategoriaiOS.php?categoria=\(self.idcategoria)"
        
        
        
        guard let url = URL(string: urlcategorias) else{return}
        //print(url)
        URLCache.shared.removeAllCachedResponses()
        URLSession.shared.dataTask(with: url) {(data,_,_) in
            guard let data=data else{return}
            
            let subcategori = try! JSONDecoder().decode([SubCategoria].self, from: data)
            print(subcategori)
            
            DispatchQueue.main.async {
                self.productoslistcategorie = subcategori
                
            }
            
            
        }.resume()
 
    }
    
    
    
   
}
///**********************************************************************/
struct Categoria: Decodable,Identifiable {
    let id:Int
    let name:String
    let image: Imagen
    let description:String
    
    
}

struct SubCategoria: Decodable,Identifiable {
    let id:Int
    let name:String
    //let image: Imagen
    let description:String
    
    
}
struct Imagen: Decodable{
    let id:Int
    let name:String
    let src:String
}


struct Productos: Decodable, Identifiable {
    let id:Int
    let name:String
    let price:String
    let regular_price:String
    let images: [Imagenes]
    let description:String
    let tax_status:String
    let stock_quantity:Int?
    let stock_status:String
    let average_rating:String
    let status:String
}
struct Imagenes: Decodable,Identifiable {
    let id:Int
    let src:String
}

//**************************************************************************************//
//Fragmento de home que se muestra en la pantalla.
struct HomeView: View {
    
        @State private var selectedIndex: Int = 0
        @ObservedObject var ofertas = Ofertas()
        @ObservedObject var categoria = Categorias()
        @ObservedObject var networkManager = NetworkManager()
        @State private var showingAlert = false
    
    
        
        var body: some View {
            
             NavigationView {
                       List {
                        // statuses 1
                        
                        ScrollView(.horizontal, content: {
                            HStack(spacing: 10) {
                                ForEach(categoria.CategoriaList) { categoria in
                                    NavigationLink(destination: SubsCat()){
                                    CategoriaRow(categoria: categoria)
                                    }
                                    
                                }
                              
                            }
                            .padding(.leading, 10)
                        })
                        .frame(height: 100)
                        //Slider de las imagenes
                        GeometryReader { geometry in
                            ImageCarouselView(numberOfImages: 4) {
                                Image("slider1")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                                Image("slider3")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                                Image("slider4")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                                Image("slider5")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                            }
                        }.frame(width:UIScreen.main.bounds.width,height: 230)
                        
                        Section(header:Text("Ofertas")){
                          ScrollView(.horizontal, content: {
                              HStack {
                                ForEach(ofertas.ofertasList) { product in
                                    NavigationLink(destination: DetailProduct(product: product)){
                                        ProductoRowView2(product: product)
                                        Divider()
                                    }
                                  }
                              }
                              .padding(.leading, 10)
                          }).background(Color.green)
                          .frame(height: 200)
                        }
                           
                           // statuses 2
                       Section(header:Text("Tendencias")){
                           ScrollView(.horizontal, content: {
                               HStack(spacing: 10) {
                                ForEach(ofertas.ofertasList) { product in
                                    NavigationLink(destination: DetailProduct(product: product)){
                                       ProductoRowView2(product: product)
                                        Divider()
                                    }
                                   }
                               }
                               .padding(.leading, 10)
                           }).background(Color.pink)
                           .frame(height: 190)
                }
                           
                           
                           // posts
                        Section(header:Text("Productos")){
                        //networkManager.idcat = Int(360)
                        
                        ForEach(networkManager.productsList) { product in
                            NavigationLink(destination: DetailProduct(product: product)){
                               ProductoRowView(product: product)
                            }
                        }
                        }
                       } .padding(.leading, -14)
                                  .padding(.trailing, -14)
                                  .navigationBarTitle(Text("Inicio"))
                .id(UUID())
                        
            }
            
        }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct ProductoRowView: View{
    let product : Productos
    @State private var showingAlert = false

    
    var totalPrice: Double {
        guard let precio1 = Double(product.price) else { return 0.0 }
        return (precio1*1.13)
    }
    var totalPriceRegular: Double {
        guard let precio2 = Double(product.regular_price) else { return 0.0 }
        return (precio2*1.13)
    }
    
    var rating: Int{
        guard let retaing = Int(product.average_rating)else{return 0}
        return retaing
    }
    
    
    
    
    var body: some View{
        HStack{
            ImageViewCustom(imageurl: product.images[0].src)
//            Image("blanco").resizable()
            
            VStack{
                Text(product.name).frame(width: 125)
                RatingView(rating: (product.average_rating as NSString).integerValue)
            }
            
            
           
                VStack{
                Text("$\(totalPrice,specifier: "%.2f")").font(.system(size: 18))
                if(totalPriceRegular>totalPrice){
                    Text("$\(totalPriceRegular,specifier: "%.2f")").strikethrough().font(.system(size: 14))
                }
                
                
                
            }
            
        }.padding(.vertical, 6)
            .padding(.leading,5)
//            .frame(width: 150, height: 100, alignment: .center)
    }
}

struct ImageViewCustom: View {
    @ObservedObject var imageLoader:ImageLoader
    
    init(imageurl: String) {
        imageLoader = ImageLoader(imageUrl: imageurl)
    }
    
    var body: some View{
        Image(uiImage: (imageLoader.data.count == 0) ? UIImage(named: "blanco")! : UIImage(data: imageLoader.data)!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100,height: 120)
            .shadow(radius: 3)
            

    }

    
}


struct ImageViewCustom2: View {
    @ObservedObject var imageLoader:ImageLoader
    
    init(imageurl: String) {
        imageLoader = ImageLoader(imageUrl: imageurl)
    }
    
    var body: some View{
        Image(uiImage: (imageLoader.data.count == 0) ? UIImage(named: "blanco")! : UIImage(data: imageLoader.data)!).renderingMode(.original)
        .resizable()
            .frame(width: 80,height: 80)
    }

    
}
struct ImageCategoryView: View {
    @ObservedObject var imageLoader:ImageLoader
    
    init(imageurl: String) {
        imageLoader = ImageLoader(imageUrl: imageurl)
    }
    
    var body: some View{
        Image(uiImage: (imageLoader.data.count == 0) ? UIImage(named: "blanco")! : UIImage(data: imageLoader.data)!).renderingMode(.original)
        .resizable()
            .frame(width: 50,height: 50)
    }

    
}



struct ImageDetailView: View {
    @ObservedObject var imageLoader:ImageLoader
    
    
    init(imageurl: Imagenes) {
        imageLoader = ImageLoader(imageUrl: imageurl.src)
    }
    
    var body: some View{
        
        Image(uiImage: (imageLoader.data.count == 0) ? UIImage(named: "blanco")! : UIImage(data: imageLoader.data)!)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.main.bounds.width,height: 350)
            
    }

    
}

struct DetailProduct: View {
    @State private var text: String = ""
    let product :Productos
     var totalPrice: Double {
           guard let precio1 = Double(product.price) else { return 0.0 }
           return (precio1*1.13)
       }
       var totalPriceRegular: Double {
           guard let precio2 = Double(product.regular_price) else { return 0.0 }
           return (precio2*1.13)
       }

        @State private var showingAlert = false
        @State private var showingAlertFavorito = false
        @State private var showingAlertFavoritoExiste = false
        @State private var activeAlert: ActiveAlert = .first
        @State private var selected=0
        @State private var cantidad=0
        @State var existe=0
        @Environment(\.managedObjectContext) var moc

        var body: some View{
        ScrollView{
        VStack{
            //Imagenes de producto en slider
            GeometryReader { geometry in
                ImageCarouselView(numberOfImages: self.product.images.count) {
                    ForEach(self.product.images){images in
                       
                        ImageDetailView(imageurl: images)
                    }
                }
            }.frame(width: UIScreen.main.bounds.width,height: 350)
                .offset(y: -30)
            VStack{
            //Nombre y descripciones del producto
            Text(product.name).font(.custom("GothamRounded-Bold", size: 23)).padding(.top,35)
            Text("$\(totalPrice,specifier: "%.2f")").font(.custom("GothamRounded-Book", size: 20))
            if(product.price<product.regular_price){
                Text("$\(totalPriceRegular,specifier: "%.2f")").font(.subheadline).strikethrough()
            }
                RatingView(rating: (product.average_rating as NSString).integerValue)
                  Text("Existencia: \(product.stock_quantity ?? 25)").font(.custom("GothamRounded-Book", size: 16)).foregroundColor(Color.green)
            }.frame(width: UIScreen.main.bounds.width)
                .background(Blurview())
            //.clipShape(BottomShape())
            .cornerRadius(25)
          
            
            
                
            
            HStack{
                Button(action: {
                                    
                                    
                self.showingAlert.toggle()
                                    
                })
                {
                HStack(alignment: .center, spacing: 5.0) {
                    Image(uiImage: UIImage(named: "carrito-1")!)
                        .resizable()
                        .frame(width: 30,height: 30)
                        .padding(.leading,10.0)
                                            
                    Text("Agregar a Carrito")
                        .fontWeight(.bold)
                        .font(.custom("GothamRounded-Book", size: 13))
                        .padding(.all, 4)
                                                
                        }
                    }
                    .cornerRadius(10)
                    .sheet(isPresented: $showingAlert, content: {
                        //DetailAddCart(product: self.product)
                        AddTocart(moc:self.moc, product: self.product)
                        })
                            
                Divider()
                                        
                Button(action: {
                    if (retrieveFav(idpro: self.product.id) ){
                        self.activeAlert = .second
                        self.showingAlertFavorito = true
                    }else{
                        let newCarrito = Favoritos(context: self.moc)
                            newCarrito.idproducto = Int64(self.product.id)
                            newCarrito.nombreproducto = self.product.name
                            newCarrito.imageurl = self.product.images[0].src
                            newCarrito.price =  self.product.price
                            newCarrito.regular_price = self.product.regular_price
                            newCarrito.descripcion = self.product.description
                                            
                            try? self.moc.save()
                                            
                                self.activeAlert = .first
                                self.showingAlertFavorito = true
                            }
                    })
                    {
                        HStack(alignment: .center, spacing: 5.0) {
                            Image(uiImage: UIImage(named: "likeclickbox")!)
                                    .resizable()
                                    .frame(width: 30,height: 30)
                                    .padding(.leading,10.0)
                                                    //.foregroundColor(Color.white)
                                                    
                            Text("Agregar a Favoritos")
                                                     //.foregroundColor(Color.white)
                                .fontWeight(.bold)
                                .font(.custom("GothamRounded-Book", size: 13))
                                .padding(.all, 4)
                                                    
                        }
                    }
                                        //.background(Color.pink)
                    .cornerRadius(10)
                    .alert(isPresented: $showingAlertFavorito){  switch activeAlert {
                        case .first:
                            return Alert(title: Text("Agregaste a Favoritos"), message: Text("Agregaste el producto a favoritos"))
                        case .second:
                            return Alert(title: Text("Ya existe"), message: Text("Este producto ya existe en favoritos"))
                        }
                    }
                }.frame(height: 50)
            
            Divider()
            Spacer()
            Text("\(product.description.stripHTML())").font(.custom("GothamRounded-Book", size: 18)).padding(10)

            Divider()
            Spacer()

            }
      
        }
       
    }
    
  
}

struct ImageButtonCarrito: View{
     
    var idprod:Int
    var body: some View{
        Button(action:{
            print(self.idprod)
        }
            , label:{
                Text("Agregar a Carrito")
                .foregroundColor(Color.white)
                .fontWeight(.bold)
                .padding(.all, 4)
                .background(Color.green)
                .cornerRadius(5)

        })
       
        
    }
}

class ImageLoader: ObservableObject{
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



class NetworkManager: ObservableObject {
    
    let objectWillChange = PassthroughSubject<NetworkManager,Never>()
    
    var productsList = [Productos](){
        willSet{
            objectWillChange.send(self)
        }
    }
    init() {
        
        guard let url = URL(string: "http:clickbox.com.sv/clickbox/WebServices/productosIos.php") else{return}
        URLCache.shared.removeAllCachedResponses()
        URLSession.shared.dataTask(with: url) {(data,_,_) in
            guard let data=data else{return}
            
            let product = try! JSONDecoder().decode([Productos].self, from: data)
            //print(product)
            
            DispatchQueue.main.async {
                self.productsList = product
            }
            
        }.resume()
    }
   
}


class Ofertas: ObservableObject {
    let objectWillChange = PassthroughSubject<Ofertas,Never>()
    
    var ofertasList = [Productos](){
        willSet{
            objectWillChange.send(self)
        }
    }
    init() {
        
        guard let url = URL(string: "http:clickbox.com.sv/clickbox/WebServices/productosIosOferta.php") else{return}
        URLCache.shared.removeAllCachedResponses()
        URLSession.shared.dataTask(with: url) {(data,_,_) in
            guard let data=data else{return}
            
            let product = try! JSONDecoder().decode([Productos].self, from: data)
            //print(product)
            
            DispatchQueue.main.async {
                self.ofertasList = product
            }
            
        }.resume()
    }
   
}

class Categorias: ObservableObject {
    let objectWillChange = PassthroughSubject<Categorias,Never>()
    
    var CategoriaList = [Categoria](){
        willSet{
            objectWillChange.send(self)
        }
    }
    init() {
        
        guard let url = URL(string: "http:clickbox.com.sv/clickbox/WebServices/productoscategoriaIos.php") else{return}
        URLCache.shared.removeAllCachedResponses()
        URLSession.shared.dataTask(with: url) {(data,_,_) in
            guard let data=data else{return}
            
           //let product = try! JSONDecoder().decode([Categoria].self, from: data)
            
            //print(product)
            
            
            /*DispatchQueue.main.async {
                self.CategoriaList = product
            }*/
            
        }.resume()
    }
   
}


struct ProductoRowView2: View{
    let product : Productos
    @State private var showingAlert = false

    var totalPrice: Double {
        guard let precio1 = Double(product.price) else { return 0.0 }
        return (precio1*1.13)
    }
    var totalPriceRegular: Double {
        guard let precio2 = Double(product.regular_price) else { return 0.0 }
        return (precio2*1.13)
    }
    var body: some View{
           
        VStack{
            ImageViewCustom2(imageurl: product.images[0].src).frame(height: 80)
            Text(product.name).frame(width: 80).font(.system(size: 12)).foregroundColor(Color.primary)
            VStack{
                
                Text("$\(totalPrice,specifier: "%.2f")").font(.system(size: 12)).foregroundColor(Color.primary)
                if(totalPriceRegular>totalPrice){
                    Text("$\(totalPriceRegular,specifier: "%.2f")").strikethrough().font(.system(size: 10)).foregroundColor(Color.primary)
                }
            }
        }.padding(.vertical, 6)
        
            .frame(width: 100, height: 180, alignment: .center)
            .background(Color.white)
            .cornerRadius(10)
        .alert(isPresented: $showingAlert){
            Alert(title: Text("Agregaste al carrito"),message: Text("Agregaste el producto \(product.id)"),
                dismissButton: .default(Text("OK")))
        }
    }
}

struct CategoriaRow: View{
    @ObservedObject var categoriachange = categoriesviewmodel()
    let categoria : Categoria
    
    var body: some View{
       
        VStack{
            ImageCategoryView(imageurl: categoria.image.src).frame(height: 60)

            Text(categoria.name).frame(width: 80).font(.system(size: 12)).lineLimit(nil).foregroundColor(Color.primary)
  
        }.padding(.vertical, 6)
            .frame(width: 80, height: 90, alignment: .center)
            .background(Color.white)
            .cornerRadius(10)
            .gesture(TapGesture().onEnded(
                {
                    self.categoriachange.changecategorie(idcat: self.categoria.id)
            }))
    
    }
}

func update(idpro:Int,cant:Int){
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchrequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Carrito")
    fetchrequest.predicate = NSPredicate(format: "idproducto = %i", idpro)
    do{
        let test = try managedContext.fetch(fetchrequest)
        
        let objectUpdate=test[0] as! NSManagedObject
        let carting=test[0] as! Carrito
        let cantiti=Int(carting.cantidad)
        let total = (Double(carting.price)! * 1.13) * Double(cantiti+cant)
        print("updatetotal \(total)")
        objectUpdate.setValue(cantiti+cant, forKey: "cantidad")
        objectUpdate.setValue(total, forKey: "total")
        
        do{
            try managedContext.save()
        }catch{
         print(error)
        }
        
    }catch{
        print(error)
    }
}

func retrieve(idpro:Int) -> Bool{

    var response=false
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return false}
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchrequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Carrito")
    fetchrequest.predicate = NSPredicate(format: "idproducto = %i", idpro)
    print(fetchrequest)
    do{
           let test = try managedContext.fetch(fetchrequest)
        if test.count>0 {
            response = true
        }else{
            response = false
        }
    }catch{
          response = false
        print(error)
        }
    
   
    
    return response
}

func retrieveFav(idpro:Int) -> Bool{

    var response=false
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return false}
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchrequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Favoritos")
    fetchrequest.predicate = NSPredicate(format: "idproducto = %i", idpro)
    print(fetchrequest)
    do{
           let test = try managedContext.fetch(fetchrequest)
        if test.count>0 {
            response = true
        }else{
            response = false
        }
    }catch{
          response = false
        print(error)
        }
    
   
    
    return response
}


struct modalview:View{
    @State private var name: String = ""
    var body: some View{
        ZStack{
            VStack{
            Text("Ingresa Cantidad")
            TextField("", text: $name).frame(width: 30,height: 10)
            Text("Cantidad \(name)")
            }
            //Button(
        }
    }
}

struct TextFieldView: View {
    @State private var text: String = ""

    var body: some View {
        VStack {
            TextField("Cantidad", text: $text)
            Text("Cantidad = \(text)!")
        }
    }
}


//Picker example
//HStack{
//    Picker(selection: $selected, label: Text("Cantidad")) {
//        ForEach(0 ..< 10) {
//            Text("\($0)")
//
//        }
//    }.pickerStyle(WheelPickerStyle())
//
//}
//script para convertir el texto html en texto normal



//Vista que permite agregar cantidades de producto y sus variables.
//Se crea un formulario con el campo de la cantidad y si es un producto variable se mostrara una forma de agregar la variante. en un Picker si se puede.
struct AddTocart: View{
    
    let moc:NSManagedObjectContext
    @State private var cantidad=""
    @State private var cant=1
    @State private var showal = false
    @State private var enableAirplaneMode = false
    @State private var selectedMode = 0
    let product:Productos
    @State private var activeAlert2: ActiveAlert2 = .first
    
    
    var disableform:Bool{
        cant < 1
    }
    var cantidadstock:Int{
        let cantity = self.product.stock_quantity ?? 25
        return cantity
    }
    
    var body: some View{
         Form{
                    Section(header: Text("Variaciones")){
                        Text("Aqui se van a mostrar las variaciones")
                    }
            Section(header: Text("Cantidad")){
            //TextField("Cantidad", text: $cantidad)
                
                Stepper(value: $cant, in: 1...cantidadstock){
                    Text("N. Articulos: \(cant)")
                }
            }
            Section{
                Button(action:{
                    if(self.cant > self.product.stock_quantity ?? 25){
                        self.showal.toggle()
                        self.activeAlert2 = .second
                    }else{
                    if (retrieve(idpro: self.product.id) ){
                        update(idpro: self.product.id, cant: self.cant)
                        self.activeAlert2 = .first
                        self.showal.toggle()
                        }else{
                        print("add to cart")
                        let total = (Double(self.product.price)! * 1.13) * Double(self.cant)
                        print(total)
                        
                        let newCarrito = Carrito(context: self.moc)
                            newCarrito.idproducto = Int64(self.product.id)
                            newCarrito.nombreproducto = self.product.name
                            newCarrito.imageurl = self.product.images[0].src
                            newCarrito.price =  self.product.price
                            newCarrito.regular_price = self.product.regular_price
                            newCarrito.descripcion = self.product.description
                            newCarrito.cantidad = Int64(self.cant)
                            newCarrito.total = total
                       
                            try? self.moc.save()

                            self.activeAlert2 = .first
                            self.showal.toggle()
                        }
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
                }.alert(isPresented: $showal){switch activeAlert2 {
                    case .first:
                        return Alert(title: Text("Agregaste al Carrito"), message: Text("Agregaste el producto al carrito"))
                    case .second:
                        return Alert(title: Text("Atención!"), message: Text("No puedes seleccionar mas de la existencia"))
                    }
                    
                }
            }.disabled(disableform)
            
        }
    }
}

struct RatingView : View{
    let rating:Int
    
    
    var label = ""
    var maximumRating = 5
    
    var offImage:Image?
    var onImage = Image(systemName: "star.fill")
    
    var offColor = Color.gray
    var onColor = Color.pink
    
    var body: some View{
        HStack {
            if label.isEmpty == false {
                Text(label)
            }

            ForEach(1..<maximumRating + 1) { number in
                
                self.image(for: number)
                    .foregroundColor(number > self.rating ? self.offColor : self.onColor)
                    
                
                //print("\(self.rating)")
                
            }
        }.frame(width: 50)
    }
    func image(for number: Int) -> Image {
        
        if number > rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
}

//metodo que convierte el texto que viene en formato HTML a formato String
/**
The html replacement regular expression
*/
let     htmlReplaceString   :   String  =   "<[^>]+>"

extension NSString {
    /**
    Takes the current NSString object and strips out HTML using regular expression. All tags get stripped out.

    :returns: NSString html text as plain text
    */
    func stripHTML() -> NSString {
        return self.replacingOccurrences(of: htmlReplaceString, with: "", options: NSString.CompareOptions.regularExpression, range: NSRange(location: 0,length: self.length)) as NSString
    }
}

extension String {
    /**
    Takes the current String struct and strips out HTML using regular expression. All tags get stripped out.

    :returns: String html text as plain text
    */
    func stripHTML() -> String {
        return self.replacingOccurrences(of: htmlReplaceString, with: "", options: NSString.CompareOptions.regularExpression, range: nil)
    }
}

//Struct para traer las subcategorias
struct SubsCat : View {
    
    
     @ObservedObject var categoriasviewmodel = categoriesviewmodel()
       

        var body: some View{
            NavigationView{
            ForEach(categoriasviewmodel.productoslistcategorie) { categoria in
                SubcategoriView(categoria: categoria)
                
                
            }
            }
           
    }
}

struct SubcategoriView:View {
    let categoria : SubCategoria
    var body: some View{
        Text(categoria.name)
    }
}

struct Blurview : UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<Blurview>) -> UIVisualEffectView {
        
        
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Blurview>) {
        
        
    }
}

struct BottomShape : Shape {
    
    func path(in rect: CGRect) -> Path {
        
        return Path{path in

            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addArc(center: CGPoint(x: rect.width / 2, y: 0), radius: 24, startAngle: .zero, endAngle: .init(degrees: 180), clockwise: false)
            
        }
    }
}


