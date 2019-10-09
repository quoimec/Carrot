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
import ARKit
import SceneKit

class GameController: UIViewController {
	
	let gameView = GameView()
	let humanView = CameraView()
	let emojiView = CameraView(forEmoji: true)
	let overlayView = OverlayView()
	
	let sceneView = ARSCNView()
	var faceNode: SCNNode = SCNNode()
	
	var isRecording = false
    
    var eyeLNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()
    
    var eyeRNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()
    
    var lookAtTargetEyeLNode: SCNNode = SCNNode()
    var lookAtTargetEyeRNode: SCNNode = SCNNode()
    
    // actual physical size of iPhoneX screen
    let phoneScreenSize = CGSize(width: 0.0623908297, height: 0.135096943231532)
    
    // actual point size of iPhoneX screen
    let phoneScreenPointSize = CGSize(width: 375, height: 812)
    
	var virtualPhoneNode: SCNNode = SCNNode()
	   
	var virtualScreenNode: SCNNode = {
	   
	   let screenGeometry = SCNPlane(width: 1, height: 1)
	   screenGeometry.firstMaterial?.isDoubleSided = true
	   screenGeometry.firstMaterial?.diffuse.contents = UIColor.green
	   
	   return SCNNode(geometry: screenGeometry)
	}()

	var eyeLookAtPositionXs: [CGFloat] = []

	var eyeLookAtPositionYs: [CGFloat] = []
	
	let eyePosition = UIView(frame: CGRect(x: 100, y: 100, width: 20, height: 20))
	
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
		
		sceneView.alpha = 0.0
		
		faceModel.faceDelegate = self
		overlayView.actionDelegate = self
		sceneView.delegate = self
        sceneView.session.delegate = self
        
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = false
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
		sceneView.scene.background.contents = nil
		
		faceModel.configure()
		
		eyePosition.backgroundColor = UIColor.red
		eyePosition.layer.cornerRadius = 10
		
		sceneView.isUserInteractionEnabled = false
		
		gameView.translatesAutoresizingMaskIntoConstraints = false
		humanView.translatesAutoresizingMaskIntoConstraints = false
		emojiView.translatesAutoresizingMaskIntoConstraints = false
		overlayView.translatesAutoresizingMaskIntoConstraints = false
		sceneView.translatesAutoresizingMaskIntoConstraints = false
		
		self.view.addSubview(gameView)
		self.view.addSubview(humanView)
		self.view.addSubview(emojiView)
		self.view.addSubview(overlayView)
		self.view.addSubview(sceneView)
		self.view.addSubview(eyePosition)
		
		overlayTop = NSLayoutConstraint(item: overlayView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0)
		
		self.view.addConstraints([
			
			// Game View
			NSLayoutConstraint(item: gameView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: gameView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.view!, attribute: .trailing, relatedBy: .equal, toItem: gameView, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.view!, attribute: .bottom, relatedBy: .equal, toItem: gameView, attribute: .bottom, multiplier: 1.0, constant: 0),
			
			// Human View
			NSLayoutConstraint(item: humanView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 60),
			NSLayoutConstraint(item: self.view!, attribute: .trailing, relatedBy: .equal, toItem: humanView, attribute: .trailing, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: humanView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 80),
			NSLayoutConstraint(item: humanView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 80),
			
			// Emoji View
			NSLayoutConstraint(item: emojiView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 60),
			NSLayoutConstraint(item: emojiView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: emojiView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 80),
			NSLayoutConstraint(item: emojiView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 80),
			
			// Overlay View
			overlayTop,
			NSLayoutConstraint(item: overlayView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.view!, attribute: .trailing, relatedBy: .equal, toItem: overlayView, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: overlayView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: overlayView.overlayHeight + overlayView.overlayPadding),
			
			// Scene View
			NSLayoutConstraint(item: sceneView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: sceneView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.view!, attribute: .trailing, relatedBy: .equal, toItem: sceneView, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.view!, attribute: .bottom, relatedBy: .equal, toItem: sceneView, attribute: .bottom, multiplier: 1.0, constant: 0)
			
		])
		
