//
//  StudentLocationTitleAnnotation.swift
//  On The Map
//
//  Created by Travis Baker on 12/10/18.
//  Copyright © 2018 Travis Baker. All rights reserved.
//

import UIKit
import MapKit

class StudentLocationTitleAnnotation: NSObject, MKAnnotation {
    let studentLocation: StudentLocation
    
    init(location: StudentLocation) {
        self.studentLocation = location
    }
    
    var coordinate: CLLocationCoordinate2D {
        guard let longitude = studentLocation.longitude,
            let latitudeCoord = CLLocationDegrees(exactly: studentLocation.latitude),
            let longitudeCoord = CLLocationDegrees(exactly: longitude) else {
                return CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: 0)!, longitude: CLLocationDegrees(exactly: 0)!)
        }
        return CLLocationCoordinate2D(latitude: latitudeCoord, longitude: longitudeCoord)
    }
    
    var title: String? {
        return "\(studentLocation.mapString ?? "Not Available")"
    }
}
