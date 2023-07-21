//
//  LoginManager.swift
//  Jonko Tracker
//
//  Created by ZoutigeWolf on 17/07/2023.
//

import Foundation

class LoginManager {
    static let shared: LoginManager = LoginManager()
    
    private let baseUrl: String = "http://127.0.0.1:42069"
    
    var currentUser: User? = nil
    
    private var rememberToken: String? = nil
    private var session: String? = nil
    
    func login(email: String, password: String, onCompletion: @escaping () -> Void, onError: @escaping (_ err: String) -> Void) -> Void {
        guard let url = URL(string: "\(baseUrl)/login") else {
            onError("Error: url = nil")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: [
                "email": email,
                "password": password,
                "remember": true
            ] as [String : Any], options: [])
        } catch {
            onError("Error: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                onError("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                onError("Error: response = nil")
                return
            }
            
            guard let data = data else {
                onError("Error: data = nil")
                return
            }
            
            if httpResponse.statusCode != 200 {
                onError("Error: \(data)")
                return
            }
            
            guard let cookieString = httpResponse.allHeaderFields["Set-Cookie"] as? String else {
                onError("Error: cookies = nil")
                return
            }

            let cookies = getCookies(cookieString: cookieString)
            
            let rememberToken = cookies["remember_token"]
            let session = cookies["session"]
            
            if rememberToken == nil {
                onError("Error: cookie-rememberToken = nil")
                return
            }
            
            if session == nil {
                onError("Error: cookie-session = nil")
                return
            }
            
            self.rememberToken = rememberToken
            self.session = session
            
            self.fetchUser(onCompletion: {
                onCompletion()
            }, onError: { err in
                onError(err)
            })
        }).resume()
    }
    
    func logout() -> Void {
        
    }
    
    func fetchUser(onCompletion: @escaping () -> Void, onError: @escaping (_ err: String) -> Void) -> Void {
        guard let url = URL(string: "\(baseUrl)/api/current-user") else {
            onError("Error: url = nil")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        guard let rememberToken = self.rememberToken, let session = self.session else {
            onError("Error: authentication cookies invalid, login first")
            return
        }
        
        let cookies = [
            HTTPCookie(properties: [
                .domain: "127.0.0.1",
                .path: "/",
                .name: "remember_token",
                .value: rememberToken
            ]),
            HTTPCookie(properties: [
                .domain: "127.0.0.1",
                .path: "/",
                .name: "session",
                .value: session
            ])
        ].compactMap { $0 }
        
        if cookies.isEmpty {
            onError("Error: Failed to create cookies")
            return
        }
        
        request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                onError("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                onError("Error: response = nil")
                return
            }
            
            guard let data = data else {
                onError("Error: data = nil")
                return
            }
            
            if httpResponse.statusCode != 200 {
                onError("Error: \(data)")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                guard let jsonObject = json as? [String: Any],
                      let id = jsonObject["id"] as? Int,
                      let username = jsonObject["username"] as? String,
                      let email = jsonObject["email"] as? String
                else {
                    onError("Error: invalid JSON")
                    return
                }
                
                self.currentUser = User(id: id, username: username, email: email)
                
                onCompletion()
            } catch {
                onError("Error: \(error.localizedDescription)")
                return
            }
        }).resume()
    }
}

func getCookies(cookieString: String) -> [String: String] {
    var cookieDict = [String: String]()
    
    let cookieArray = cookieString.components(separatedBy: ", ")
    
    for cookie in cookieArray {
        let cookieParts = cookie.components(separatedBy: ";")
        
        let cookieComponents = cookieParts[0].components(separatedBy: "=")
        
        if cookieComponents.count == 2 {
            cookieDict[cookieComponents[0]] = cookieComponents[1]
        }
    }
    
    return cookieDict
}
