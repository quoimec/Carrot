//
//  FaceDelegate.swift
//  Carrot
//
//  Created by Charlie on 25/8/19.
//  Copyright © 2019 Schacher. All rights reserved.
//

import Foundation
import UIKit
import ARKit

protocol FaceDelegate: class {

	func faceUpdate(passedImage: UIImage)

	func emotionUpdate(passedEmotion: String)

}

