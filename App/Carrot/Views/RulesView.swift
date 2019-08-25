//
//  RulesView.swift
//  Carrot
//
//  Created by Charlie on 24/8/19.
//  Copyright © 2019 Schacher. All rights reserved.
//

import Foundation
import UIKit

class RulesView: UIView {

	let rulesHeader = UILabel()
	let rulesContent = UILabel()
	let videoPreview = UIImageView()
	
	init() {
		super.init(frame: CGRect.zero)
		
		rulesHeader.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
		rulesContent.font = UIFont.systemFont(ofSize: 16, weight: .medium)
		
		rulesContent.numberOfLines = 0
		videoPreview.isUserInteractionEnabled = true
		
		rulesHeader.text = "How To Play"
		rulesContent.text = "Carrot In A Box is a simple game involving two players, you and a Reinforcement Learning agent. The point of this game is to end up with the carrot.\n\nThe game begins with you looking inside of your box and seeing if you have the carrot. You then get to choose if you want to switch boxes with the agent or keep your box. The agent will then try and guess which box it thinks has the carrot. It does this by tracking your facial expressions and eye gaze. If the agent picks the box without the carrot, you win! If the agent picks the box with carrot, then unfortunately you loose.\n\nTap on the video below to watch the original version of the game on 8 out of 10 Cats."
		videoPreview.image = UIImage(named: "CarrotPreview")
	
		rulesHeader.translatesAutoresizingMaskIntoConstraints = false
		rulesContent.translatesAutoresizingMaskIntoConstraints = false
		videoPreview.translatesAutoresizingMaskIntoConstraints = false
	
		self.addSubview(rulesHeader)
		self.addSubview(rulesContent)
		self.addSubview(videoPreview)
		
		self.addConstraints([
		
			// Rules Header
			NSLayoutConstraint(item: rulesHeader, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: rulesHeader, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 20),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: rulesHeader, attribute: .trailing, multiplier: 1.0, constant: 24),
			
			// Rules Content
			NSLayoutConstraint(item: rulesContent, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: rulesContent, attribute: .top, relatedBy: .equal, toItem: rulesHeader, attribute: .bottom, multiplier: 1.0, constant: 12),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: rulesContent, attribute: .trailing, multiplier: 1.0, constant: 24),
			
			// Video Preview
			NSLayoutConstraint(item: videoPreview, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: videoPreview, attribute: .top, relatedBy: .equal, toItem: rulesContent, attribute: .bottom, multiplier: 1.0, constant: 30),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: videoPreview, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: videoPreview, attribute: .bottom, multiplier: 1.0, constant: Phone.rounded ? 100 : 60),
			NSLayoutConstraint(item: videoPreview, attribute: .height, relatedBy: .equal, toItem: videoPreview, attribute: .width, multiplier: 0.625, constant: 0)
		
		])
	
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
