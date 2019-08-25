//
//  OverlayView.swift
//  Carrot
//
//  Created by Charlie on 23/8/19.
//  Copyright © 2019 Schacher. All rights reserved.
//

import Foundation
import UIKit

class OverlayView: UIView {
	
	let grabArea = UIView()
	private let overlayHandle = UIView()
	private let actionView = UIView()
	private let scrollView = UIScrollView()
	private let rulesView = RulesView()
	private let statsView = StatsView(passedName: "Your Emotions")

	var overlayBottom: CGFloat {
		get { return grabArea.frame.height + actionView.frame.height + 36 }
	}
	
	var overlayHeight: CGFloat {
		get { return UIScreen.main.bounds.height - 80 }
	}
	
	var overlayPadding: CGFloat {
		get { return 100 }
	}
	
	var actionDelegate: ActionDelegate?

	init() {
		super.init(frame: CGRect.zero)
		
		self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		self.layer.cornerRadius = 32
		self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		
		overlayHandle.backgroundColor = #colorLiteral(red: 0.56, green: 0.56, blue: 0.56, alpha: 1.00)
		overlayHandle.layer.cornerRadius = 3
		
		scrollView.alwaysBounceVertical = true
		scrollView.showsVerticalScrollIndicator = false
		
		grabArea.translatesAutoresizingMaskIntoConstraints = false
		overlayHandle.translatesAutoresizingMaskIntoConstraints = false
		actionView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		statsView.translatesAutoresizingMaskIntoConstraints = false
		rulesView.translatesAutoresizingMaskIntoConstraints = false
		
		self.addSubview(grabArea)
		self.addSubview(actionView)
		self.addSubview(scrollView)
		grabArea.addSubview(overlayHandle)
		scrollView.addSubview(statsView)
		scrollView.addSubview(rulesView)
		
		self.addConstraints([
		
			// Grab Area
			NSLayoutConstraint(item: grabArea, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: grabArea, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: grabArea, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: grabArea, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30),
			
			// Button View
			NSLayoutConstraint(item: actionView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: actionView, attribute: .top, relatedBy: .equal, toItem: grabArea, attribute: .bottom, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: actionView, attribute: .trailing, multiplier: 1.0, constant: 24),
			
			// Scroll View
			NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: actionView, attribute: .bottom, multiplier: 1.0, constant: 6),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: overlayPadding)
		
		])
		
		grabArea.addConstraints([
		
			// Overlay Handle
			NSLayoutConstraint(item: overlayHandle, attribute: .centerY, relatedBy: .equal, toItem: grabArea, attribute: .centerY, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: overlayHandle, attribute: .centerX, relatedBy: .equal, toItem: grabArea, attribute: .centerX, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: overlayHandle, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50),
			NSLayoutConstraint(item: overlayHandle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 8)
		
		])
		
		scrollView.addConstraints([
		
			// Stats View
			NSLayoutConstraint(item: statsView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: statsView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: Phone.rounded ? 14 : 4),
			NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: statsView, attribute: .trailing, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: statsView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.0, constant: -48),
			
			// Rules View
			NSLayoutConstraint(item: rulesView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: rulesView, attribute: .top, relatedBy: .equal, toItem: statsView, attribute: .bottom, multiplier: 1.0, constant: 20),
			NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: rulesView, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: rulesView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0)
		
		])
		
		rulesView.videoPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(watchVideo)))
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func clearActions() {
	
		for eachConstraint in actionView.constraints {

		   if let firstItem = eachConstraint.firstItem as? UIView, firstItem == self {
			   actionView.removeConstraint(eachConstraint)
		   }

		   if let secondItem = eachConstraint.secondItem as? UIView, secondItem == self {
			   actionView.removeConstraint(eachConstraint)
		   }
		   
		}
		
		for eachView in actionView.subviews {
		
			if let gestureArray = eachView.gestureRecognizers {
				for eachGesture in gestureArray { eachView.removeGestureRecognizer(eachGesture) }
			}
		
			eachView.removeFromSuperview()
		}
	
	}

	func resizeContent() {
	
		scrollView.contentSize.height = scrollView.subviews.reduce(0.0, { $0 + $1.frame.height })
	
	}

	func setText(passedText: String) {
	
		clearActions()
	
		let actionLabel = UILabel()
		actionLabel.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
		actionLabel.textColor = #colorLiteral(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.00)
		actionLabel.text = passedText
		
		actionLabel.translatesAutoresizingMaskIntoConstraints = false
		
		actionView.addSubview(actionLabel)
		
		actionView.addConstraints([
		
			// Action Label
			NSLayoutConstraint(item: actionLabel, attribute: .leading, relatedBy: .equal, toItem: actionView, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: actionLabel, attribute: .top, relatedBy: .equal, toItem: actionView, attribute: .top, multiplier: 1.0, constant: 18),
			NSLayoutConstraint(item: actionView, attribute: .trailing, relatedBy: .equal, toItem: actionLabel, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: actionView, attribute: .bottom, relatedBy: .equal, toItem: actionLabel, attribute: .bottom, multiplier: 1.0, constant: 20)
		
		])
	
	}

	func setButtons(passedButtons: Array<ButtonType>) {

		clearActions()

		var previousButton: ActionButton?
		
		for (eachIndex, eachType) in passedButtons.enumerated() {
		
			let eachButton = ActionButton(buttonType: eachType)
			
			switch eachType {
				
				case .NewGame:
				eachButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(newButton)))
				
				case .OpenBox:
				eachButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openButton)))
				
				case .KeepBox:
				eachButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(keepButton)))
				
				case .SwapBox:
				eachButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(swapButton)))
				
			}
			
			eachButton.translatesAutoresizingMaskIntoConstraints = false
			
			actionView.addSubview(eachButton)
			
			actionView.addConstraints([
				NSLayoutConstraint(item: eachButton, attribute: .leading, relatedBy: .equal, toItem: actionView, attribute: .leading, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: actionView, attribute: .trailing, relatedBy: .equal, toItem: eachButton, attribute: .trailing, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: eachButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 48)
			])
			
			if let safeButton = previousButton {
				actionView.addConstraint(NSLayoutConstraint(item: eachButton, attribute: .top, relatedBy: .equal, toItem: safeButton, attribute: .bottom, multiplier: 1.0, constant: 14))
			} else {
				actionView.addConstraint(NSLayoutConstraint(item: eachButton, attribute: .top, relatedBy: .equal, toItem: actionView, attribute: .top, multiplier: 1.0, constant: 14))
			}
			
			if eachIndex == passedButtons.count - 1 {
				actionView.addConstraint(NSLayoutConstraint(item: actionView, attribute: .bottom, relatedBy: .equal, toItem: eachButton, attribute: .bottom, multiplier: 1.0, constant: 20))
			}
			
			previousButton = eachButton
		
		}
	
	}

	func updateStats(passedData: Dictionary<String, Int>) {
	
		statsView.statsGraph.updateGraph(passedData: passedData)
	
	}
	
}

extension OverlayView {

	@objc private func newButton() { actionDelegate?.newGame() }
	
	@objc private func openButton() { actionDelegate?.openBox() }
	
	@objc private func swapButton() { actionDelegate?.swapBox() }
	
	@objc private func keepButton() { actionDelegate?.keepBox() }
	
	@objc private func watchVideo() { actionDelegate?.watchVideo() }

}
