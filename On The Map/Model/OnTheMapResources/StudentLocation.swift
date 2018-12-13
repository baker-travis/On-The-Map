//
//  StudentLocation.swift
//  On The Map
//
//  Created by Travis Baker on 12/7/18.
//  Copyright © 2018 Travis Baker. All rights reserved.
//

import Foundation
import MapKit

struct StudentLocation: Codable {
    let createdAt: String?
    var firstName: String
    var lastName: String
    var latitude: Double
    var longitude: Double?
    var mapString: String?
    var mediaURL: String
    let objectId: String?
    var uniqueKey: String?
    let updatedAt: String?
    
    init(firstName: String, lastName: String, latitude: Double, longitude: Double, mapString: String, mediaURL: String, uniqueKey: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.latitude = latitude
        self.longitude = longitude
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.uniqueKey = uniqueKey
        self.createdAt = nil
        self.objectId = nil
        self.updatedAt = nil
    }
}
