//
//  FestApp.swift
//  FestApp
//
//  Created by Oleg Grenrus on 30/10/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

import Foundation
import UIKit

// could use extension on UIColor though?
func UIColorHex(r: UInt8, g: UInt8, b: UInt8) -> UIColor {
    return UIColor(
        red: CGFloat(r)/255.0,
        green: CGFloat(b)/255.0,
        blue: CGFloat(g)/255.0,
        alpha: 1.0
    )
}

let FEST_COLOR_GOLD = UIColorHex(204, 153, 0)
