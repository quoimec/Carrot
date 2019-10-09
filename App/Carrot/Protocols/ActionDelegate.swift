//
//  ActionDelegate.swift
//  Carrot
//
//  Created by Charlie on 23/8/19.
//  Copyright © 2019 Schacher. All rights reserved.
//

import Foundation

protocol ActionDelegate: class {

	func newGame()
	
	func playAgain()
	
	func openBox()
	
	func swapBox()
	
	func keepBox()
	
	func watchVideo()
	
	func resetSession()

}
