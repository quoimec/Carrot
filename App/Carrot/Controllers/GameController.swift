//
//  GameController.swift
//  Carrot
//
//  Created by Charlie on 18/8/19.
//  Copyright © 2019 Schacher. All rights reserved.
//

import UIKit
import Vision
import AVKit
import AVFoundation
import CoreML

class GameController: UIViewController {
	
	let gameView = GameView()
	let cameraView = CameraView()
	let overlayView = OverlayView()
	
	let faceModel = Face()
	let carrotGame = Carrot()
	
	var overlayTop = NSLayoutConstraint()
	var overlayConstant: CGFloat = 0.0
	
	var hasStarted: Bool = false
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		faceModel.configure(super: self)
		overlayView.actionDelegate = self
		
		gameView.translatesAutoresizingMaskIntoConstraints = false
		cameraView.translatesAutoresizingMaskIntoConstraints = false
		overlayView.translatesAutoresizingMaskIntoConstraints = false
		
		self.view.addSubview(gameView)
		self.view.addSubview(cameraView)
		self.view.addSubview(overlayView)
		
		overlayTop = NSLayoutConstraint(item: overlayView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0)
		
		self.view.addConstraints([
			
			// Game View
			NSLayoutConstraint(item: gameView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: gameView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.view!, attribute: .trailing, relatedBy: .equal, toItem: gameView, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.view!, attribute: .bottom, relatedBy: .equal, toItem: gameView, attribute: .bottom, multiplier: 1.0, constant: 0),
			
			// Camera View
			NSLayoutConstraint(item: cameraView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 60),
			NSLayoutConstraint(item: self.view!, attribute: .trailing, relatedBy: .equal, toItem: cameraView, attribute: .trailing, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: cameraView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60),
			NSLayoutConstraint(item: cameraView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 80),
			
			// Overlay View
			overlayTop,
			NSLayoutConstraint(item: overlayView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.view!, attribute: .trailing, relatedBy: .equal, toItem: overlayView, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: overlayView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: overlayView.overlayHeight + overlayView.overlayPadding)
			
		])
		
		overlayView.grabArea.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(draggedHandle)))
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4, execute: { [weak self] in
		
			guard let safe = self else { return }
		
			safe.processInstruction(passedInstruction: safe.carrotGame.next())
			
			UIView.animate(withDuration: 0.8, delay: 1.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: { [weak self] in
				guard let safe = self else { return }
				safe.overlayTop.constant = -safe.overlayView.overlayBottom
				safe.view.layoutIfNeeded()
			})
		
		})

	}

}

extension GameController: AVCaptureVideoDataOutputSampleBufferDelegate {

	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
	
		guard let imageSample = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
	
		let faceRequest = VNDetectFaceRectanglesRequest(completionHandler: { [weak self] visionRequest, visionError in
			self?.faceModel.detectedFace(from: imageSample, visionRequest: visionRequest, visionError: visionError)
		})
		
		do {
			try faceModel.visionSequence.perform([faceRequest], on: imageSample, orientation: .downMirrored)
		} catch {
			print(error.localizedDescription)
		}
	
	}
	
}

extension GameController: FaceDelegate {

	func faceUpdate(passedImage: UIImage) {
		cameraView.cameraImage.image = passedImage
	}
	
	func emotionUpdate(passedEmotion: String) {
		carrotGame.current.recordEmotion(passedEmotion: passedEmotion)
	}

}

extension GameController: ActionDelegate {
	
