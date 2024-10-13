//
//  ConsulationMeetingVC.swift
//  NativeBupaZoomApp
//
//  Created by Muhammad Arslan Khalid on 27/09/2024.
//

import UIKit
import ZoomVideoSDK
import ReplayKit
import AudioToolbox


class ConsulationMeetingVC: BupaBaseVC {
    
    @IBOutlet private weak var bottomActionView:UIView!
    
    @IBOutlet private weak var lblWaitingMsg:UILabel!
    
    @IBOutlet private weak var otherUserPlaceHolderIcon:UIImageView!
    @IBOutlet private weak var meUserPlaceHolderIcon:UIImageView!
    
    
    
    @IBOutlet private weak var containerZoomView:UIView!
    
    @IBOutlet private weak var zoomView:ZoomView!
    
    @IBOutlet private weak var callDismissbtn:UIButton!
    @IBOutlet private weak var btnAudioIcon:UIButton!
    @IBOutlet private weak var btnVideoIcon:UIButton!
    @IBOutlet private weak var btnChatIcon:UIButton!
    
    @IBOutlet private weak var thumbnailView:ZoomView!
    
    //According to Design these btn are not included
    @IBOutlet private weak var btnSpeakerIcon:UIButton!
    @IBOutlet private weak var btnShareScreen:UIButton!
    
    
    @IBOutlet private weak var lblCurrentUserDesignation:UILabel!
    @IBOutlet private weak var lblCurrentUserName:UILabel!
    
    @IBOutlet private weak var timerView:UIView!
    @IBOutlet private weak var lblTimer:UILabel!
    
    @IBOutlet private weak var snackBarView:UIView!
    @IBOutlet private weak var lblTitleSnackbar:UILabel!
    
    
    
    private var timer:Timer!
    private var chatVc:ZoomChatVC?
    private var arrChatMessages:[ZoomVideoSDKChatMessage] = [ZoomVideoSDKChatMessage]();
    private var isSpeakerOn = true;
    
    
    
    //this property we will use to share screen
    var sharedExrensionAppBundleId:String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.methodsOnViewLoaded();
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
    }
}


//MARK: Btn Actions
private extension ConsulationMeetingVC{
    @IBAction func btnCloseSessionPressed(_ sender:UIButton){
        if let user = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf(){
            self.askForLeaveSession(user: user)
        }
    }
    
    @IBAction func btnAudioTogglePressed(_ sender:UIButton){
        let user = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf();
        if(user?.audioStatus()?.audioType != ZoomVideoSDKAudioType.none){
            if(user?.audioStatus()?.isMuted == false){
                ZoomVideoSDK.shareInstance()?.getAudioHelper()?.muteAudio(user);
            }
            else{
                ZoomVideoSDK.shareInstance()?.getAudioHelper()?.unmuteAudio(user);
            }
        }
        else{
            ZoomVideoSDK.shareInstance()?.getAudioHelper()?.startAudio();
        }
    }
    
    @IBAction func btnSwitchSpeakerPressed(_ sender:UIButton){
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            if(isSpeakerOn){
                try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                isSpeakerOn = false;
            }
            else{
                try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                isSpeakerOn = true;
            }
            
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        //self.btnSpeakerIcon.setImage(UIImage(systemName:isSpeakerOn ? "speaker" :  "speaker.slash"), for: .normal)
    }
    
    @IBAction func btnToggleVideoPressed(_ sender:UIButton){
        if(self.btnVideoIcon.isSelected){
            self.btnVideoIcon.isSelected = false;
            ZoomVideoSDK.shareInstance()?.getVideoHelper()?.stopVideo();
            self.meUserPlaceHolderIcon.isHidden = false;
            //self.btnVideoIcon.setImage(UIImage(systemName: "video.slash"), for: .normal)
        }
        else{
            self.btnVideoIcon.isSelected = true;
            ZoomVideoSDK.shareInstance()?.getVideoHelper()?.startVideo();
            self.meUserPlaceHolderIcon.isHidden = true;
            self.btnVideoIcon.setImage(UIImage(named: "video_enable_icon"), for: .normal)
        }
    }
    
    @IBAction func btnChatPressed(_ sender:UIButton){
        self.chatVc = nil;
        if #available(iOS 13.0, *) {
            self.chatVc =  self.storyboard?.instantiateViewController(identifier: "ZoomChatVC", creator: { coder in
                ZoomChatVC(arrChatMessages: self.arrChatMessages, coder: coder);
            })
        } else {
            // Fallback on earlier versions
        }
        
