//
//  OverView.swift
//  Carrot
//
//  Created by Charlie on 25/8/19.
//  Copyright © 2019 Schacher. All rights reserved.
//

import Foundation
import UIKit

class OverView: UIView {

	private let emojiLabel = UILabel()
	private let finalLabel = UILabel()
	
	init(playerWon: Bool) {
		super.init(frame: CGRect.zero)
		
		finalLabel.textColor = #colorLiteral(red: 0.17, green: 0.17, blue: 0.17, alpha: 1.00)
		finalLabel.numberOfLines = 0
		emojiLabel.font = UIFont.systemFont(ofSize: 50)
		finalLabel.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
		
		if playerWon {
			emojiLabel.text = "🎉"
			finalLabel.text = "Congratulations\nYou Won!"
		} else {
			emojiLabel.text = "🤖"
			finalLabel.text = "Commiserations\nYou Lost!"
		}
		
		emojiLabel.translatesAutoresizingMaskIntoConstraints = false
		finalLabel.translatesAutoresizingMaskIntoConstraints = false
	
		self.addSubview(emojiLabel)
		self.addSubview(finalLabel)
	
		self.addConstraints([
		
			// Emoji Label
			NSLayoutConstraint(item: emojiLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 6),
			NSLayoutConstraint(item: emojiLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: emojiLabel, attribute: .bottom, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: emojiLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 65),
			
			// Final Label
			NSLayoutConstraint(item: finalLabel, attribute: .leading, relatedBy: .equal, toItem: emojiLabel, attribute: .trailing, multiplier: 1.0, constant: 4),
			NSLayoutConstraint(item: finalLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: finalLabel, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: finalLabel, attribute: .bottom, multiplier: 1.0, constant: 0)
		
		])
	
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	

}
