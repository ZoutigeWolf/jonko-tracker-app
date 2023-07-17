//
//  LoginManager.swift
//  Jonko Tracker
//
//  Created by ZoutigeWolf on 17/07/2023.
//

import Foundation

class LoginManager {
    static let shared: LoginManager = LoginManager()
    private let baseUrl: String = "http://127.0.0.1"
    
    var currentUser: User? = nil
    
    func login(email: String, password: String) {
        let url = URL(string: "\(baseUrl)/login")
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
        })
    }
    
    func logout() {
        
    }
}

struct User {
    let id: Int
    let username: String
    let email: String
}
