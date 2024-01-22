//
//  VideoViewController.swift
//  HelloCordova
//
//  Created by Henrique Silva on 17/01/24.
//

import UIKit
import ZoomVideoSDK

class VideoViewController: UIViewController, ZoomVideoSDKDelegate {

    @IBOutlet weak var secondPreview: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var myPreview: UIView!
    @IBOutlet weak var toggleVideoButton: UIButton!
    
    @IBOutlet weak var toggleMicButton: UIButton!
    @IBOutlet weak var hangUpButton: UIButton!
    
    var myself: ZoomVideoSDKUser?
    var userOnMainView: ZoomVideoSDKUser?
    var userOnSecondView: ZoomVideoSDKUser?
    var zoomInstance: ZoomVideoSDK?
    
    var isVideoOn: Bool = true
    var isAudioOn: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ZoomVideoSDK.shareInstance()?.delegate = self
        zoomInstance = ZoomVideoSDK.shareInstance()
        myself = zoomInstance?.getSession()?.getMySelf()
        secondPreview.isHidden = true
        
        hangUpButton.layer.cornerRadius = 20
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        subscribeUserView(view: myPreview, user: myself)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        zoomInstance?.cleanup()
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
    func onUserJoin(_ helper: ZoomVideoSDKUserHelper?, users userArray: [ZoomVideoSDKUser]?) {
        print("user join event")
        for i in 0..<userArray!.count{
            if userOnMainView == nil{
                userOnMainView = userArray![i]
                subscribeUserView(view: mainView, user: userOnMainView)
            } else {
                userOnSecondView = userArray![i]
                subscribeUserView(view: secondPreview, user: userOnSecondView)
                secondPreview.isHidden = false
            }
        }
    }
    func onUserActiveAudioChanged(_ helper: ZoomVideoSDKUserHelper?, users userArray: [ZoomVideoSDKUser]?) {
        for i in 0..<userArray!.count{
            if userOnSecondView == userArray![i]{
                switchMainUserWithSecondaryUser()
            }
        }
    }
    func onUserLeave(_ helper: ZoomVideoSDKUserHelper?, users userArray: [ZoomVideoSDKUser]?) {
        for i in 0..<userArray!.count{
            if userOnMainView == userArray![i]{
                userOnMainView?.getVideoCanvas()?.unSubscribe(with: mainView)
                userOnMainView = nil
                if(userOnSecondView != nil){
                    userOnMainView = userOnSecondView
                    userOnSecondView?.getVideoCanvas()?.unSubscribe(with: secondPreview)
                    userOnSecondView = nil
                    subscribeUserView(view: mainView, user: userOnMainView)
                    secondPreview.isHidden = true
                }
            } else if userOnSecondView == userArray![i]{
                userOnSecondView?.getVideoCanvas()?.unSubscribe(with: secondPreview)
                secondPreview.isHidden = true
            }
        }
    }
    func onSessionLeave() {
        closeScreen()
    }
    
    @IBAction func flipCameraButtonOnClick(_ sender: UIButton) {
        zoomInstance?.getVideoHelper().switchCamera()
    }
    
    @IBAction func toggleVideoOnClick(_ sender: UIButton) {
        if self.isVideoOn{
            zoomInstance?.getVideoHelper().stopVideo()
            self.isVideoOn = false
            if let image = UIImage(named: "ic_video_off_114.png"){
                toggleVideoButton.setImage(image, for: .normal)
            }
        } else {
            zoomInstance?.getVideoHelper().startVideo()
            self.isVideoOn = true
            if let image = UIImage(named: "ic_video_on_114.png"){
                toggleVideoButton.setImage(image, for: .normal)
            }
        }
    }
    
    @IBAction func muteButtonOnClick(_ sender: UIButton) {
            if self.isAudioOn{
                zoomInstance?.getAudioHelper().stopAudio()
                self.isAudioOn = false
                if let image = UIImage(named: "ic_mic_off_114.png"){
                    toggleMicButton.setImage(image, for: .normal)
                }
            } else {
                zoomInstance?.getAudioHelper().startAudio()
                self.isAudioOn = true
                if let image = UIImage(named: "ic_mic_on_114.png"){
                    toggleMicButton.setImage(image, for: .normal)
                }
            }
    }
    @IBAction func hangupOnClick(_ sender: UIButton) {
        zoomInstance?.leaveSession(false)
    }
    
    func subscribeUserView(view:UIView, user: ZoomVideoSDKUser?){
        if let usersVideoCanvas = user?.getVideoCanvas() {
            // Set video aspect.
            let videoAspect = ZoomVideoSDKVideoAspect.panAndScan
            let resolution = ZoomVideoSDKVideoResolution._Auto
            // Subscribe User's videoCanvas to render their video stream.
            usersVideoCanvas.subscribe(with: view, aspectMode: videoAspect, andResolution: resolution)
        }
    }
    
    func switchMainUserWithSecondaryUser(){
        let aux = userOnSecondView
        userOnSecondView = userOnMainView
        userOnMainView = aux
        if userOnMainView != nil {
            subscribeUserView(view: mainView, user: userOnMainView)
        }
        if userOnSecondView != nil {
            subscribeUserView(view: secondPreview, user: userOnSecondView)
        } else {
            secondPreview.isHidden = true
        }
    }

    func closeScreen(){
        self.dismiss(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
