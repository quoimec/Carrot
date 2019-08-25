//
//  FaceModel.swift
//  Carrot
//
//  Created by Charlie on 25/8/19.
//  Copyright © 2019 Schacher. All rights reserved.
//

import Foundation
import Vision
import AVKit
import AVFoundation
import CoreML

class Face {
	
	var cameraAvailable = true
	var faceDelegate: FaceDelegate?
	
	private let visionSession = AVCaptureSession()
	let visionSequence = VNSequenceRequestHandler()
	private let visionDispatch = DispatchQueue(label: "FaceQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
	
	private var visionFrame: CGRect?
	private var emotionRequests = Array<VNRequest>()

	func configure(super superDelegate: GameController) {
		
		guard let visionCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front), let visionInput = try? AVCaptureDeviceInput(device: visionCamera) else {
			print("Running in Simulator - Camera feed is unavailable.")
			cameraAvailable = false
			return
		}
		
		visionSession.addInput(visionInput)
		
		let visionOutput = AVCaptureVideoDataOutput()
		visionOutput.setSampleBufferDelegate(superDelegate, queue: visionDispatch)
		visionOutput.videoSettings = [
			kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
		]
		
		visionSession.addOutput(visionOutput)
		
		guard let visionConnection = visionOutput.connection(with: .video) else {
			print("Running in Simulator - Video feed is unavailable.")
			cameraAvailable = false
			return
		}
		
		visionConnection.videoOrientation = .portrait
		cameraAvailable = true

		guard let emotionModel = try? VNCoreMLModel(for: Emotions().model) else {
			fatalError("Unable to locate required Emotions CoreML model")
		}
		
		let emotionRequest = VNCoreMLRequest(model: emotionModel, completionHandler: classifyFace)
		emotionRequest.imageCropAndScaleOption = .scaleFill

		emotionRequests = [emotionRequest]
		
	}
	
	func start() {
		
		if !cameraAvailable { return }
		visionSession.startRunning()
		
	}
	
	func stop() {
		
		if !cameraAvailable { return }
		visionSession.stopRunning()
		
	}
	
	func detectedFace(from rawBuffer: CVImageBuffer, visionRequest: VNRequest, visionError: Error?) {
	
		if visionFrame == nil { visionFrame = CVImageBufferGetCleanRect(rawBuffer) }
	
		guard let faceResults = visionRequest.results as? Array<VNFaceObservation>, let bufferFrame = visionFrame else { return }
	
		guard let firstFace = faceResults.first else { return }
		
		guard let coreImage = CIContext().createCGImage(CIImage(cvImageBuffer: rawBuffer), from: bufferFrame), let croppedImage = coreImage.cropping(to: VNImageRectForNormalizedRect(firstFace.boundingBox, Int(bufferFrame.width), Int(bufferFrame.height))) else { return }
		
		let emotionRequest = VNImageRequestHandler(cgImage: croppedImage, options: [:])
		
		do {
            try emotionRequest.perform(emotionRequests)
        } catch {
            print(error)
        }
        
		DispatchQueue.main.async { [weak self] in
			guard let safe = self else { return }
			safe.faceDelegate?.faceUpdate(passedImage: UIImage(cgImage: croppedImage, scale: 1.0, orientation: .upMirrored))
		}
		
	}
	
	func classifyFace(request: VNRequest, error: Error?) {
		
		guard let emotionResults = request.results as? Array<VNClassificationObservation> else { return }
		
		DispatchQueue.main.async { [weak self] in
			guard let safe = self else { return }
			safe.faceDelegate?.emotionUpdate(passedEmotion: emotionResults[0].identifier)
		}
		
	}

}
