//
//  UdacityAPI.swift
//  On The Map
//
//  Created by Travis Baker on 12/7/18.
//  Copyright © 2018 Travis Baker. All rights reserved.
//

import Foundation

class UdacityAPI {
    static var auth: UdacityAuthResponse?
    static var userInfo: UdacityStudentInfo?
    
    enum Errors: Error, LocalizedError {
        case loginFailure(message: String)
        case logoutFailure(message: String)
        case userInfoFailure(message: String)
        
        var errorDescription: String? {
            switch self {
            case .loginFailure(let message),
                 .logoutFailure(let message),
                 .userInfoFailure(let message):
                return message
            }
        }
    }
    
    enum Endpoints {
        case deleteSession
        case newSession
        case getUserInfo
        
        var url: URL? {
            return URL(string: self.valueForCase)
        }
        
        var valueForCase: String {
            switch self {
            case .newSession:
                return "https://onthemap-api.udacity.com/v1/session"
            case .getUserInfo:
                if let authKey = auth?.account.key {
                    return "https://onthemap-api.udacity.com/v1/users/\(authKey)"
                } else {
                    return ""
                }
            case .deleteSession:
                return "https://onthemap-api.udacity.com/v1/session"
            }
        }
    }
    
    class func logIn(username: String, password: String, handler: @escaping (_ success: Bool, Error?) -> Void) {
        let url = Endpoints.newSession.url!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // encoding a JSON body from a string, can also use a Codable struct
        let requestBody: [String: [String: String]] = [
            "udacity": [
                "username": username,
                "password": password
            ]
        ]
        request.httpBody = try? JSONEncoder().encode(requestBody)
//        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                DispatchQueue.main.async {
                    handler(false, error)
                }
                return
            }
            
            guard let newData = data?.dropFirst(5) else { /* subset response data! */
                DispatchQueue.main.async {
                    handler(false, nil)
                }
                return
            }
            
            if let newAuthData = try? JSONDecoder().decode(UdacityAuthResponse.self, from: newData) {
                DispatchQueue.main.async {
                    handler(true, nil)
                }
                self.auth = newAuthData
            } else if let errorResponse = try? JSONDecoder().decode(UdacityErrorResponse.self, from: newData) {
                DispatchQueue.main.async {
                    handler(false, Errors.loginFailure(message: errorResponse.error))
                }
            }
        }
        task.resume()
    }
    
    class func logOut(_ completionHandler: @escaping (_ success: Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.deleteSession.url!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
                
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                DispatchQueue.main.async {
                    completionHandler(false, error!)
                }
                return
            }
            
            guard let newData = data?.dropFirst(5) else { /* subset response data! */
                DispatchQueue.main.async {
                    completionHandler(false, Errors.logoutFailure(message: "Could not parse response"))
                }
                return
            }
            
            if (try? JSONDecoder().decode(UdacityDeleteSessionResponse.self, from: newData)) != nil {
                self.auth = nil
                self.userInfo = nil
                OnTheMapAPI.objectId = nil
                DispatchQueue.main.async {
                    completionHandler(true, nil)
                }
            } else if let errorResponse = try? JSONDecoder().decode(UdacityErrorResponse.self, from: newData) {
                DispatchQueue.main.async {
                    completionHandler(false, Errors.logoutFailure(message: errorResponse.error))
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(false, Errors.logoutFailure(message: "Unknown error. Please try again later."))
                }
            }
        }
        task.resume()
    }
    
    class func getUserInfo(_ completionHandler: ((UdacityStudentInfo?, Error?) -> Void)?) {
        let request = URLRequest(url: Endpoints.getUserInfo.url!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                completionHandler?(nil, error!)
                return
            }
            
            guard let newData = data?.dropFirst(5) else { /* subset response data! */
                DispatchQueue.main.async {
                    completionHandler?(nil, Errors.userInfoFailure(message: "Could not parse response"))
                }
                return
            }
            
            if let studentInfo = try? JSONDecoder().decode(UdacityStudentInfo.self, from: newData) {
                DispatchQueue.main.async {
                    completionHandler?(studentInfo, nil)
                    self.userInfo = studentInfo
                }
            } else if let errorResponse = try? JSONDecoder().decode(UdacityErrorResponse.self, from: newData) {
                DispatchQueue.main.async {
                    completionHandler?(nil, Errors.userInfoFailure(message: errorResponse.error))
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler?(nil, Errors.userInfoFailure(message: "Unknown error. Please try again later."))
                }
            }
        }
        task.resume()
    }
}
