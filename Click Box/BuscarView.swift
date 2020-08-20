//
//  BuscarView.swift
//  Click Box
//
//  Created by Julio Landaverde
//  Copyright © 2020 Facebook. All rights reserved.
//

import SwiftUI

struct BuscarView: View {
    @State var username: String = ""
    @State var password: String = ""
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
                .background(Color(UIColor.lightGray))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            SecureField("Password", text: $password)
                .padding()
                .background(Color(UIColor.lightGray))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            Button(action: {print("Button tapped")}) {
               LoginButtonContent()
            }
           }
            .padding()

    }
}

struct BuscarView_Previews: PreviewProvider {
    static var previews: some View {
        BuscarView()
    }
}
struct LoginButtonContent : View {
    var body: some View {
        return Text("LOGIN")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.green)
            .cornerRadius(15.0)
    }
}
