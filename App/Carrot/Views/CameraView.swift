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

	init() {
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
	
		cameraImage.translatesAutoresizingMaskIntoConstraints = false
	
		self.addSubview(cameraImage)
		
		self.addConstraints([
			
			// Camera Image
			NSLayoutConstraint(item: cameraImage, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: cameraImage, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: cameraImage, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: cameraImage, attribute: .bottom, multiplier: 1.0, constant: 0)
		
		])
	
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}




