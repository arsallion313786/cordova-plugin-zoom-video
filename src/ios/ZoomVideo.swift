import ZoomVideoSDK
//import ZoomVideoSDKUIToolkit
@objc(ZoomVideo) class ZoomVideo: CDVPlugin{
    var emptyMessage: String?
    var isSDKInitilise:Bool = false;
    
   @objc(openSession:)
   func openSession(command: CDVInvokedUrlCommand) {
        
        let JWTToken = command.arguments[0] as? String ?? ""
        let sessionName = command.arguments[1] as? String ?? ""
        let userName = command.arguments[2] as? String ?? ""
        let domain = command.arguments[3] as? String ?? "zoom.us"
        let enableLog = command.arguments[4] as? Bool ?? false
        let groupId = command.arguments[5] as? String ?? ""//groupId
        let shareExtensionBundleId = command.arguments[6] as? String ?? ""//groupId
        emptyMessage = command.arguments[7] as? String ?? "Waiting for someone to join the call..."

       if(isSDKInitilise == false){
           if initializeZoomSDK(domain: domain, enableLog: enableLog, appGroupId: groupId){
               self.isSDKInitilise = true;
           }
       }
       
       if(isSDKInitilise){
           if joinZoomSession(jwt: JWTToken, sessionName: sessionName, userName: userName){
               openVideoCall(shareExtensionBundleIdentifier: shareExtensionBundleId);
           }
       }
    }
    
    func initializeZoomSDK(domain: String, enableLog: Bool, appGroupId:String) -> Bool{
        let initParams = ZoomVideoSDKInitParams()
        initParams.domain = domain
        if(appGroupId.isEmpty == false){
            initParams.appGroupId = appGroupId
        }
        initParams.enableLog = enableLog
        
        let sdkInitReturnStatus = ZoomVideoSDK.shareInstance()?.initialize(initParams)
        switch sdkInitReturnStatus {
            case .Errors_Success:
                print("SDK initialized successfully")
            default:
                if let error = sdkInitReturnStatus {
                    print("SDK failed to initialize: \(error)")
                    return false
                }
        }
        return true
    };
    
    
    
    func joinZoomSession(jwt: String, sessionName: String, userName: String) -> Bool{
        let sessionContext = ZoomVideoSDKSessionContext()
        sessionContext.token = jwt
        sessionContext.sessionName = sessionName
        sessionContext.userName = userName
        //here we are setting video and audio for video conference
        let audioOption = ZoomVideoSDKAudioOptions();
        audioOption.connect     = true;
        audioOption.mute        = false;
        
        let videoOption = ZoomVideoSDKVideoOptions();
        videoOption.localVideoOn = true;
        videoOption.multitaskingCameraAccessEnabled = true;
        
        sessionContext.videoOption = videoOption;
        sessionContext.audioOption = audioOption;
        
        if let _ = ZoomVideoSDK.shareInstance()?.joinSession(sessionContext) {
            print("session joined successfully")
            return true
        } else {
            print("session failed to join")
            return false
        }
    }
    
    
    func openVideoCall(shareExtensionBundleIdentifier:String){
        let pasteboard = UIPasteboard.general
        pasteboard.string = emptyMessage
        let storyboard = UIStoryboard(name: "Consultation", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "ConsulationMeetingVC") as! ConsulationMeetingVC
        if(shareExtensionBundleIdentifier.isEmpty == false){
            secondViewController.sharedExrensionAppBundleId = shareExtensionBundleIdentifier;
        }
        secondViewController.modalPresentationStyle = .fullScreen
        self.viewController.present(secondViewController, animated: true, completion: nil)

    }
    
/*
    * This action uses the ZoomVideoSDKUIToolkit.xcframework dependency, but this framework is currently in beta as Jan 2024. WHat it does is it replaces our custom screen with a default Zoom video screen provided by Zoom
 */
    /*
    func openVideoCallZoomLayout(jwt: String, sessionName: String, userName: String){
        let vc = UIToolkitVC(sessionContext: SessionContext(jwt: jwt, sessionName: sessionName, username: userName))
        vc.modalPresentationStyle = .fullScreen
        self.viewController.present(vc, animated: true)
        print("session joined")
    }*/
}