        if let vc =  self.chatVc{
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func btnSwitchCameraPressed(_ sender:UIButton){
        DispatchQueue.global().async {
            ZoomVideoSDK.shareInstance()?.getVideoHelper()?.switchCamera();
        }
        
    }
    
    @IBAction func btnShareScreenPressed(_ sender:UIButton){
        self.checkAndStartShareScreenProcess();
    }
}


//MARK: Utility Methods
private extension ConsulationMeetingVC{
    func methodsOnViewLoaded(){
        ZoomVideoSDK.shareInstance()?.delegate = self;
        self.setUI();
        self.setData();
        if let user = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf(){
            //SDKPiPHelper.shared().updatePiPVideoUser(user: user, videoType: .videoData)
        }
    }
    
    func setUI(){
        self.callDismissbtn.roundEdges();
        self.btnAudioIcon.roundEdges();
        self.btnChatIcon.roundEdges();
        self.btnVideoIcon.roundEdges();
        self.bottomActionView.roundEdges(radius: 34.0)
        
        self.timerView.roundEdges(radius: 17.5);
        self.snackBarView.roundEdges(radius: 20);
        //self.btnShareScreen.isHidden = self.sharedExrensionAppBundleId == nil;
    }
    
    func setData(){
        self.thumbnailView.dataType = ZoomVideoSDKVideoType.videoData;
        self.thumbnailView.user = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf();
        if(self.thumbnailView.user != nil){
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.thumbnailView.user!.getVideoCanvas()?.subscribe(with: self.thumbnailView, aspectMode: ZoomVideoSDKVideoAspect.letterBox, andResolution: ZoomVideoSDKVideoResolution._Auto);
            }
           
        }
    }
    
    func setDesignationName(user:ZoomVideoSDKUser){
            if user.isHost(){
                self.lblCurrentUserDesignation.text = "General Practitioner"
            }
            else{
                self.lblCurrentUserDesignation.text = "Patient/Attendee"
            }
        
    }
    
    
    
    
//    func makeHalfCircleIntoBottomActionView(){
//        let circlePath = UIBezierPath(arcCenter: CGPoint(x: bottomActionView.bounds.size.width / 2, y: 0), radius: 50, startAngle: 0.0, endAngle: -.pi, clockwise: true)
//        
//        circlePath.append(UIBezierPath(rect: bottomActionView.bounds));
//        circlePath.close();
//        
//        let circleShape = CAShapeLayer()
//        circleShape.path = circlePath.cgPath
//        circleShape.fillRule = .evenOdd
//        bottomActionView.layer.mask = circleShape;
//    }
    
    func onLeave(){
        self.timer?.invalidate();
        self.timer = nil;
        let user = self.zoomView.user;
        self.unsubscribeView(user: self.zoomView.user, view: self.zoomView);
        self.unsubscribeView(user: self.thumbnailView.user, view: self.thumbnailView);
        self.dismiss(animated: true);
    }
    
    func onAudioStatusChange(){
        let user = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf();
        if(user?.audioStatus()?.audioType != ZoomVideoSDKAudioType.none){
            if(user?.audioStatus()?.isMuted ?? true){
                //self.btnAudioIcon.setImage(UIImage(systemName: "mic.slash"), for: .normal);
            }
            else{
                //self.btnAudioIcon.setImage(UIImage(named: "mic_enable_icon"), for: .normal);
            }
        }
        else{
           // self.btnAudioIcon.setImage(UIImage(systemName: "mic.slash"), for: .normal);
        }
        
    }
    
