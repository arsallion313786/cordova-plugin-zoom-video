import ZoomVideoSDK
//import ZoomVideoSDKUIToolkit
@objc (ZoomVideo) class ZoomVideo: CDVPlugin{
    var emptyMessage: String?
    @objc (openSession:) // This @OBJC tag matcher our Javascript interface method with the SWIFT code. The actual function name can be whatever you want, as long as the tag matches
    func openSession(command: CDVInvokedUrlCommand) {
        
        let JWTToken = command.arguments[0] as? String ?? ""
        let sessionName = command.arguments[1] as? String ?? ""
        let userName = command.arguments[2] as? String ?? ""
        let domain = command.arguments[3] as? String ?? "zoom.us"
        let enableLog = command.arguments[4] as? Bool ?? false
        emptyMessage = command.arguments[5] as? String ?? "Waiting for someone to join the call..."

        if initializeZoomSDK(domain: domain, enableLog: enableLog){
            if joinZoomSession(jwt: JWTToken, sessionName: sessionName, userName: userName){
                openVideoCall()
            }
        }
    }
    
    func initializeZoomSDK(domain: String, enableLog: Bool) -> Bool{
        let initParams = ZoomVideoSDKInitParams()
        initParams.domain = domain
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
    }
    
    func joinZoomSession(jwt: String, sessionName: String, userName: String) -> Bool{
        let sessionContext = ZoomVideoSDKSessionContext()
        sessionContext.token = jwt
        sessionContext.sessionName = sessionName
        sessionContext.userName = userName
        if let session = ZoomVideoSDK.shareInstance()?.joinSession(sessionContext) {
            print("session joined successfully")
            return true
        } else {
            print("session failed to join")
            return false
        }
    }
    
    
    func openVideoCall(){
        let pasteboard = UIPasteboard.general
        pasteboard.string = emptyMessage
        let storyboard = UIStoryboard(name: "VideoCall", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(identifier: "ViewController") as! VideoViewController
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
