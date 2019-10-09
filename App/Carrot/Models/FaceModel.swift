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
import ARKit

class Face: NSObject {
	
	var cameraAvailable = true
	var faceDelegate: FaceDelegate?

	let backgroundQueue = DispatchQueue(label: "Background", qos: .background)
	
	private let visionSession = AVCaptureSession()
	let visionSequence = VNSequenceRequestHandler()
	private let visionDispatch = DispatchQueue(label: "FaceQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
	
	private var visionFrame: CGRect?
	private var emotionRequests = Array<VNRequest>()

	func configure() {
		
		
////		augmentSession.delegate = self
////		augmentSession.run(augmentConfig, options: [.resetTracking, .removeExistingAnchors])
//
//		guard let visionCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front), let visionInput = try? AVCaptureDeviceInput(device: visionCamera) else {
//			print("Running in Simulator - Camera feed is unavailable.")
//			cameraAvailable = false
//			return
//		}
//
//		visionSession.addInput(visionInput)
//
//		let visionOutput = AVCaptureVideoDataOutput()
//		visionOutput.setSampleBufferDelegate(self, queue: visionDispatch)
//		visionOutput.videoSettings = [
//			kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
//		]
//
//		visionSession.addOutput(visionOutput)
//
//		guard let visionConnection = visionOutput.connection(with: .video) else {
//			print("Running in Simulator - Video feed is unavailable.")
//			cameraAvailable = false
//			return
//		}
//
//		visionConnection.videoOrientation = .portrait

		guard let emotionModel = try? VNCoreMLModel(for: Emotions().model) else {
			fatalError("Unable to locate required Emotions CoreML model")
		}
		
		let emotionRequest = VNCoreMLRequest(model: emotionModel, completionHandler: classifyFace)
		emotionRequest.imageCropAndScaleOption = .scaleFill

		emotionRequests = [emotionRequest]
		
	}
	
	func start() {
		
		if !cameraAvailable { return }
		print("Started Vision Capture")
		visionSession.startRunning()
		
	}
	
	func stop() {
		
		if !cameraAvailable { return }
		print("Stopped Vision Capture")
		visionSession.stopRunning()
		
	}
	
	private func detectedFace(rawBuffer: CVImageBuffer, visionRequest: VNRequest, visionError: Error?) {
	
//		let coreImage =
		
	
//		if visionFrame == nil { visionFrame = CVImageBufferGetCleanRect(rawBuffer) }
//
////		print("Width: \(visionFrame?.width), Height: \(visionFrame?.height)")
//
//		guard let faceResults = visionRequest.results as? Array<VNFaceObservation>, let bufferFrame = visionFrame else { return }
//
//		guard let firstFace = faceResults.first else { return }
//
//		guard let coreImage = CIContext().createCGImage(rawImage, from: CGRect(x: 0, y: 0, width: 1080, height: 1440)) else { return }
		
//		, let croppedImage = coreImage.cropping(to: VNImageRectForNormalizedRect(firstFace.boundingBox, Int(bufferFrame.width), Int(bufferFrame.height))) else { return }

//		VNImageRec

//		let emotionRequest = VNImageRequestHandler(cgImage: croppedImage, options: [:])
//
//		do {
//            try emotionRequest.perform(emotionRequests)
//        } catch {
//            print(error)
//        }
        
//		DispatchQueue.main.async { [weak self] in
//			guard let safe = self else { return }
//			safe.faceDelegate?.faceUpdate(passedImage: UIImage(cgImage: coreImage))
//		}
		
	}
	
	private func classifyFace(request: VNRequest, error: Error?) {
		
		guard let emotionResults = request.results as? Array<VNClassificationObservation> else { return }
		
		DispatchQueue.main.async { [weak self] in
			guard let safe = self else { return }
			safe.faceDelegate?.emotionUpdate(passedEmotion: emotionResults[0].identifier)
		}
		
	}

	func captureBuffer(passedBuffer: CVPixelBuffer) {
	
		let faceRequest = VNDetectFaceRectanglesRequest(completionHandler: { [weak self] visionRequest, visionError in
			guard let safe = self else { return }
			safe.detectedFace(rawBuffer: passedBuffer, visionRequest: visionRequest, visionError: visionError)
		})

		do {
			try visionSequence.perform([faceRequest], on: passedBuffer, orientation: .right)
		} catch {
			print(error.localizedDescription)
		}

	}

}

extension Face: AVCaptureVideoDataOutputSampleBufferDelegate {

	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
	
		guard let imageSample = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
	
		let faceRequest = VNDetectFaceRectanglesRequest(completionHandler: { [weak self] visionRequest, visionError in
			guard let safe = self else { return }
			return
//			safe.detectedFace(from: imageSample, visionRequest: visionRequest, visionError: visionError)
		})
		
		do {
			try visionSequence.perform([faceRequest], on: imageSample, orientation: .downMirrored)
		} catch {
			print(error.localizedDescription)
		}
	
	}
	
}


extension Face: ARSessionDelegate {

//	func session(_ session: ARSession, didUpdate frame: ARFrame) {
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//	}

}
