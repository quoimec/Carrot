//
//  StatisticsView.swift
//  Carrot
//
//  Created by Charlie on 23/8/19.
//  Copyright © 2019 Schacher. All rights reserved.
//

import Foundation
import UIKit

class StatsView: UIView {

	var statsLabel = UILabel()
	var statsGraph: StatsGraph

	init(passedName: String) {
		statsGraph = StatsGraph()
		super.init(frame: CGRect.zero)
	
		self.backgroundColor = #colorLiteral(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
		self.layer.cornerRadius = 16
	
		statsLabel.text = passedName
		statsLabel.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
		statsLabel.textColor = #colorLiteral(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.00)
		
		statsLabel.translatesAutoresizingMaskIntoConstraints = false
		statsGraph.translatesAutoresizingMaskIntoConstraints = false
		
		self.addSubview(statsLabel)
		self.addSubview(statsGraph)
		
		self.addConstraints([
		
			// Stats Label
			NSLayoutConstraint(item: statsLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 20),
			NSLayoutConstraint(item: statsLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 18),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: statsLabel, attribute: .trailing, multiplier: 1.0, constant: 14),
		
			// Bar Graph
			NSLayoutConstraint(item: statsGraph, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 14),
			NSLayoutConstraint(item: statsGraph, attribute: .top, relatedBy: .equal, toItem: statsLabel, attribute: .bottom, multiplier: 1.0, constant: 8),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: statsGraph, attribute: .trailing, multiplier: 1.0, constant: 14),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: statsGraph, attribute: .bottom, multiplier: 1.0, constant: 16)
			
		])
	
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

class StatsGraph: UIView, UIGestureRecognizerDelegate {
	
	var verticalDisabled: Bool = false
	var horizontalDisabled: Bool = false
	
	init() {
		super.init(frame: CGRect.zero)
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(hoverBars(sender:)))
		panGesture.delegate = self
		
