import ZoomVideoSDK
@objc (ZoomVideo) class ToastiOS: CDVPlugin{
    @objc (openSession:) // This @OBJC tag matcher our Javascript interface method with the SWIFT code. The actual function name can be whatever you want, as long as the tag matches
    func openSession(command: CDVInvokedUrlCommand) {
        
        let kAppDomain = ""
        
        let initParams = ZoomVideoSDKInitParams()
        initParams.domain = "zoom.us"
        initParams.enableLog = true
        
        let sdkInitReturnStatus = ZoomVideoSDK.shareInstance()?.initialize(initParams)
        switch sdkInitReturnStatus {
        case .Errors_Success:
            print("SDK initialized successfully")
        default:
            if let error = sdkInitReturnStatus {
                print("SDK failed to initialize: \(error)")
            }
        }
        ZoomVideoSDK().initialize(initParams)
        joinZoomSession()
        
    }
    
    func joinZoomSession(){
        let sessionContext = ZoomVideoSDKSessionContext()
        // Ensure that you do not hard code JWT or any other confidential credentials in your production app.
        sessionContext.token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBfa2V5Ijoic095T2lYYlZTQzZoVHNlYjBaaWlGdyIsInJvbGVfdHlwZSI6MSwidHBjIjoiVGVzdCBTZXNzaW9uIiwidmVyc2lvbiI6MSwiaWF0IjoxNzA1MzQ4NTEzLCJleHAiOjE3MDUzNTU3MTMsInVzZXJfaWRlbnRpdHkiOiJIZW5yaXF1ZSJ9.I5ALtjiyvMrdU43r6Al8a2ig-e5E5rFG1RuQL3g5Sc4"
        sessionContext.sessionName = "Test Session"
        sessionContext.userName = "Henrique"
//        sessionContext.sessionPassword = "Your session password"
        if let session = ZoomVideoSDK.shareInstance()?.joinSession(sessionContext) {
            // Session joined successfully.
            print("session joined happy face")
        }
    }
    
    func displayToastMessage(message: String, durationInSeconds: Double){
        // TODO
    }
}
