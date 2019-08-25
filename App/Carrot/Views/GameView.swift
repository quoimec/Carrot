//
//  GameView.swift
//  Carrot
//
//  Created by Charlie on 23/8/19.
//  Copyright © 2019 Schacher. All rights reserved.
//

import Foundation
import UIKit

class GameView: UIView {

	private let boxContainer = UIView()
	let agentBox = GameBox()
	let playerBox = GameBox()

	init() {
		super.init(frame: CGRect.zero)
		
		self.backgroundColor = #colorLiteral(red: 0.07, green: 0.12, blue: 0.27, alpha: 1.00)
		
		boxContainer.translatesAutoresizingMaskIntoConstraints = false
		agentBox.translatesAutoresizingMaskIntoConstraints = false
		playerBox.translatesAutoresizingMaskIntoConstraints = false
		
		boxContainer.addSubview(agentBox)
		boxContainer.addSubview(playerBox)
		self.addSubview(boxContainer)
		
		self.addConstraints([
		
			// Box Container
			NSLayoutConstraint(item: boxContainer, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.3, constant: 0),
			NSLayoutConstraint(item: boxContainer, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: boxContainer, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 14)
		
		])
		
		boxContainer.addConstraints([
		
			// Agent Box
			NSLayoutConstraint(item: agentBox, attribute: .leading, relatedBy: .equal, toItem: boxContainer, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: agentBox, attribute: .top, relatedBy: .equal, toItem: boxContainer, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: boxContainer, attribute: .trailing, relatedBy: .equal, toItem: agentBox, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: boxContainer, attribute: .centerY, relatedBy: .equal, toItem: agentBox, attribute: .bottom, multiplier: 1.0, constant: 14),
			NSLayoutConstraint(item: agentBox, attribute: .height, relatedBy: .equal, toItem: boxContainer, attribute: .width, multiplier: 1.0, constant: 0),
			
			// Player Box
			NSLayoutConstraint(item: playerBox, attribute: .leading, relatedBy: .equal, toItem: boxContainer, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: playerBox, attribute: .top, relatedBy: .equal, toItem: boxContainer, attribute: .centerY, multiplier: 1.0, constant: 14),
			NSLayoutConstraint(item: boxContainer, attribute: .trailing, relatedBy: .equal, toItem: playerBox, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: boxContainer, attribute: .bottom, relatedBy: .equal, toItem: playerBox, attribute: .bottom, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: playerBox, attribute: .height, relatedBy: .equal, toItem: boxContainer, attribute: .width, multiplier: 1.0, constant: 0),
			
		])
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func swapBoxes() {
	
		agentBox.close()
		playerBox.close()
	
		UIView.animate(withDuration: 2.4, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveLinear, animations: {
			self.boxContainer.transform = CGAffineTransform(rotationAngle: 180°)
			self.agentBox.transform = CGAffineTransform(rotationAngle: -0.999 * 180°)
			self.playerBox.transform = CGAffineTransform(rotationAngle: -0.999 * 180°)
		}, completion: { animated in
			self.boxContainer.transform = CGAffineTransform.identity
			self.agentBox.transform = CGAffineTransform.identity
			self.playerBox.transform = CGAffineTransform.identity
		})
		
	}
	
	func keepBoxes(whichPlayer: Carrot.Player) {
	
		agentBox.close()
		playerBox.close()
		
		var whichBox: GameBox
		
		switch whichPlayer {
		
			case .Human:
			whichBox = playerBox
			
			case .Agent:
			whichBox = agentBox
		
		}
		
		UIView.animate(withDuration: 0.4, delay: 0.0, animations: {
			whichBox.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
		}, completion: { animated in
			UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
				whichBox.transform = CGAffineTransform.identity
			})
		})
		
	}
	
}

class GameBox: UIImageView {

	init() {
		super.init(image: UIImage(named: "ClosedBox"))
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func open(withCarrot: Bool) {
		if withCarrot {
			self.image = UIImage(named: "CarrotBox")
		} else {
			self.image = UIImage(named: "EmptyBox")
		}
	}
	
	func censor() {
		self.image = UIImage(named: "CensoredBox")
	}
	
	func close() {
		self.image = UIImage(named: "ClosedBox")
	}

}
