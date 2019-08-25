//
//  PhoneModel.swift
//  Carrot
//
//  Created by Charlie on 23/8/19.
//  Copyright © 2019 Schacher. All rights reserved.
//

import Foundation

public enum PhoneModel: String {
	case iPhone5s
	case iPhone6, iPhone6Plus
	case iPhone6s, iPhone6sPlus, iPhoneSE
	case iPhone7, iPhone7Plus
	case iPhoneX, iPhone8, iPhone8Plus
	case iPhoneXs, iPhoneXsMax, iPhoneXR
	case Unknown
}

public enum PhoneSize {
	case smallPhone, mediumPhone, largePhone
}

public class Phone {

	static var size: PhoneSize {

		get {
			
			switch model {
			
				case .iPhone5s, .iPhoneSE, .iPhone6, .iPhone6s, .iPhone7, .iPhone8:
				return .smallPhone
				
				case .iPhone6Plus, .iPhone6sPlus, .iPhone7Plus, .iPhone8Plus:
				return .mediumPhone
				
				case .iPhoneX, .iPhoneXs, .iPhoneXsMax, .iPhoneXR:
				return .largePhone
				
				case .Unknown:
				return .mediumPhone
				
			}
			
		}

	}
	
	static var model: PhoneModel {
		
		// PhoneModel code from StackOverflow
		// - https://stackoverflow.com/questions/26028918/how-to-determine-the-current-iphone-device-model
		// - Will have to check back to update identifiers each September
		
		get {
		
			var systemInfo = utsname()
			uname(&systemInfo)
			
			let machineMirror = Mirror(reflecting: systemInfo.machine)
			let deviceIdentifier = machineMirror.children.reduce("", { eachIdentifier, eachElement in
				
				guard let eachValue = eachElement.value as? Int8, eachValue != 0 else { return eachIdentifier }
				return eachIdentifier + String(UnicodeScalar(UInt8(eachValue)))
				
			})
			
			let finalIdenfitier = deviceIdentifier != "x86_64" ? deviceIdentifier : ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
			
			switch finalIdenfitier {
			
				case "iPhone6,1", "iPhone6,2":
				return .iPhone5s
				
				case "iPhone7,2":
				return .iPhone6
				
				case "iPhone7,1":
				return .iPhone6Plus
				
				case "iPhone8,1":
				return .iPhone6s
				
				case "iPhone8,2":
				return .iPhone6sPlus
				
				case "iPhone9,1", "iPhone9,3":
				return .iPhone7
				
				case "iPhone9,2", "iPhone9,4":
				return .iPhone7Plus
				
				case "iPhone8,4":
				return .iPhoneSE
				
				case "iPhone10,1", "iPhone10,4":
				return .iPhone8
				
				case "iPhone10,2", "iPhone10,5":
				return .iPhone8Plus
				
				case "iPhone10,3", "iPhone10,6":
				return .iPhoneX
				
				case "iPhone11,2":
				return .iPhoneXs
				
				case "iPhone11,4", "iPhone11,6":
				return .iPhoneXsMax
				
				case "iPhone11,8":
				return .iPhoneXR
			
				default:
				print("!! - Unknown Phone Model: \(deviceIdentifier)")
				return .Unknown
			
			}
			
		}
		
	}
	
	static var rounded: Bool {
	
		get {
			
			switch model {
			
				case .iPhone5s, .iPhoneSE, .iPhone6, .iPhone6s, .iPhone7, .iPhone8, .iPhone6Plus, .iPhone6sPlus, .iPhone7Plus, .iPhone8Plus:
				return false
				
				case .iPhoneX, .iPhoneXs, .iPhoneXsMax, .iPhoneXR:
				return true
				
				case .Unknown:
				return false
				
			}
			
		}
	
	}
	
}
