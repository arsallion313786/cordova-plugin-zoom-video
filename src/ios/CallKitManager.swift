//
//  CallKitManager.swift
//  NativeBupaZoomApp
//
//  Created by Muhammad Arslan Khalid on 01/10/2024.
//

import Foundation

import CallKit
import ZoomVideoSDK


class CallKitManager: NSObject, CXProviderDelegate  {
    
    
    private var provider:CXProvider!
    private var callController:CXCallController!
    private var callingUUID:UUID!
    
    
    
    private static var callKitManager: CallKitManager = {
        let callKitManager = CallKitManager()
        return callKitManager;
    }()
    
    class func shared() -> CallKitManager {
        return callKitManager
    }
    
    override init() {
        super.init()
        
        if #available(iOS 14.0, *) {
            let providerConfig:CXProviderConfiguration = CXProviderConfiguration()
            self.provider = CXProvider(configuration: providerConfig);
            self.provider.setDelegate(self, queue: nil);
            self.callController = CXCallController();
        } else {
            // Fallback on earlier versions
        };
       
        
    }
    
    func isInCall() -> Bool {
        return callingUUID != nil
    }
    
    func endCall() {
        if !self.isInCall() {
            print("Not in call")
            return
        }
        
        let endCallAction = CXEndCallAction(call: callingUUID!)
        let transaction = CXTransaction(action: endCallAction)
        callController.request(transaction) { error in
            if let error = error {
                print("Error ending call:", error.localizedDescription)
            } else {
                print("Call ended successfully")
                self.callingUUID = nil
            }
        }
    }
    
    func startCall(sessionName:String?, withCompletion completion: (() -> Swift.Void)? = nil) {
        if self.isInCall() {
            print("Already in call!")
            return
        }
        
        let callUUID = UUID()
        let startCallAction = CXStartCallAction(call: callUUID,
                                                handle: CXHandle(type: .generic, value:   sessionName ?? "foo@bar.zoom"))
        let transaction = CXTransaction(action: startCallAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting start call transaction:", error.localizedDescription)
                self.callingUUID = nil
            } else {
                print("Requested start call transaction succeeded")
                self.callingUUID = callUUID
                completion?()
            }
        }
    }
    
    func providerDidReset(_ provider: CXProvider) {
        self.callingUUID = nil;
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        let shouldEndCall = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()?.isHost() ?? false
        ZoomVideoSDK.shareInstance()?.leaveSession(shouldEndCall)
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        let myselfUser = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()
        if action.isMuted {
            ZoomVideoSDK.shareInstance()?.getAudioHelper()?.muteAudio(myselfUser)
        } else {
            ZoomVideoSDK.shareInstance()?.getAudioHelper()?.unmuteAudio(myselfUser)
        }
        action.fulfill()
    }
    
}
