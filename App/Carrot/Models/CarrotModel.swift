//
//  CarrotModel.swift
//  Carrot
//
//  Created by Charlie on 22/8/19.
//  Copyright © 2019 Schacher. All rights reserved.
//

import Foundation

class Carrot {

	var current: Game

	init() {
		self.current = Game(playerOne: .Human)
	}

	public enum Player {
		case Human, Agent
	}

	public enum Instruction {
		case StartGame, PlayerOpen, AgentOpen, PlayerSwitchKeep, AgentDecision, GameFinish
	}

	struct Game {

		let playerOne: Player
		var carrotHolder: Player
		var instructionSet: Array<Instruction>
		
		private let emotionArray: Array<String>
		private var emotionRecord: Dictionary<String, Int>
		
		var emotions: Dictionary<String, Int> {
		
			get {
				return emotionRecord
			}
		
		}
		
		init(playerOne: Player) {
			
			self.playerOne = playerOne
			self.carrotHolder = Array<Player>([.Human, .Agent]).randomElement()!
			self.emotionArray = ["anger", "disgust", "fear", "happy", "sad", "surprised", "neutral"]
			self.emotionRecord = Dictionary(uniqueKeysWithValues: emotionArray.map({ ($0, 0) }))
			
			self.instructionSet = [.StartGame, .PlayerOpen, .PlayerSwitchKeep, .AgentDecision, .GameFinish]
		
		}
		
		mutating func recordEmotion(passedEmotion: String) {
			
			if emotionArray.contains(passedEmotion) {
				emotionRecord[passedEmotion]! += 1
			} else {
				print("Unknown emotion: \(passedEmotion)")
			}
					
		}
		
	}

	func next() -> Instruction { return current.instructionSet.remove(at: 0) }
	
	func swap() { current.carrotHolder = current.carrotHolder == .Human ? .Agent : .Human }

	func reset() { current = Game(playerOne: current.carrotHolder == .Human ? .Agent : .Human) }

}