		self.addGestureRecognizer(panGesture)
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func updateGraph(passedData: Dictionary<String, Int>) {
	
		var previousBar: StatsBar?
		let maximumValue = CGFloat(passedData.values.max() ?? 0)
	
		for eachConstraint in self.constraints { self.removeConstraint(eachConstraint) }
		
		for eachView in self.subviews {
		
			if let gestureArray = eachView.gestureRecognizers {
				for eachGesture in gestureArray { eachView.removeGestureRecognizer(eachGesture) }
			}
		
			eachView.removeFromSuperview()
		}
		
		let graphWidth: Int = Int(self.frame.size.width)
		let baseWidth: Int = graphWidth / passedData.count
		let moduloCount: Int = graphWidth % passedData.count
		
		let arrayWidths: Array<CGFloat> = zip(
			[Int](repeatElement(baseWidth, count: passedData.count)),
			([Int](repeatElement(1, count: moduloCount)) + [Int](repeatElement(0, count: moduloCount)))
		).map({ CGFloat($0 + $1) }).shuffled()
		
		for (eachIndex, eachEmotion) in passedData.keys.sorted().enumerated() {
		
			let eachValue = passedData[eachEmotion]!
		
			let eachBar = StatsBar(recordName: eachEmotion, recordValue: CGFloat(eachValue), recordMax: maximumValue)
			eachBar.translatesAutoresizingMaskIntoConstraints = false
			self.addSubview(eachBar)
		
			self.addConstraints([
				NSLayoutConstraint(item: eachBar, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: eachBar, attribute: .bottom, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: eachBar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: arrayWidths[eachIndex]),
			])
		
			if let safeRecord = previousBar {
				self.addConstraint(NSLayoutConstraint(item: eachBar, attribute: .leading, relatedBy: .equal, toItem: safeRecord, attribute: .trailing, multiplier: 1.0, constant: 0))
			} else {
				self.addConstraint(NSLayoutConstraint(item: eachBar, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
			}
			
			if eachIndex == passedData.count - 1 {
				self.addConstraint(NSLayoutConstraint(item: eachBar, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
			}
		
			previousBar = eachBar
		
		}
	
	}
	
	@objc func hoverBars(sender: UIPanGestureRecognizer) {
	
		if sender.state == .began {
		
			let panVelocity = sender.velocity(in: self)
			
			if abs(panVelocity.x) >= abs(panVelocity.y) {
				verticalDisabled = true
			} else {
				horizontalDisabled = true
			}
			
		} else if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
			
			verticalDisabled = false
			horizontalDisabled = false
			
			for case let eachBar as StatsBar in self.subviews { eachBar.hoverReset() }
			
			return
			
		}
		
		if horizontalDisabled { return }
		
		for case let eachBar as StatsBar in self.subviews {
		
			if (0.0 ... eachBar.frame.width).contains(sender.location(in: eachBar).x) {
				eachBar.hoverFocus()
			} else {
				eachBar.hoverBlur()
			}
		
		}
		
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
	
		if verticalDisabled { return false }

		return true
		
	}
	
}

class StatsBar: UIView {

	private var barActual = UIView()
	private var barContainer = UIView()
	private var barValue = UILabel()
	private var barName = UILabel()
	
	private let barBorder: CGFloat = 4.0

	init(recordName: String, recordValue: CGFloat, recordMax: CGFloat) {
		super.init(frame: CGRect.zero)
		
		barValue.text = "\(Int(recordValue))"
		barValue.textAlignment = .center
		barValue.font = UIFont.systemFont(ofSize: 11, weight: .black)
		barValue.textColor = #colorLiteral(red: 0.23, green: 0.02, blue: 0.05, alpha: 1.00)
		
		barName.text = recordName.capitalized
		barName.textAlignment = .center
		barName.font = UIFont.systemFont(ofSize: 8, weight: .bold)
		barName.textColor = #colorLiteral(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.00)
		
		barActual.layer.cornerRadius = 6
		
		hoverReset()
		
		barValue.translatesAutoresizingMaskIntoConstraints = false
		barActual.translatesAutoresizingMaskIntoConstraints = false
		barContainer.translatesAutoresizingMaskIntoConstraints = false
		barName.translatesAutoresizingMaskIntoConstraints = false
		
		barContainer.addSubview(barActual)
		self.addSubview(barValue)
		self.addSubview(barContainer)
		self.addSubview(barName)
		
		self.addConstraints([
		
			// Bar Value
			NSLayoutConstraint(item: barValue, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: barValue, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 6),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: barValue, attribute: .trailing, multiplier: 1.0, constant: 0),
			
			// Bar Container
			NSLayoutConstraint(item: barContainer, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: barContainer, attribute: .top, relatedBy: .equal, toItem: barValue, attribute: .bottom, multiplier: 1.0, constant: 10),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: barContainer, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: barContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 120),
		
			// Bar Name
			NSLayoutConstraint(item: barName, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: barName, attribute: .top, relatedBy: .equal, toItem: barContainer, attribute: .bottom, multiplier: 1.0, constant: 12),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: barName, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: barName, attribute: .bottom, multiplier: 1.0, constant: 6)
			
		])
		
		barContainer.addConstraints([
		
			// Bar Actual
			NSLayoutConstraint(item: barActual, attribute: .leading, relatedBy: .equal, toItem: barContainer, attribute: .leading, multiplier: 1.0, constant: barBorder),
			NSLayoutConstraint(item: barContainer, attribute: .trailing, relatedBy: .equal, toItem: barActual, attribute: .trailing, multiplier: 1.0, constant: barBorder),
			NSLayoutConstraint(item: barContainer, attribute: .bottom, relatedBy: .equal, toItem: barActual, attribute: .bottom, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: barActual, attribute: .height, relatedBy: .equal, toItem: barContainer, attribute: .height, multiplier: recordMax > 0 ? recordValue / recordMax : 0.0, constant: 0)
		
		])
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func hoverFocus() {
	
		barActual.backgroundColor = #colorLiteral(red: 0.93, green: 0.25, blue: 0.35, alpha: 1.00)
		barValue.alpha = 1.0
		barName.alpha = 1.0
	
	}
	
	func hoverBlur() {
	
		barActual.backgroundColor = #colorLiteral(red: 0.95, green: 0.81, blue: 0.83, alpha: 1.00)
		barValue.alpha = 0.0
		barName.alpha = 0.0
		
	}
	
	func hoverReset() {
	
		barActual.backgroundColor = #colorLiteral(red: 0.96, green: 0.53, blue: 0.59, alpha: 1.00)
		barValue.alpha = 0.0
		barName.alpha = 1.0
		
	}

}


