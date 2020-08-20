//
//  CarritoView.swift
//  Click Box
//
//  Created by Julio Landaverde
//  Copyright © 2020 Facebook. All rights reserved.
//

import SwiftUI
import Combine
import CoreData



struct Departamentos: Decodable,Identifiable {
    let id :Int 
    let code:String
    let name:String
    let Municipios:[Municipios]

}

struct Municipios:Decodable,Identifiable{
    let id :Int
    let name:String
}

struct FormasEnvio:Decodable,Identifiable{
    let id :Int
    let method_id :String
    let method_title:String
    let title :String
    let enabled:Bool
    let settings:Settings
}

struct Settings:Decodable{
    let cost:costos?
}

struct costos:Decodable,Identifiable{
    let id:String?
    let value:String?
}

struct FormasPago:Decodable,Identifiable{
    let id :String
    let title :String
    let enabled:Bool
    let description:String
}



struct CarritoView: View {
   //var carritos:[Carrito]=DataModel.instance.getContacts()
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Carrito.entity(), sortDescriptors: []) var carritos: FetchedResults<Carrito>
    @State var totalprecios = 0.0
    
   var totaltotal : Double{
         let valor = sumtotal()
        
        return valor
    }
    
    
   
   
    var body: some View {
        
        NavigationView {
            
        List{
        
            Section(header: HStack{
                Text("Imagen").frame(width: 100)
                //            Image("blanco").resizable()
                Text("Nombre").frame(width: 130)
                Text("Cantidad")
                Text("Precio")
                },  content: {
            ForEach(carritos, id: \.idproducto) { carrito in
                
                CarritoRowView(carrito: carrito)
                
                
                
            }.onDelete(perform: removecarrito)
            })
            
            

            Text("Total $\(totaltotal,specifier: "%.2f")")
            VStack{
            NavigationLink(destination: IngresoDatos(),label: {Text("Finalizar Compra")})
            }
    
    
        }.navigationBarTitle(Text("Carrito"))
            .navigationBarItems(trailing: EditButton())
            
           
        }.padding(.leading, -10)
        .padding(.trailing, -10)
        .navigationBarTitle(Text("Carrito"))
       
        
    }
    func removecarrito(at offsets:IndexSet) {
        for index in offsets{
            let cart=carritos[index]
            managedObjectContext.delete(cart)
            do {
                try managedObjectContext.save()
            } catch {
                // handle the Core Data error
            }
        }
    }
    
}

struct CarritoView_Previews: PreviewProvider {
    static var previews: some View {
        CarritoView()
        
    }
}


struct CarritoRow: View {
   
   
    var body: some View {
        HStack{
           
           
             Text("Hola").font(.system(size: 18))
                           
        }
    }
}

struct DetailCarrito:View {
    
    
    var body:some View{
        VStack(alignment:.leading){
           Text("Hola")
        }
    }
}

struct ImageViewCustom1: View {
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

struct CarritoRowView:View {
        let carrito : Carrito
   
    //@State private var selected = 0
    
        @State private var showingAlert = false

        var totalPrice: Double {
            guard let precio1 = Double(carrito.price) else { return 0.0 }
            return (precio1*1.13)
        }
        var totalPriceRegular: Double {
            guard let precio2 = Double(carrito.regular_price) else { return 0.0 }
            return (precio2*1.13)
        }
   
    
    
    
    
        var body: some View{
            HStack{
                ImageViewCustom(imageurl: carrito.imageurl)
    //            Image("blanco").resizable()
                Text(carrito.nombreproducto).frame(width: 130)
                Text("\(carrito.cantidad)").frame(width: 70)
                VStack{
                    
                    Text("$\(totalPrice,specifier: "%.2f")").font(.system(size: 18))
                    if(totalPriceRegular>totalPrice){
                        Text("$\(totalPriceRegular,specifier: "%.2f")").strikethrough().font(.system(size: 14))
                    }
                    
                }
                
            }.padding(.vertical, 6)
            
                               
    //            .frame(width: 150, height: 100, alignment: .center)
        }
}

class ImageLoaderCart: ObservableObject{
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
//Modelo que sirve para cambiar el picker secundario.
//Esto se aplica para los controles que heredan un dato de otro
//en este caso el picker de municipios tiene que cambiar segun el departamento.
class Model: ObservableObject {
    @ObservedObject var departments = Departaments()
    var departamentos : [Departamentos] {
        return departments.departamentslist
    }
    private var citySelections: [Int: Int] = [:]