		sceneView.scene.rootNode.addChildNode(faceNode)
        sceneView.scene.rootNode.addChildNode(virtualPhoneNode)
        virtualPhoneNode.addChildNode(virtualScreenNode)
        faceNode.addChildNode(eyeLNode)
        faceNode.addChildNode(eyeRNode)
        eyeLNode.addChildNode(lookAtTargetEyeLNode)
        eyeRNode.addChildNode(lookAtTargetEyeRNode)
        
        lookAtTargetEyeLNode.position.z = 2
        lookAtTargetEyeRNode.position.z = 2
		
		overlayView.grabArea.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(draggedHandle)))
		
		self.view.layoutIfNeeded()
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4, execute: { [weak self] in
		
			guard let safe = self else { return }
		
			safe.processInstruction(passedInstruction: safe.carrotGame.next())
			safe.overlayView.resizeContent()
			
			UIView.animate(withDuration: 1.0, delay: 1.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: { [weak self] in
				guard let safe = self else { return }
				safe.overlayTop.constant = -safe.overlayView.overlayHeight
				safe.view.layoutIfNeeded()
			})
		
		})

	}

}

extension GameController: FaceDelegate {

	func faceUpdate(passedImage: UIImage) {
		humanView.cameraImage.image = passedImage
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
	
	func playAgain() {
		
		gameView.playerBox.close()
		gameView.agentBox.close()
		
		faceModel.start()
		isRecording = true
		carrotGame.reset()
		processInstruction(passedInstruction: carrotGame.next())
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: { [weak self] in
			guard let safe = self else { return }
			safe.overlayView.clearOver()
		})
		
	}
	
	func newGame() {
		hasStarted = true
		faceModel.start()
		isRecording = true
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
		carrotGame.session.stop()
		overlayView.setText(passedText: "")
		carrotGame.current.recordDecision(whichPlayer: .Human, whichDecision: .Swap)
		
		resetOverlay()
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0, execute: { [weak self] in
			guard let safe = self else { return }
			safe.processInstruction(passedInstruction: safe.carrotGame.next())
		})
		
	}
	
	func keepBox() {
		
		gameView.keepBoxes(whichPlayer: .Human)
		carrotGame.session.stop()
		overlayView.setText(passedText: "")
		carrotGame.current.recordDecision(whichPlayer: .Human, whichDecision: .Keep)
		
		if carrotGame.current.playerOne == .Human { carrotGame.session.stop() }
		
		resetOverlay()
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.6, execute: { [weak self] in
			guard let safe = self else { return }
			safe.processInstruction(passedInstruction: safe.carrotGame.next())
		})
		
	}
	
	func resetSession() {
	
		faceModel.stop()
		isRecording = false
		carrotGame.reset(fullReset: true)
		overlayView.clearOver()
		overlayView.clearStats()
		
		gameView.playerBox.close()
		gameView.agentBox.close()
		
		processInstruction(passedInstruction: carrotGame.next())
		overlayView.resizeContent()
		
		UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: { [weak self] in
			guard let safe = self else { return }
			safe.overlayView.scrollTop()
			safe.view.layoutIfNeeded()
		})
		
	}

}

extension GameController {

	@objc func draggedHandle(sender: UIPanGestureRecognizer) {
	
		if sender.state == .began {
			
			if overlayTop.constant == -overlayView.overlayBottom {
				faceModel.stop()
				isRecording = false
				overlayView.updateStats(passedCarrot: carrotGame)
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
					safe.overlayView.scrollTop()
					safe.view.layoutIfNeeded()
				}, completion: { [weak self] animated in
					guard let safe = self else { return }
					safe.faceModel.start()
					safe.isRecording = true
				})
				
			}
			
