//
//  StudentLocationsModel.swift
//  On The Map
//
//  Created by Travis Baker on 12/12/18.
//  Copyright © 2018 Travis Baker. All rights reserved.
//

import Foundation

extension Notification.Name {
    static var studentLocationsListUpdated: Notification.Name {
        return .init(rawValue: "StudentLocationModel.listUpdated")
    }
}

class StudentLocationsModel {
    private static let notificationCenter: NotificationCenter = NotificationCenter.default
    
    static var studentLocations: [StudentLocation] = [] {
        didSet {
            notificationCenter.post(name: .studentLocationsListUpdated, object: studentLocations)
        }
    }
}
