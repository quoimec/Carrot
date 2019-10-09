//
//  ActionView.swift
//  Carrot
//
//  Created by Charlie on 23/8/19.
//  Copyright © 2019 Schacher. All rights reserved.
//

import Foundation
import UIKit

class ActionButton: UIView {

	let buttonType: ButtonType
	private let buttonLabel = UILabel()

	init(buttonType: ButtonType) {
		self.buttonType = buttonType
		super.init(frame: CGRect.zero)
		
		self.layer.cornerRadius = 16
		
		buttonLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		buttonLabel.textAlignment = .center
		buttonLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		
		switch buttonType {
		
			case .NewGame:
			buttonLabel.text = "New Game"
			self.backgroundColor = #colorLiteral(red: 0.41, green: 0.85, blue: 0.53, alpha: 1.00)
			
			case .PlayAgain:
			buttonLabel.text = "Play Again"
			self.backgroundColor = #colorLiteral(red: 0.41, green: 0.85, blue: 0.53, alpha: 1.00)
			
			case .OpenBox:
			buttonLabel.text = "Open Your Box"
			self.backgroundColor = #colorLiteral(red: 0.85, green: 0.34, blue: 0.42, alpha: 1.00)
			
			case .KeepBox:
			buttonLabel.text = "Keep Your Box"
			self.backgroundColor = #colorLiteral(red: 0.34, green: 0.81, blue: 0.85, alpha: 1.00)
			
			case .SwapBox:
			buttonLabel.text = "Switch Boxes"
			self.backgroundColor = #colorLiteral(red: 0.89, green: 0.76, blue: 0.36, alpha: 1.00)
			
			case .ResetSession:
			buttonLabel.text = "Reset Session"
			self.backgroundColor = #colorLiteral(red: 0.2059803299, green: 0.2059803299, blue: 0.2059803299, alpha: 1)
			
		}
		
		buttonLabel.translatesAutoresizingMaskIntoConstraints = false
		
		self.addSubview(buttonLabel)
		
		self.addConstraints([
		
			// Button Label
			NSLayoutConstraint(item: buttonLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: buttonLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 12),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: buttonLabel, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: buttonLabel, attribute: .bottom, multiplier: 1.0, constant: 12)
			
		])
	
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
