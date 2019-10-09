//
//  CameraView.swift
//  Carrot
//
//  Created by Charlie on 23/8/19.
//  Copyright © 2019 Schacher. All rights reserved.
//

import Foundation
import UIKit

class CameraView: UIView {

	let cameraImage = UIImageView()
	let emojiLabel = UILabel()

	init(forEmoji: Bool = false) {
		super.init(frame: CGRect.zero)
		
		self.layer.cornerRadius = 14
		self.layer.borderWidth = 4
		self.layer.borderColor = UIColor.white.cgColor
		self.layer.shadowRadius = 4
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOpacity = 1.0
		self.layer.shadowOffset = .zero
		
		cameraImage.backgroundColor = UIColor.black
		cameraImage.contentMode = .scaleAspectFit
		cameraImage.layer.cornerRadius = 14
		cameraImage.clipsToBounds = true
		
		if forEmoji { emojiLabel.text = "😐" }
		
		emojiLabel.font = UIFont.systemFont(ofSize: 40)
		emojiLabel.textAlignment = .center
	
		cameraImage.translatesAutoresizingMaskIntoConstraints = false
		emojiLabel.translatesAutoresizingMaskIntoConstraints = false
	
		self.addSubview(cameraImage)
		self.addSubview(emojiLabel)
		
		self.addConstraints([
			
			// Camera Image
			NSLayoutConstraint(item: cameraImage, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: cameraImage, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: cameraImage, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: cameraImage, attribute: .bottom, multiplier: 1.0, constant: 0),
			
			// Emoji Label
			NSLayoutConstraint(item: emojiLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: emojiLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: emojiLabel, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: emojiLabel, attribute: .bottom, multiplier: 1.0, constant: 0)
		
		])
	
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func animateFaces(emojiArray: Array<String>, emotionDelay: Double) {
	
		if emojiArray.count == 0 { return }
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + emotionDelay + 0.15, execute: { [weak self] in
			guard let safe = self else { return }
			safe.emojiLabel.text = emojiArray[0]
		})
		
		UIView.animate(withDuration: 0.3, delay: emotionDelay, animations: { [weak self] in
			guard let safe = self else { return }
			safe.emojiLabel.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
		}, completion: { animated in
			
			UIView.animate(withDuration: 0.7, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { [weak self] in
			   guard let safe = self else { return }
			   safe.emojiLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
			}, completion: { [weak self] animated in
				guard let safe = self else { return }
				safe.animateFaces(emojiArray: Array(emojiArray.dropFirst()), emotionDelay: 0.5)
			})
	
		})
	
	}
	
}