    @Published var selectedContry: Int = 0 {
            willSet {
                //print("country changed", newValue, citySelections[newValue] ?? 0)
                selectedCity = citySelections[newValue] ?? 0
                id = UUID()
            }
        }
    @Published var selectedCity: Int = 0 {
            willSet {
                DispatchQueue.main.async { [newValue] in
                    
                    //print("city changed", newValue)
                    self.citySelections[self.selectedContry] = newValue
                    self.printeres()
                }
            }
        }
    @Published var id: UUID = UUID()
   
    var countryNemes: [String] {
        departamentos.map { (depart) in
            depart.name
        }
    }
    var cityNamesCount: Int {
        cityNames.count
    }
    var cityNames: [String] {
       
        return departamentos[selectedContry].Municipios.map { (city) in
            city.name
        }
    }
    var departamentoseleted:String{
        return departamentos[selectedContry].code
    }
    var municipioselected:String{
        return departamentos[selectedContry].Municipios[selectedCity].name
    }
    
    func printeres(){
        print(departamentos[selectedContry].name)
        print(departamentos[selectedContry].Municipios[selectedCity].name)}
}

///
//Struct que llama la vista de los datos del cliente.
struct IngresoDatos: View {
    
    
    @State var nombre = ""
    @State var apellido = ""
    @State var nombrerecibe = ""
    @State var direccion = ""
    @State var referencia = ""
    @State var telefono = ""
    @State var correo = ""
    @State var dui = ""
    @State var nota = ""

    //se crea una instancia de la clase Model la cual se usara para cambiar los datos que se usaran en los controles de los pickers
    @ObservedObject var model = Model()
 
    
    @State private var depSelection = ""
    
     var codigodep :String{
        return model.departamentoseleted
    }
    var municipio :String{
        return model.municipioselected
    }
    
    var body: some View {
        
            Form{
                Section(header: Text("Datos personales")){
                    TextField("Nombre", text: $nombre)
                TextField("Apellido", text: $apellido)
                TextField("Nombre de quien recibe", text: $nombrerecibe)
                TextField("DUI", text: $dui)
                }
                Section(header: Text("Departamento")){
                    
                     
                            Picker(selection: $model.selectedContry, label: Text("")){
                                ForEach(0 ..< model.countryNemes.count){ index in
                                    Text(self.model.countryNemes[index])
                                }
                            }.labelsHidden()
                            .clipped()
                }
                Section(header: Text("Municipio")){
                    Picker(selection: $model.selectedCity, label: Text("")){
                        ForEach(0 ..< model.cityNamesCount,id: \.self){ index in
                            Text(self.model.cityNames[index])
                            
                        }
                    }
                    
                    // !! changing views id force SwiftUI to recreate it !!
                    //.id(model.id)

                    .labelsHidden()
                    .clipped()
                }
                Section(header: Text("Direccion")){
                TextField("Direccion",text: $direccion)
                TextField("Referencia",text: $referencia)
                TextField("Telefono",text: $telefono)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.numberPad)
                TextField("Correo",text: $correo)
                    .textContentType(.emailAddress)
                    TextField("Nota",text: $nota)
                }
                Section{
                    NavigationLink(destination: FormasDePago(codigodepar: codigodep, nombremun: municipio, nombre: nombre, apellido: apellido, nombrerecibe: nombrerecibe, direccion: direccion, referencia: referencia, telefono: telefono, correo: correo, dui: dui, nota: nota)){ Text("Formas de Pago")
                    }
                }
            .navigationBarTitle(Text("Ingreso Datos"))
            
        }
    }
}

struct FormasDePago: View{
    var codigodepar : String
    var nombremun : String
    var nombre : String
    var apellido : String
    var nombrerecibe : String
    var direccion : String
    var referencia : String
    var telefono : String
    var correo : String
    var dui : String
    var nota : String
    
    @State var envioselected = 0
    @State var pagoselected = 0
    @ObservedObject var formasEnvio = Envios()
    @ObservedObject var formasPago = Pagos()
    