			return
		}
	
		overlayTop.constant = overlayConstant + sender.translation(in: self.view).y
	
	}

	func resetOverlay() {
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01, execute: { [weak self] in
		
			UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: { [weak self] in
				guard let safe = self else { return }
				safe.overlayTop.constant = -safe.overlayView.overlayBottom
				safe.overlayView.scrollTop()
				safe.view.layoutIfNeeded()
			})
		
		})
		
	}

	func processInstruction(passedInstruction: Carrot.Instruction) {
	
		switch passedInstruction {
		
			case .StartGame:
			overlayView.setButtons(passedButtons: [.NewGame])
			return
			
			case .PlayerOpen:
			overlayView.setButtons(passedButtons: [.OpenBox])
			
			case .PlayerSwitchKeep:
			carrotGame.session.start()
			overlayView.setText(passedText: "")
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: { [weak self] in
				guard let safe = self else { return }
				safe.overlayView.setButtons(passedButtons: [.KeepBox, .SwapBox])
				safe.resetOverlay()
			})
			
			if carrotGame.current.playerOne == .Agent {
				emojiView.animateFaces(emojiArray: carrotGame.current.pickEmojis(emojiCount: 3), emotionDelay: 0.0)
			}
			
			case .AgentDecision:
			overlayView.setText(passedText: "🧠 Thinking...")
			
			if carrotGame.current.playerOne == .Human {
				emojiView.animateFaces(emojiArray: carrotGame.current.pickEmojis(emojiCount: 3), emotionDelay: 0.0)
			}
			
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.0, execute: { [weak self] in
				
				guard let safe = self else { return }
				
				var shouldSwitch: Bool = safe.carrotGame.current.carrotHolder == .Human
				
				if Double.random(in: 0.0 ... 1.0) > safe.carrotGame.session.agentAccuracy { shouldSwitch = !shouldSwitch }
				
				if shouldSwitch {
					safe.carrotGame.current.recordDecision(whichPlayer: .Agent, whichDecision: .Swap)
					safe.overlayView.setText(passedText: "Agent Switched Boxes")
					safe.carrotGame.swap()
					safe.gameView.swapBoxes()
				} else {
					safe.carrotGame.current.recordDecision(whichPlayer: .Agent, whichDecision: .Keep)
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
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: { [weak self] in
				guard let safe = self else { return }
				safe.gameView.agentBox.censor()
				safe.overlayView.setText(passedText: "Agent Is Looking At Its Box")

				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: { [weak self] in
					guard let safe = self else { return }
					safe.processInstruction(passedInstruction: safe.carrotGame.next())
				})
				
			})
						
			case .GameFinish:
			faceModel.stop()
			isRecording = false
			carrotGame.score()
			carrotGame.upload()
			
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: { [weak self] in
				guard let safe = self else { return }
				safe.gameView.playerBox.open(withCarrot: safe.carrotGame.current.carrotHolder == .Human)
				safe.gameView.agentBox.open(withCarrot: safe.carrotGame.current.carrotHolder == .Agent)
			})
			
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.2, execute: { [weak self] in
				guard let safe = self else { return }
				safe.overlayView.setButtons(passedButtons: [.PlayAgain])
				safe.overlayView.createOver(playerWon: safe.carrotGame.current.carrotHolder == .Human)
				safe.overlayView.createStats(passedCarrot: safe.carrotGame)
				safe.overlayView.resizeContent()
				safe.view.layoutIfNeeded()
			})
			
			UIView.animate(withDuration: 1.0, delay: 2.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveLinear, animations: { [weak self] in
				guard let safe = self else { return }
				safe.overlayTop.constant = -safe.overlayView.overlayHeight
				safe.view.layoutIfNeeded()
			})
			return
		
		}
		
		resetOverlay()
		
	}

}

extension GameController: ARSCNViewDelegate, ARSessionDelegate {

	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        faceNode.transform = node.transform
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        update(withFaceAnchor: faceAnchor)
        
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
	
		if !isRecording { return }
	
		faceModel.captureBuffer(passedBuffer: frame.capturedImage)
		
