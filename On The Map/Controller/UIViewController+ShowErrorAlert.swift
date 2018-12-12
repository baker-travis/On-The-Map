//
//  Util.swift
//  On The Map
//
//  Created by Travis Baker on 12/11/18.
//  Copyright © 2018 Travis Baker. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
