//
//  OnTheMapAPI.swift
//  On The Map
//
//  Created by Travis Baker on 12/7/18.
//  Copyright © 2018 Travis Baker. All rights reserved.
//

import Foundation

class OnTheMapAPI {
    static let applicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static let endpoint = "https://parse.udacity.com/parse/classes/StudentLocation"
    static var objectId: String?
    
    enum Errors: LocalizedError {
        case unknownError
        case queryReturnedNoResults
        case genericError(message: String)
        
        var errorDescription: String? {
            switch self {
            case .unknownError:
                return "An unknown error occurred. Please try again later."
            case .queryReturnedNoResults:
                return "No results were found from your query."
            case .genericError(let message):
                return message
            }
        }
    }
    
    enum LocationFilterOptions {
        case limit(Int)
        case skip(Int)
        case order(Order, ascending: Bool)
        
        enum Order: String {
            case updatedAt
        }
        
        var queryItem: URLQueryItem {
            var key, value: String
            switch self {
            case let .limit(length):
                key = "limit"
                value = "\(length)"
            case let .skip(length):
                key = "skip"
                value = "\(length)"
            case let .order(order, ascending):
                key = "order"
                value = "\(ascending ? "" : "-")\(order.rawValue)"
            }
            
            return URLQueryItem(name: key, value: value)
        }
    }
    
    class func getListOfStudentLocations(options: [LocationFilterOptions]?, completionHandler: @escaping ([StudentLocation], Error?) -> Void) {
        var urlComponents = URLComponents(string: endpoint)!
        var queryItems: [URLQueryItem] = []
        options?.forEach({ (option) in
            queryItems.append(option.queryItem)
        })
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            print("Could not generate url with query params")
            return
        }
        var request = URLRequest(url: url)
        request.addValue(applicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler([], error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler([], Errors.genericError(message: "Could not parse response. Please try again later."))
                }
                return
            }
            
            do {
                let studentLocations = try JSONDecoder().decode(StudentLocationResponse.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(studentLocations.results, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler([], error)
                }
            }
        }
        task.resume()
    }
    
    class func getStudentLocation(uniqueKey: String, completionHandler: @escaping ((StudentLocation?, Error?) -> Void)) {
        var urlComponents = URLComponents(string: endpoint)
        urlComponents?.queryItems = [URLQueryItem(name: "where", value: "{\"uniqueKey\":\"\(uniqueKey)\"}")]
        var request = URLRequest(url: urlComponents!.url!)
        request.addValue(applicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, Errors.genericError(message: "Could not parse response. Please try again later."))
                }
                return
            }
            
            if let locationList = try? JSONDecoder().decode(StudentLocationResponse.self, from: data) {
                if locationList.results.count > 0 {
                    DispatchQueue.main.async {
                        completionHandler(locationList.results[0], nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completionHandler(nil, Errors.queryReturnedNoResults)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(nil, Errors.genericError(message: "Could not get location from response."))
                }
            }
            
            print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
    }
    
    class func postNewStudentLocation(_ location: StudentLocation, completionHandler: @escaping (Bool, Error?) -> Void) {
        let url = URL(string: endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(applicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(location)
//        request.httpBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Cupertino, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.322998, \"longitude\": -122.032182}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                DispatchQueue.main.async {
                    completionHandler(false, error!)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(false, Errors.genericError(message: "Could not parse response. Please try again later."))
                }
                return
            }
            
            if let responseDict = try? JSONDecoder().decode([String: String].self, from: data), let objectId = responseDict["objectId"] {
                self.objectId = objectId
                DispatchQueue.main.async {
                    completionHandler(true, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(false, Errors.genericError(message: "Could not get location result from response."))
                }
            }
            print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
    }
    
    class func updateStudentLocation(_ location: StudentLocation, objectId: String, completionHandler: @escaping (Bool, Error?) -> Void) {
        var url = URL(string: endpoint)!
        url.appendPathComponent(objectId)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue(applicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(location)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                DispatchQueue.main.async {
                    completionHandler(false, error!)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(false, Errors.genericError(message: "Could not parse response. Please try again later."))
                }
                return
            }
            
            if let responseData = try? JSONDecoder().decode([String: String].self, from: data), let _ = responseData["updatedAt"] {
                DispatchQueue.main.async {
                    completionHandler(true, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(false, Errors.genericError(message: "Could not get location result from response."))
                }
            }
            print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
    }
}