		let face = frame.anchors.first! as! ARFaceAnchor
		print(face.geometry.)
		
		
//		sceneView.projectPoint(<#T##point: SCNVector3##SCNVector3#>)
		
//		frame.camera.projectPoint(<#T##point: simd_float3##simd_float3#>, orientation: .portrait, viewportSize: CGSize(width: 1080, height: 1920))
	
	}
    
    func update(withFaceAnchor anchor: ARFaceAnchor) {
        
        if !isRecording { return }
        
        eyeRNode.simdTransform = anchor.rightEyeTransform
        eyeLNode.simdTransform = anchor.leftEyeTransform
        
        var eyeLLookAt = CGPoint()
        var eyeRLookAt = CGPoint()
        
        let heightCompensation: CGFloat = 312
        
        DispatchQueue.main.async {
            
            let phoneScreenEyeRHitTestResults = self.virtualPhoneNode.hitTestWithSegment(from: self.lookAtTargetEyeRNode.worldPosition, to: self.eyeRNode.worldPosition, options: nil)
            
            let phoneScreenEyeLHitTestResults = self.virtualPhoneNode.hitTestWithSegment(from: self.lookAtTargetEyeLNode.worldPosition, to: self.eyeLNode.worldPosition, options: nil)
            
            for result in phoneScreenEyeRHitTestResults {
                
                eyeRLookAt.x = CGFloat(result.localCoordinates.x) / (self.phoneScreenSize.width / 2) * self.phoneScreenPointSize.width
                
                eyeRLookAt.y = CGFloat(result.localCoordinates.y) / (self.phoneScreenSize.height / 2) * self.phoneScreenPointSize.height + heightCompensation
            }
            
            for result in phoneScreenEyeLHitTestResults {
                
                eyeLLookAt.x = CGFloat(result.localCoordinates.x) / (self.phoneScreenSize.width / 2) * self.phoneScreenPointSize.width
                
                eyeLLookAt.y = CGFloat(result.localCoordinates.y) / (self.phoneScreenSize.height / 2) * self.phoneScreenPointSize.height + heightCompensation
            }
            
            let smoothThresholdNumber: Int = 3
            self.eyeLookAtPositionXs.append((eyeRLookAt.x + eyeLLookAt.x) / 2)
            self.eyeLookAtPositionYs.append(-(eyeRLookAt.y + eyeLLookAt.y) / 2)
            self.eyeLookAtPositionXs = Array(self.eyeLookAtPositionXs.suffix(smoothThresholdNumber))
            self.eyeLookAtPositionYs = Array(self.eyeLookAtPositionYs.suffix(smoothThresholdNumber))
            
            var smoothEyeLookAtPositionX = self.eyeLookAtPositionXs.reduce(0.0, { $0 + $1 })
            var smoothEyeLookAtPositionY = self.eyeLookAtPositionYs.reduce(0.0, { $0 + $1 })
            
            if self.eyeLookAtPositionXs.count > 0 { smoothEyeLookAtPositionX = smoothEyeLookAtPositionX / CGFloat(self.eyeLookAtPositionXs.count) }
            
            if self.eyeLookAtPositionYs.count > 0 { smoothEyeLookAtPositionY = smoothEyeLookAtPositionY / CGFloat(self.eyeLookAtPositionYs.count) }
            
            self.carrotGame.looking.append(["x": Int(round(smoothEyeLookAtPositionX + self.phoneScreenPointSize.width / 2)), "y": Int(round(smoothEyeLookAtPositionY + self.phoneScreenPointSize.height / 2))])
            
            self.eyePosition.frame.origin = CGPoint(x: Int(round(smoothEyeLookAtPositionX + self.phoneScreenPointSize.width / 2)), y: Int(round(smoothEyeLookAtPositionY + self.phoneScreenPointSize.height / 2)))

        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        virtualPhoneNode.transform = (sceneView.pointOfView?.transform)!
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        faceNode.transform = node.transform
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        update(withFaceAnchor: faceAnchor)
    }

}
