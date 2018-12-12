//
//  UdacityStudentInfo.swift
//  On The Map
//
//  Created by Travis Baker on 12/10/18.
//  Copyright © 2018 Travis Baker. All rights reserved.
//

import Foundation

class UdacityStudentInfo: Codable {
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
