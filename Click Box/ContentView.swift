//
//  ContentView.swift
//  Click Box
//
//  Created by Julio Landaverde
//  Copyright © 2020 Facebook. All rights reserved.
//

import SwiftUI
import Combine





let items: [BottomBarItem] = [
    BottomBarItem(icon: "house.fill", title: "Home", color: .purple),
    BottomBarItem(icon: "heart", title: "Favoritos", color: .pink),
    BottomBarItem(icon: "cart", title: "Carrito", color: .green),
    BottomBarItem(icon: "magnifyingglass", title: "Buscar", color: .orange),
    BottomBarItem(icon: "person.fill", title: "Cuenta", color: .blue)
]



struct ContentView: View {
    @State private var selectedIndex: Int = 0

       var selectedItem: BottomBarItem {
           items[selectedIndex]
       }
    
    
    var body: some View {
        TabView{
            HomeView().tabItem({
                Image(uiImage: UIImage(named: "home")!)
                    .resizable()
//                    .frame(minWidth: 24, idealWidth: 32, maxWidth: 32, minHeight: 24, idealHeight: 32, maxHeight: 32, alignment: .center)
                    
                
                    
                Text("Home")
                }).tag(0)
            
            FavoritoView().tabItem({
                Image(uiImage: UIImage(named: "likeclickbox-1")!)
//                .font(.system(size: 14))
                
            
                
            Text("Favoritos")
            }).tag(1)
            
            CarritoView().tabItem({
                            Image(uiImage: UIImage(named: "carrito-1")!)
            //                .font(.system(size: 14))
                            
                        
                            
                        Text("Carrito")
                        }).tag(2)
            BuscarView().tabItem({
                            Image(uiImage: UIImage(named: "perfilclickbox")!)
                        Text("Mi cuenta")
                        }).tag(3)
        }
       
//            VStack{
//
//
//          BottomBar(selectedIndex: self.$selectedIndex, items: items)
//            }
                
            
        
        
    }
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



public struct BottomBarItem {
    public let icon: String
    public let title: String
    public let color: Color
    
    public init(icon: String,
                title: String,
                color: Color) {
        self.icon = icon
        self.title = title
        self.color = color
    }
}

public struct BottomBarItemView: View {
    public let isSelected: Bool
    public let item: BottomBarItem
    
    public var body: some View {
        VStack {
            Image(systemName: item.icon)
                .imageScale(.large)
                .foregroundColor(isSelected ? item.color : .primary)
            
            if isSelected {
                Text(item.title)
                    .foregroundColor(item.color)
                    .fontWeight(.light)
                    .fixedSize()
            }
        }
        .padding()
//        .background(
//            Capsule()
//                .fill(isSelected ? item.color.opacity(0.2) : Color.clear)
//        )
    }
}

// bottom bar/barra navegacion
struct BottomBar : View{
    @Binding public var selectedIndex: Int
    
    public let items: [BottomBarItem]
    
    public init(selectedIndex: Binding<Int>, items: [BottomBarItem]) {
        self._selectedIndex = selectedIndex
        self.items = items
    }
    
    func itemView(at index: Int) -> some View {
        Button(action: {
            withAnimation { self.selectedIndex = index }
        }) {
            BottomBarItemView(isSelected: index == selectedIndex, item: items[index])
        }
    }
    
    public var body: some View {
        HStack(alignment: .bottom) {
            ForEach(0..<items.count) { index in
                self.itemView(at: index)
                
                if index != self.items.count-1 {
                    Spacer()
                }
            }
        }
        .padding()
        .animation(.default)
    }
    
    
}


