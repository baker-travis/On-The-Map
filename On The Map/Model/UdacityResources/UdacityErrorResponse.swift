//
//  UdacityErrorResponse.swift
//  On The Map
//
//  Created by Travis Baker on 12/7/18.
//  Copyright © 2018 Travis Baker. All rights reserved.
//

import Foundation

struct UdacityErrorResponse: Codable {
    let status: Int
    let error: String
}
