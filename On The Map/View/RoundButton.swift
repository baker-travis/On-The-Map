//
//  RoundButton.swift
//  On The Map
//
//  Created by Travis Baker on 12/7/18.
//  Copyright © 2018 Travis Baker. All rights reserved.
//

import UIKit

@IBDesignable class RoundButton: UIButton {
    @IBInspectable var borderRadius: Int = 0 {
        didSet {
            self.layer.cornerRadius = CGFloat(integerLiteral: borderRadius)
        }
    }
}
