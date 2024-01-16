//
//  VideoManager.swift
//  HelloCordova
//
//  Created by Henrique Silva on 15/01/24.
//

import Foundation
import ZoomVideoSDK
class VideoManager: NSObject, ZoomVideoSDKDelegate {
    // Add any of the following callback functions here as needed for your app.
    override init() {
        super.init()
        ZoomVideoSDK.shareInstance()?.delegate = self
    }
    
    func onError(_ ErrorType: ZoomVideoSDKError, detail details: Int) {
          switch ErrorType {
            case .Errors_Success:
          // Your ZoomVideoSDK operation was successful.
          print("Success")
          default:
          // Your ZoomVideoSDK operation raised an error.
          // Refer to error code documentation.
          print("Error \(ErrorType) \(details)")
          return
        }
    }
}


