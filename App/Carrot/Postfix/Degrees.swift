//
//  Degrees.swift
//  Carrot
//
//  Created by Charlie on 23/8/19.
//  Copyright © 2019 Schacher. All rights reserved.
//

import Foundation
import UIKit

postfix operator °

protocol IntegerInitializable: ExpressibleByIntegerLiteral {
    init (_: Int)
}

extension Int: IntegerInitializable {
    postfix public static func °(lhs: Int) -> CGFloat {
        return CGFloat(lhs) * .pi / 180
    }
}