    func startTimerForVideoConference(){
        let videoStartDate  = Date();
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {[weak self] (timer) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                let result = Date().dHMS(fromDate: videoStartDate);
                
                self.lblTimer.text = "\(self.getDesignedTimeValue(val: result.h)):\(self.getDesignedTimeValue(val: result.m)):\(self.getDesignedTimeValue(val: result.s))"
            }
        });
    }
    
    func getDesignedTimeValue(val:Int) -> String{
        let formatter = NumberFormatter();
        formatter.minimumIntegerDigits = 0
        formatter.locale = Locale(identifier: "en_US");
        if val <= 9 {
            return "\(formatter.string(from: NSNumber(value: Float("0")!))!)\(formatter.string(from: NSNumber(value: Float("\(val)")!))!)"
        }
        return formatter.string(from: NSNumber(value: val))!
    }
    
    func showSnackbar(message:String){
        self.lblTitleSnackbar.text =  message;
        UIView.animate(withDuration: 0.3) {
            self.snackBarView.alpha = 1.0
        } completion: { isFinished in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                UIView.animate(withDuration: 0.3) {
                    self.snackBarView.alpha = 0.0
                }
            }
        }
        
    }
    
    func checkAndStartShareScreenProcess(){
        if(ZoomVideoSDK.shareInstance()?.getShareHelper()?.isShareLocked() ?? false){
            self.showSnackbar(message: "Share is locked by admin");
        }
        else if(ZoomVideoSDK.shareInstance()?.getShareHelper()?.isOtherSharing() ?? false){
            self.showSnackbar(message: "Someone else already sharing");
        }
        else {
            
            if #available(iOS 12.0, *) {
                let broadcastView = RPSystemBroadcastPickerView()
                broadcastView.preferredExtension = self.sharedExrensionAppBundleId;
                broadcastView.tag = 1000000;
                self.view.addSubview(broadcastView)
                self.sendTouchDownEventToBroadcastButton()
            } else {
                // Fallback on earlier versions
            };
          
        }
        
        //if (ZoomVideoSDK.shareInstance()?.getShareHelper()?.isScreenSharingOut()  ?? false)  == false
        
    }
    
    func sendTouchDownEventToBroadcastButton(){
        if #available(iOS 12.0, *) {
            let broadcastView:RPSystemBroadcastPickerView?  = self.view.viewWithTag(1000000) as? RPSystemBroadcastPickerView
            guard let broadcastView else { return;}
            
            for subView in broadcastView.subviews{
                if subView.isKind(of: UIButton.self){
                    let broadcastBtn = subView as! UIButton
                    broadcastBtn.sendActions(for: .allTouchEvents)
                    break;
                    
                }
            }
        } else {
            // Fallback on earlier versions
        };
        
    }
    
    func setUserFullScreenCanvas(user:ZoomVideoSDKUser, type:ZoomVideoSDKVideoType){
        if(type == ZoomVideoSDKVideoType.videoData){
            user.getVideoCanvas()?.subscribe(with: self.zoomView, aspectMode: .full_Filled, andResolution: ._Auto)
        }
        else{
            user.getShareCanvas()?.subscribe(with: self.zoomView, aspectMode: .full_Filled, andResolution: ._Auto);
        }
        
        self.zoomView.user = user
        self.zoomView.dataType = type;
        
        //SDKPiPHelper.shared().updatePiPVideoUser(user: user, videoType: type);
    }
    
    func unsubscribeView(user:ZoomVideoSDKUser?, view:ZoomView){
        
        user?.getVideoCanvas()?.unSubscribe(with: view);
        user?.getShareCanvas()?.unSubscribe(with: view);
        
        view.user = nil
        view.dataType = nil;
    }
    
    func askForLeaveSession(user:ZoomVideoSDKUser){
        let alert = UIAlertController(title: "Video Session", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Leave", style: .default , handler:{ (UIAlertAction)in
            ZoomVideoSDK.shareInstance()?.leaveSession(false)
        }))
        
        if(user.isHost()){
            alert.addAction(UIAlertAction(title: "End Session", style: .destructive , handler:{ (UIAlertAction)in
                ZoomVideoSDK.shareInstance()?.leaveSession(true)
            }))
        }
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:{ (UIAlertAction)in
        }))
        
        
        //uncomment for iPad Support
        //if you are also supporting for iPad than you need to provide btn reference
        //also to present action sheet in popover
        //alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func updateViewIfUserStopVideo(user:ZoomVideoSDKUser, canvas:ZoomView){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if(user.getShareCanvas()?.videoStatus()?.on == false && canvas.dataType != ZoomVideoSDKVideoType.shareData){
//                canvas.backgroundColor = UIColor.black;
//                self.unsubscribeView(user: user, view: canvas);
                self.otherUserPlaceHolderIcon.isHidden = false;
                
                if let user = self.thumbnailView.user {
                    //SDKPiPHelper.shared().updatePiPVideoUser(user: user, videoType: .videoData)
                }
                
            }
            else{
                if let user = self.zoomView.user {
                    //SDKPiPHelper.shared().updatePiPVideoUser(user: user, videoType: .videoData)
                }
                self.otherUserPlaceHolderIcon.isHidden = true;
            }
        }
        
    }
    
    
    //    func checkIfAlreadyWeHaveUserInSession(){
    //        let arr:[ZoomVideoSDKUser] =  ZoomVideoSDK.shareInstance()?.getSession()?.getRemoteUsers() ?? [];
    //        if(arr.isEmpty == false){
    //
    //        }
    //    }
    
}

//MARK: ZoomVide Delegate Methods
extension ConsulationMeetingVC:ZoomVideoSDKDelegate{
    func onError(_ ErrorType: ZoomVideoSDKError, detail details: Int) {
        switch(ErrorType){
        case ZoomVideoSDKError.Errors_Session_Join_Failed:
            self.onLeave();
            break;
        case .Errors_Session_Disconnecting:
            break;
        case .Errors_Session_Reconnecting:
            break;
        default:
            break;
        }
    }
    
    
    
