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
	private let actionContainer = UIView()
	private let overContainer = UIView()
	private let statsContainer = UIView()
	private let scrollView = UIScrollView()
	private let rulesView = RulesView()
	private let resetButton = ActionButton(buttonType: .ResetSession)
	
	var overlayBottom: CGFloat {
		get { return grabArea.frame.height + actionContainer.frame.height + (Phone.rounded ? 20 : 6) }
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
		actionContainer.translatesAutoresizingMaskIntoConstraints = false
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		overContainer.translatesAutoresizingMaskIntoConstraints = false
		statsContainer.translatesAutoresizingMaskIntoConstraints = false
		rulesView.translatesAutoresizingMaskIntoConstraints = false
		resetButton.translatesAutoresizingMaskIntoConstraints = false
		
		self.addSubview(grabArea)
		self.addSubview(actionContainer)
		self.addSubview(scrollView)
		grabArea.addSubview(overlayHandle)
		scrollView.addSubview(overContainer)
		scrollView.addSubview(statsContainer)
		scrollView.addSubview(rulesView)
		scrollView.addSubview(resetButton)
		
		self.addConstraints([
		
			// Grab Area
			NSLayoutConstraint(item: grabArea, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: grabArea, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: grabArea, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: grabArea, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30),
			
			// Button View
			NSLayoutConstraint(item: actionContainer, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: actionContainer, attribute: .top, relatedBy: .equal, toItem: grabArea, attribute: .bottom, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: actionContainer, attribute: .trailing, multiplier: 1.0, constant: 24),
			
			// Scroll View
			NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: actionContainer, attribute: .bottom, multiplier: 1.0, constant: 6),
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
		
			// Over Container
			NSLayoutConstraint(item: overContainer, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: overContainer, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: overContainer, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: overContainer, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0),
		
			// Stats Container
			NSLayoutConstraint(item: statsContainer, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: statsContainer, attribute: .top, relatedBy: .equal, toItem: overContainer, attribute: .bottom, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: statsContainer, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: statsContainer, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0),
			
			// Rules View
			NSLayoutConstraint(item: rulesView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: rulesView, attribute: .top, relatedBy: .equal, toItem: statsContainer, attribute: .bottom, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: rulesView, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: rulesView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0),
			
			// Reset Button
			NSLayoutConstraint(item: resetButton, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: resetButton, attribute: .top, relatedBy: .equal, toItem: rulesView, attribute: .bottom, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: resetButton, attribute: .trailing, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: resetButton, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.0, constant: -48),
			NSLayoutConstraint(item: resetButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 48)
		
		])
		
		rulesView.videoPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(watchVideo)))
		
		resetButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resetSession)))
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func clearSubviews(passedView: UIView) {
	
		for eachConstraint in passedView.constraints { passedView.removeConstraint(eachConstraint) }
		
		for eachView in passedView.subviews {
		
			if let gestureArray = eachView.gestureRecognizers {
				for eachGesture in gestureArray { eachView.removeGestureRecognizer(eachGesture) }
			}
		
			eachView.removeFromSuperview()
		}
	
	}

	func resizeContent() { scrollView.contentSize.height = scrollView.subviews.reduce(0.0, { $0 + $1.frame.height }) + (Phone.rounded ? 40.0 : 10.0) }

	func setText(passedText: String) {
	
		clearSubviews(passedView: actionContainer)
	
		let actionLabel = UILabel()
		actionLabel.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
		actionLabel.textColor = #colorLiteral(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.00)
		actionLabel.text = passedText
		
		actionLabel.translatesAutoresizingMaskIntoConstraints = false
		
		actionContainer.addSubview(actionLabel)
		
		actionContainer.addConstraints([
		
			// Action Label
			NSLayoutConstraint(item: actionLabel, attribute: .leading, relatedBy: .equal, toItem: actionContainer, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: actionLabel, attribute: .top, relatedBy: .equal, toItem: actionContainer, attribute: .top, multiplier: 1.0, constant: 10),
			NSLayoutConstraint(item: actionContainer, attribute: .trailing, relatedBy: .equal, toItem: actionLabel, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: actionContainer, attribute: .bottom, relatedBy: .equal, toItem: actionLabel, attribute: .bottom, multiplier: 1.0, constant: 20)
		
		])
		
		self.layoutIfNeeded()
	
	}

	func setButtons(passedButtons: Array<ButtonType>) {

		clearSubviews(passedView: actionContainer)

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
				
				case .PlayAgain:
				eachButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playAgain)))
				
				case .ResetSession:
				break
				
			}
			
			eachButton.translatesAutoresizingMaskIntoConstraints = false
			
			actionContainer.addSubview(eachButton)
			
			actionContainer.addConstraints([
				NSLayoutConstraint(item: eachButton, attribute: .leading, relatedBy: .equal, toItem: actionContainer, attribute: .leading, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: actionContainer, attribute: .trailing, relatedBy: .equal, toItem: eachButton, attribute: .trailing, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: eachButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 48)
			])
			
			if let safeButton = previousButton {
				actionContainer.addConstraint(NSLayoutConstraint(item: eachButton, attribute: .top, relatedBy: .equal, toItem: safeButton, attribute: .bottom, multiplier: 1.0, constant: 14))
			} else {
				actionContainer.addConstraint(NSLayoutConstraint(item: eachButton, attribute: .top, relatedBy: .equal, toItem: actionContainer, attribute: .top, multiplier: 1.0, constant: 14))
			}
			
			if eachIndex == passedButtons.count - 1 {
				actionContainer.addConstraint(NSLayoutConstraint(item: actionContainer, attribute: .bottom, relatedBy: .equal, toItem: eachButton, attribute: .bottom, multiplier: 1.0, constant: 20))
			}
			
			previousButton = eachButton
		
		}
	
		self.layoutIfNeeded()
	
	}

	func createOver(playerWon: Bool) {
	
		clearSubviews(passedView: overContainer)
	
		let overView = OverView(playerWon: playerWon)
		overView.translatesAutoresizingMaskIntoConstraints = false
		overContainer.addSubview(overView)
	
		overContainer.addConstraints([
		
			// Over View
			NSLayoutConstraint(item: overView, attribute: .leading, relatedBy: .equal, toItem: overContainer, attribute: .leading, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: overView, attribute: .top, relatedBy: .equal, toItem: overContainer, attribute: .top, multiplier: 1.0, constant: 14),
			NSLayoutConstraint(item: overContainer, attribute: .trailing, relatedBy: .equal, toItem: overView, attribute: .trailing, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: overContainer, attribute: .bottom, relatedBy: .equal, toItem: overView, attribute: .bottom, multiplier: 1.0, constant: 24)
		
		])
		
		self.layoutIfNeeded()
	
	}

	func clearOver() { clearSubviews(passedView: overContainer) }
	
	func clearStats() { clearSubviews(passedView: statsContainer) }

	func createStats(passedCarrot: Carrot) {
	
		clearSubviews(passedView: statsContainer)
		
		let performanceStats = StatsView(passedType: .Performance, passedName: "Your Performance")
		let emotionsStats = StatsView(passedType: .Emotions, passedName: "Recorded Emotions")
		
		performanceStats.translatesAutoresizingMaskIntoConstraints = false
		emotionsStats.translatesAutoresizingMaskIntoConstraints = false
		statsContainer.addSubview(performanceStats)
		statsContainer.addSubview(emotionsStats)
	
		statsContainer.addConstraints([
		
			// Performance Stats
			NSLayoutConstraint(item: performanceStats, attribute: .leading, relatedBy: .equal, toItem: statsContainer, attribute: .leading, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: performanceStats, attribute: .top, relatedBy: .equal, toItem: statsContainer, attribute: .top, multiplier: 1.0, constant: 14),
			NSLayoutConstraint(item: statsContainer, attribute: .trailing, relatedBy: .equal, toItem: performanceStats, attribute: .trailing, multiplier: 1.0, constant: 24),
			
			// Performance Stats
			NSLayoutConstraint(item: emotionsStats, attribute: .leading, relatedBy: .equal, toItem: statsContainer, attribute: .leading, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: emotionsStats, attribute: .top, relatedBy: .equal, toItem: performanceStats, attribute: .bottom, multiplier: 1.0, constant: 30),
			NSLayoutConstraint(item: statsContainer, attribute: .trailing, relatedBy: .equal, toItem: emotionsStats, attribute: .trailing, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: statsContainer, attribute: .bottom, relatedBy: .equal, toItem: emotionsStats, attribute: .bottom, multiplier: 1.0, constant: 6),
		
		])
		
		self.layoutIfNeeded()
		
		updateStats(passedCarrot: passedCarrot)
		
		self.layoutIfNeeded()
		
	}
	
	func updateStats(passedCarrot: Carrot) {
	
		for case let eachStats as StatsView in statsContainer.subviews {
		
			switch eachStats.statsType {
			
				case .Performance:
				eachStats.statsGraph.updateStats(passedData: passedCarrot.history)
				
				case .Emotions:
				eachStats.statsGraph.updateStats(passedData: passedCarrot.current.emotions)
			
			}
		
		}
	
	}
	
	func scrollTop(animated: Bool = true) { scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: animated) }
	
}

extension OverlayView {

	@objc private func newButton() { actionDelegate?.newGame() }
	
	@objc private func playAgain() { actionDelegate?.playAgain() }
	
	@objc private func openButton() { actionDelegate?.openBox() }
	
	@objc private func swapButton() { actionDelegate?.swapBox() }
	
	@objc private func keepButton() { actionDelegate?.keepBox() }
	
	@objc private func watchVideo() { actionDelegate?.watchVideo() }

	@objc private func resetSession() { actionDelegate?.resetSession() }

}