	func watchVideo() {
		
		let videoPlayer = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "Carrot", ofType: "mp4")!))

		let videoController = AVPlayerViewController()
		videoController.player = videoPlayer
		
		self.present(videoController, animated: true, completion: {
			videoPlayer.play()
		})
		
	}
	
	func newGame() {
		hasStarted = true
		faceModel.start()
		processInstruction(passedInstruction: carrotGame.next())
	}
	
	func openBox() {
		
		overlayView.setText(passedText: "")
		resetOverlay()
	
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4, execute: { [weak self] in
			guard let safe = self else { return }
			safe.gameView.playerBox.open(withCarrot: safe.carrotGame.current.carrotHolder == .Human)
			safe.processInstruction(passedInstruction: safe.carrotGame.next())
		})
	
	}
	
	func swapBox() {
		carrotGame.swap()
		gameView.swapBoxes()
		processInstruction(passedInstruction: carrotGame.next())
	}
	
	func keepBox() {
		gameView.keepBoxes(whichPlayer: .Human)
		processInstruction(passedInstruction: carrotGame.next())
	}

}

extension GameController {

	@objc func draggedHandle(sender: UIPanGestureRecognizer) {
	
		if sender.state == .began {
			
			if overlayTop.constant == -overlayView.overlayBottom {
				faceModel.stop()
				overlayView.updateStats(passedData: carrotGame.current.emotions)
				overlayView.layoutIfNeeded()
			}
		
			overlayView.resizeContent()
			overlayConstant = overlayTop.constant
			
		} else if sender.state == .ended {
			
			if sender.velocity(in: self.view).y <= 0 && abs(overlayTop.constant) > abs(overlayView.overlayBottom + 60) {
			
				UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveLinear, animations: { [weak self] in
					guard let safe = self else { return }
					safe.overlayTop.constant = -safe.overlayView.overlayHeight
					safe.view.layoutIfNeeded()
				})
			
			} else {
			
				UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveLinear, animations: { [weak self] in
					guard let safe = self else { return }
					safe.overlayTop.constant = -safe.overlayView.overlayBottom
					safe.view.layoutIfNeeded()
				}, completion: { [weak self] animated in
					guard let safe = self else { return }
					safe.faceModel.startrr()
				})
				
			}
			
			return
		}
	
		overlayTop.constant = overlayConstant + sender.translation(in: self.view).y
	
	}

	func processInstruction(passedInstruction: Carrot.Instruction) {
	
		switch passedInstruction {
		
			case .StartGame:
			overlayView.setButtons(passedButtons: [.NewGame])
			
			case .PlayerOpen:
			overlayView.setButtons(passedButtons: [.OpenBox])
			
			case .PlayerSwitchKeep:
			overlayView.setText(passedText: "")
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: { [weak self] in
				guard let safe = self else { return }
				safe.overlayView.setButtons(passedButtons: [.KeepBox, .SwapBox])
				safe.resetOverlay()
			})
			
			case .AgentDecision:
			overlayView.setText(passedText: "🧠 Thinking...")
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0, execute: { [weak self] in
				
				guard let safe = self else { return }
				
				let randomValue = Double.random(in: 0.0 ... 1.0)
				
				if randomValue <= 0.5 {
					safe.overlayView.setText(passedText: "Agent Switched Boxes")
					safe.carrotGame.swap()
					safe.gameView.swapBoxes()
				} else {
					safe.overlayView.setText(passedText: "Agent Kept Its Box")
					safe.gameView.keepBoxes(whichPlayer: .Agent)
				}
				
				safe.resetOverlay()
				
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: { [weak self] in
					guard let safe = self else { return }
					safe.processInstruction(passedInstruction: safe.carrotGame.next())
				})
				
			})
			
			case .AgentOpen:
			gameView.agentBox.censor()
			overlayView.setText(passedText: "Agent Is Looking At Its Box")
			
			case .GameFinish:
			break
		
		}
		
		resetOverlay()
		
	}

	func resetOverlay() {
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01, execute: { [weak self] in
		
			UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: { [weak self] in
				guard let safe = self else { return }
				safe.overlayTop.constant = -safe.overlayView.overlayBottom
				safe.view.layoutIfNeeded()
			}, completion: { animated in
				guard let safe = self, safe.hasStarted else { return }
				safe.faceModel.start()
			})
		
		})
		
	}

}
