//
//  Taptics.swift
//  Breakout
//
//  Created by Albertino Padin on 4/18/16.
//  Copyright © 2016 Albertino Padin. All rights reserved.
//

import Foundation

enum Taptics: UInt32 {
    case Peek = 1519    // Weak tap
    case Pop = 1520     // Strong tap
    case Nope = 1521    // Three weak taps
}