//
//  CarrotModel.swift
//  Carrot
//
//  Created by Charlie on 22/8/19.
//  Copyright © 2019 Schacher. All rights reserved.
//

import Foundation
import UIKit

class Carrot {

	var current: Game
	var history: Dictionary<String, Int> = ["won": 0, "lost": 0]
	var session: Session
	var looking = Array<Dictionary<String, Int>>()

	init() {
		self.current = Game(playerOne: .Human, isInitial: true)
		self.session = Session()
	}

	public enum Player: String {
		case Human, Agent
	}
	
	public enum Decision: String {
		case Swap, Keep
	}

	public enum Instruction {
		case StartGame, PlayerOpen, AgentOpen, PlayerSwitchKeep, AgentDecision, GameFinish
	}

	struct Game {

		let playerOne: Player
		var carrotHolder: Player
		var instructionSet = Array<Instruction>()
		
		private let emojiArray: Array<String> = ["😡", "🤢", "😨", "😀", "😒", "😮", "😐"]
		private let emotionArray: Array<String> = ["anger", "disgust", "fear", "happy", "sad", "surprised", "neutral"]
		
		private var gameRecord = Dictionary<String, Any>()
		private var emotionRecord: Dictionary<String, Int>
		private let emojiRecord: Dictionary<String, String>
		
		var emotions: Dictionary<String, Int> {
		
			get {
				return emotionRecord
			}
		
		}
		
		init(playerOne: Player, isInitial: Bool = false) {
			
			self.playerOne = playerOne
			
			self.carrotHolder = Array<Player>([.Human, .Agent]).randomElement()!
			self.emotionRecord = Dictionary(uniqueKeysWithValues: emotionArray.map({ ($0, 0) }))
			self.emojiRecord = Dictionary(uniqueKeysWithValues: zip(emotionArray, emojiArray))
			
			if isInitial { self.instructionSet += [.StartGame] } 
			
			if playerOne == .Human {
				self.instructionSet += [.PlayerOpen, .PlayerSwitchKeep, .AgentDecision, .GameFinish]
			} else {
				self.instructionSet += [.AgentOpen, .AgentDecision, .PlayerSwitchKeep, .GameFinish]
			}
			
			self.gameRecord["playerOne"] = self.playerOne.rawValue
			self.gameRecord["carrotStart"] = self.carrotHolder.rawValue
			
		}
		
		mutating func recordEmotion(passedEmotion: String) {
			
			if emotionArray.contains(passedEmotion) {
				emotionRecord[passedEmotion]! += 1
			} else {
				print("Unknown emotion: \(passedEmotion)")
			}
					
		}
		
		mutating func pickEmojis(emojiCount: Int) -> Array<String> {
		
			let emojiArray = Array(emojiRecord.values)
			let emojiValues: Array<String> = Range(0 ... 2).map({ _ in emojiArray[Int.random(in: 0 ..< emojiArray.count)] })
			
			for (eachIndex, eachKey) in ["emojiOne", "emojiTwo", "emojiThree"].enumerated() {
				self.gameRecord[eachKey] = emojiValues[eachIndex]
			}
		
			return emojiValues
		
		}
		
		mutating func recordDecision(whichPlayer: Player, whichDecision: Decision) {
		
			self.gameRecord[whichPlayer == .Human ? "playerDecision" : "agentDecision"] = whichDecision.rawValue
		
		}
		
		mutating func getRecord() -> Dictionary<String, Any> {
		
			for (eachEmotion, eachValue) in emotionRecord {
				self.gameRecord["\(eachEmotion)Count"] = eachValue
			}
			
			self.gameRecord["carrotWinner"] = carrotHolder.rawValue
			
			return self.gameRecord
			
		}
		
	}

	struct Session {
	
		private var begin: Date?
		private var end: Date?
		private var count: Int = 0
		private let accuracyRange: ClosedRange<Double> = (0.45 ... 0.70)
		var agentAccuracy: Double
		
		init() {
			self.agentAccuracy = Double.random(in: self.accuracyRange)
		}
		
		mutating func start() {
			self.begin = Date()
			self.end = nil
			self.count += 1
		}
		
		mutating func stop() {
			self.end = Date()
		}
		
		mutating func reset() {
			self.begin = nil
			self.end = nil
			self.count = 0
			self.agentAccuracy = Double.random(in: self.accuracyRange)
		}
		
		func details() -> (TimeInterval, Int) {
			guard let safe = begin, let time = end?.timeIntervalSince(safe) else { return (0.0, count) }
			return (time, count)
		}
		
		func getRecord() -> Dictionary<String, Any> {
		
			let (gameSeconds, sessionCount) = self.details()
		
			return [
				"agentAccuracy": agentAccuracy,
				"sessionCount": sessionCount,
				"gameSeconds": gameSeconds
			]
		
		}
		
	}

	func next() -> Instruction { return current.instructionSet.remove(at: 0) }
	
	func swap() { current.carrotHolder = current.carrotHolder == .Human ? .Agent : .Human }

	func reset(fullReset: Bool = false) {
		
		looking = []
		
		if fullReset {
			session.reset()
			history = ["won": 0, "lost": 0]
			current = Game(playerOne: .Human, isInitial: true)
		} else {
			current = Game(playerOne: current.playerOne == .Human ? .Agent : .Human)
		}
		
	}

	func score() { history[current.carrotHolder == .Human ? "won" : "lost"]! += 1 }

	func upload() {
		
		var carrotDump = current.getRecord().merging(session.getRecord()) { (_, new) in new }
		
		carrotDump["humanWon"] = history["won"]
		carrotDump["humanLost"] = history["lost"]
		carrotDump["eyePoints"] = looking
		
		var requestObject = URLRequest(url: URL(string: "http://13.70.105.105/carrot")!, timeoutInterval: 20.0)
		requestObject.httpBody = try! JSONSerialization.data(withJSONObject: carrotDump, options: [])
		requestObject.httpMethod = "POST"
		requestObject.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		
		var requestSession = URLSession.shared.dataTask(with: requestObject, completionHandler: { data, response, error in
		
			guard let safeData = data else { return }
			
			print(String(decoding: safeData, as: UTF8.self))
		
		}).resume()
			
	}

}