    func datosdeenvio(){
        if codigodepar == "SV-LL" || codigodepar == "SV-SS"{
            
        }
    }
     let total = CarritoView().totaltotal
   
    
    var body: some View{
       
            Form{
                Section(header: Text("Forma de Envio")){
                    Picker(selection: $envioselected, label: Text("Formas Envio")){
                        ForEach(0 ..< formasEnvio.envioslist.count){
                            if self.formasEnvio.envioslist[$0].enabled{
                                Text(self.formasEnvio.envioslist[$0].title)
                            }
                    }
                }
                    Text("\(formasEnvio.envioslist[envioselected].settings.cost?.value ?? "0")")
                    //Text("Hola")
                }
                Section(header: Text("Forma de Pago")){
                    Picker(selection: $pagoselected, label: Text("Formas Pago")){
                            ForEach(0 ..< formasPago.pagoslist.count){index in
                                if self.formasPago.pagoslist[index].enabled{
                                    Text(self.formasPago.pagoslist[index].title)
                                }
                        }
                    
                    }
                    
                    Text(formasPago.pagoslist[pagoselected].description)
                    if formasPago.pagoslist[pagoselected].id == "pagadito"{
                        Text("\(total+(total*0.05)+0.25)")
                    }else{
                        Text("\(total)")
                    }
                    
                }
                    
                Section(header: Text("Guardar")){
                    Button(action: {
                        let total = CarritoView().totaltotal
                        
                       
//
                            print(total)
//                        print(self.codigodepar)
//                        print(self.nombre)
//                        print(self.apellido)
                   
                        
                    }){
                        Text("Guardar")
                    }
                }
                .navigationBarTitle(Text("Forma de pago/envio"))
            }
        
    }
}



//metodo para sumar el valor de todos los productos en el carrito
func sumtotal() -> Double{
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return 0.0}
    
    var amountTotal : Double = 0
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let keypathExp1 = NSExpression(forKeyPath: "total")
    let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp1])
    let sumDesc = NSExpressionDescription()
    sumDesc.expression = expression
    sumDesc.name = "sum"
    sumDesc.expressionResultType = .doubleAttributeType
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Carrito")
    request.returnsObjectsAsFaults = false
    request.propertiesToFetch = [sumDesc]
    request.resultType = .dictionaryResultType
    
    do {
        let results = try managedContext.fetch(request)
        let resultMap = results[0] as! [String:Double]
        amountTotal = resultMap["sum"]!
        //print(amountTotal)
    } catch let error as NSError {
        NSLog("Error when summing amounts: \(error.localizedDescription)")
    }
    
    return amountTotal
}


//ObservableObject de los departamentos en la que mostraremos una lista de los depart
class Departaments: ObservableObject {

    let objectWillChange = PassthroughSubject<Departaments,Never>()

    var departamentslist = [Departamentos](){
        willSet{
            objectWillChange.send(self)
        }
    }
    init() {

        guard let url = URL(string: "http://clickbox.com.sv/clickbox/WebServices/ios-statesAndPlaces.php") else{return}
        URLCache.shared.removeAllCachedResponses()
        URLSession.shared.dataTask(with: url) {(data,_,_) in
            guard let data=data else{return}
            let departament = try! JSONDecoder().decode([Departamentos].self, from: data)
            //print(departament)

            DispatchQueue.main.async {
                self.departamentslist = departament
            }

        }.resume()
    }

}


class Envios: ObservableObject {
    

    let objectWillChange = PassthroughSubject<Envios,Never>()

    var envioslist = [FormasEnvio](){
        willSet{
            objectWillChange.send(self)
        }
    }
    init() {

        guard let url = URL(string: "http://clickbox.com.sv/clickbox/WebServices/formasdeentregaiOS.php?idmetod=58") else{return}
        URLCache.shared.removeAllCachedResponses()
        URLSession.shared.dataTask(with: url) {(data,_,_) in
            guard let data=data else{return}
            let envio = try! JSONDecoder().decode([FormasEnvio].self, from: data)
            //print(departament)

            DispatchQueue.main.async {
                self.envioslist = envio
            }

        }.resume()
    }

}

class Pagos: ObservableObject {

    let objectWillChange = PassthroughSubject<Pagos,Never>()

    var pagoslist = [FormasPago](){
        willSet{
            objectWillChange.send(self)
        }
    }
    init() {

        guard let url = URL(string: "http://clickbox.com.sv/clickbox/WebServices/formasdepagoiOS.php") else{return}
        URLCache.shared.removeAllCachedResponses()
        URLSession.shared.dataTask(with: url) {(data,_,_) in
            guard let data=data else{return}
            let pago = try! JSONDecoder().decode([FormasPago].self, from: data)
            //print(departament)

            DispatchQueue.main.async {
                self.pagoslist = pago
            }

        }.resume()
    }

}


