//
//  ContentView.swift
//  Jonko Tracker
//
//  Created by ZoutigeWolf on 17/07/2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.924159, longitude: 4.477720),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Map(coordinateRegion: $region)
                    HStack {
                        NavigationLink(destination: MenuView()) {
                            Text("Menu")
                        }
                    }
                    .frame(height: 40)
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct MenuView: View {
    var body: some View {
        VStack {
            Text("Username placeholder")
            NavigationLink(destination: LoginView()) {
                Text("Logout")
            }
        }
    }
}

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        VStack {
            TextField(
                "E-Mail",
                text: $email
            )
            .autocapitalization(.none)
            
            SecureField(
                "Password",
                text: $password
            )
            HStack {
                Button("Register") {
                    
                }
                
                Button("Login") {
                    print("Logging in...")
                    print("E-Mail: \(email)")
                    print("Password: \(password)")
                    LoginManager.shared.login(
                        email: email,
                        password: password,
                        onCompletion: {
                            print(LoginManager.shared.currentUser as Any)
                        },
                        onError: {err in
                            print("Login failed")
                            print(err)
                        })
                }
            }
        }
        .padding(16)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