    func onSessionJoin() {
        print("Session Joined Successfully");
        self.startTimerForVideoConference();
        DispatchQueue.global(qos: .userInitiated).async {
            CallKitManager.shared().startCall(sessionName: ZoomVideoSDK.shareInstance()?.getSession()?.getName()) {
                DispatchQueue.main.async {
                    //SDKPiPHelper.shared().presetPiPWithSrcView(sourceView: self.containerZoomView);
                }
                
            }
        }
    }
    
    func onSessionLeave(_ reason: ZoomVideoSDKSessionLeaveReason) {
        //SDKPiPHelper.shared().cleanUpPictureInPicture();
        CallKitManager.shared().endCall();
        self.onLeave();
    }
    
    func onUserJoin(_ helper: ZoomVideoSDKUserHelper?, users userArray: [ZoomVideoSDKUser]?) {
        
        if let meUser = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf(){
            if(meUser.getID() == userArray?.first?.getID()){
                return;
            }
        }
        
        
        if let user = userArray?.first as? ZoomVideoSDKUser{
            self.setDesignationName(user: user);
            self.lblWaitingMsg.isHidden = true;
            self.setUserFullScreenCanvas(user: user, type: .videoData);
            //SDKPiPHelper.shared().updatePiPVideoUser(user: user, videoType: .videoData)
            if let name =  user.getName(){
                self.lblCurrentUserName.text = name;
                showSnackbar(message: "\(name) Joined");
            }
        }
    }
    
    
    
    func onUserLeave(_ helper: ZoomVideoSDKUserHelper?, users userArray: [ZoomVideoSDKUser]?) {
        
        if let meUser = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf(){
            if(meUser.getID() == userArray?.first?.getID()){
                return;
            }
        }
        
        
        
        if let user = userArray?.first as? ZoomVideoSDKUser{
            
            
            if(user.getID() == self.zoomView.user?.getID()){
                self.unsubscribeView(user: user, view: self.zoomView)
            }
            
            if let name = user.getName(){
                //showSnackbar(message: "\(name) leave session");
                self.lblWaitingMsg.text = "\(name) leave session";
            }
            else{
                //showSnackbar(message: "someone leave session");
                self.lblWaitingMsg.text = "someone leave session";
            }
            self.lblWaitingMsg.isHidden = false;
            
            //self.otherUserPlaceHolderIcon.isHidden = false;
            
            
        }
    }
    
    func onUserVideoStatusChanged(_ helper: ZoomVideoSDKVideoHelper?, user userArray: [ZoomVideoSDKUser]?) {
//            if let meUser = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf(){
//                if(meUser.getID() == userArray?.first?.getID()){
//                    return;
//                    //self.updateViewIfUserStopVideo(user: meUser, canvas: self.thumbnailView);
//                }
//            }
            
            if let user = userArray?.first as? ZoomVideoSDKUser{
                if(user.getID() == self.zoomView.user?.getID()){
                    self.updateViewIfUserStopVideo(user: user, canvas: self.zoomView)
                }
            }
        
        
    }
    
    func onUserAudioStatusChanged(_ helper: ZoomVideoSDKAudioHelper?, user userArray: [ZoomVideoSDKUser]?) {
        self.onAudioStatusChange()
    }
    
    func onChatNewMessageNotify(_ helper: ZoomVideoSDKChatHelper?, message chatMessage: ZoomVideoSDKChatMessage?) {
        if let chatMessage{
            self.arrChatMessages.append(chatMessage);
            self.chatVc?.reloadData(messages: self.arrChatMessages);
            if (self.chatVc?.isBeingDismissed == true){
                self.showSnackbar(message: "\(chatMessage.senderUser?.getName() ?? "unknown"): \(chatMessage.content ?? "N/A")")
            }
        }
    }
    
    func onUserShareStatusChanged(_ helper: ZoomVideoSDKShareHelper?, user: ZoomVideoSDKUser?, status: ZoomVideoSDKReceiveSharingStatus) {
        if let meUser = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf(){
            if(user?.getID() == meUser.getID()){
                if (status == ZoomVideoSDKReceiveSharingStatus.start || status == ZoomVideoSDKReceiveSharingStatus.resume){
                    //self.btnShareScreen.setImage(UIImage(systemName: "shareplay"), for: .normal)
                }
                else if(status == ZoomVideoSDKReceiveSharingStatus.stop || status == ZoomVideoSDKReceiveSharingStatus.pause){
                    //self.btnShareScreen.setImage(UIImage(systemName: "shareplay.slash"), for: .normal)
                }
                return
            }
        }
        
        if let user {
            if (status == ZoomVideoSDKReceiveSharingStatus.start || status == ZoomVideoSDKReceiveSharingStatus.resume){
                self.setUserFullScreenCanvas(user: user, type: .shareData);
            }
            else if(status == ZoomVideoSDKReceiveSharingStatus.stop){
                self.setUserFullScreenCanvas(user: user, type: .videoData);
            }
        }
    }
    
    
}
