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

    var emptyRoomMessage: UITextView!
    // var loadingIcon: UIActivityIndicatorView!
    
    var myself: ZoomVideoSDKUser?
    var userOnMainView: ZoomVideoSDKUser?
    var userOnSecondView: ZoomVideoSDKUser?
    var zoomInstance: ZoomVideoSDK?
    var emptyMessage: String?

    var isVideoOn: Bool = true
    var isAudioOn: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ZoomVideoSDK.shareInstance()?.delegate = self
        zoomInstance = ZoomVideoSDK.shareInstance()
        myself = zoomInstance?.getSession()?.getMySelf()
        secondPreview.isHidden = true
        zoomInstance?.getVideoHelper().mirrorMyVideo(true)
        hangUpButton.layer.cornerRadius = 20
        
        let pasteboard = UIPasteboard.general
        emptyMessage = pasteboard.string

        bootStrapUITextView()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.secondaryViewOnClick))
        secondPreview.addGestureRecognizer(gesture)
    }
    
    @objc func secondaryViewOnClick(){
        switchMainUserWithSecondaryUser()
    }

    deinit {
        zoomInstance?.cleanup()
    }

    override func viewDidAppear(_ animated: Bool) {
        /*
         * If the video was stopped when the app was put in the background, start again.
         */
        if (zoomInstance?.isInSession() == true && self.isVideoOn == true) {
            zoomInstance?.getVideoHelper().startVideo();
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        /*
         * Stop video before going in the background. This ensures that the
         * camera can be used by other applications while this app is in the background.
         */
        if (zoomInstance?.isInSession() == true && self.isVideoOn == true) {
            zoomInstance?.getVideoHelper().stopVideo();
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Your code here to handle orientation change
        zoomInstance?.getVideoHelper().rotateMyVideo(UIDevice.current.orientation)
        subscribeUserView(view: mainView, user: userOnMainView)
        subscribeUserView(view: secondPreview, user: userOnSecondView)
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

    func onSessionJoin() {
        subscribeUserView(view: myPreview, user: myself)
        self.isVideoOn = true
        validateShowEmptyRoomMessage()
    }

    func onSessionLeave() {
        self.dismiss(animated: true)
    }

    func onUserJoin(_ helper: ZoomVideoSDKUserHelper?, users userArray: [ZoomVideoSDKUser]?) {
        validateShowEmptyRoomMessage()
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
        // for i in 0..<userArray!.count{
        //     if userOnSecondView == userArray![i]{
        //         switchMainUserWithSecondaryUser()
        //     }
        // }
    }

    func onUserLeave(_ helper: ZoomVideoSDKUserHelper?, users userArray: [ZoomVideoSDKUser]?) {
        validateShowEmptyRoomMessage()
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
            zoomInstance?.getAudioHelper().muteAudio(myself)
            self.isAudioOn = false
            if let image = UIImage(named: "ic_mic_off_114.png"){
                toggleMicButton.setImage(image, for: .normal)
            }
        } else {
            zoomInstance?.getAudioHelper().unmuteAudio(myself)
            self.isAudioOn = true
            if let image = UIImage(named: "ic_mic_on_114.png"){
                toggleMicButton.setImage(image, for: .normal)
            }
        }
    }

    @IBAction func hangupOnClick(_ sender: UIButton) {
        // The web client expects that the participants will turn off the video before leaving the call
        if self.isVideoOn{
            zoomInstance?.getVideoHelper().stopVideo()
            self.isVideoOn = false
        }

        zoomInstance?.leaveSession(false)
    }
    
    
    
    func subscribeUserView(view:UIView, user: ZoomVideoSDKUser?){
        let videoAspect = ZoomVideoSDKVideoAspect.panAndScan
        let resolution = ZoomVideoSDKVideoResolution._Auto
        
        // If user is sharing, subscribe users share video. If not, try user camera video.
        if user != nil{
            if user?.getShareCanvas()?.shareStatus()?.sharingStatus != ZoomVideoSDKReceiveSharingStatus.none{
                if let usersVideoCanvas = user?.getShareCanvas(){
                    usersVideoCanvas.subscribe(with: view, aspectMode: .letterBox, andResolution: resolution)
                }
            } else if let usersVideoCanvas = user?.getVideoCanvas() {
                usersVideoCanvas.subscribe(with: view, aspectMode: videoAspect, andResolution: resolution)
            }
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
    
    func validateShowEmptyRoomMessage(){
        emptyRoomMessage.text = emptyMessage
        if (zoomInstance?.getSession()?.getRemoteUsers()?.count == 0){
            emptyRoomMessage.isHidden = false
        } else {
            emptyRoomMessage.isHidden = true
        }
    }
    
    func bootStrapUITextView(){
        // loadingIcon = UIActivityIndicatorView(style: .large)
        // loadingIcon.translatesAutoresizingMaskIntoConstraints = false
        // loadingIcon.hidesWhenStopped = true
        // view.addSubview(loadingIcon)

        // let centerXConstraint = loadingIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        // let centerYConstraint = loadingIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        // NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])

        // loadingIcon.startAnimating()

        emptyRoomMessage = UITextView()

        // Set the text alignment to center
        emptyRoomMessage.textAlignment = .center
        emptyRoomMessage.font = UIFont.systemFont(ofSize: 20)

        // Add the UITextView object as a subview of the view
        view.addSubview(emptyRoomMessage)

        // Disable the autoresizing mask translation
        emptyRoomMessage.translatesAutoresizingMaskIntoConstraints = false

        // Create constraints for the UITextView object
        let centerXConstraint = emptyRoomMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let centerYConstraint = emptyRoomMessage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let widthConstraint = emptyRoomMessage.widthAnchor.constraint(equalToConstant: 200)
        let heightConstraint = emptyRoomMessage.heightAnchor.constraint(equalToConstant: 100)

        // Activate the constraints
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint, widthConstraint, heightConstraint])
        // Do any additional setup after loading the view.
    }
    
 
    
    
    func onUserShareStatusChanged(_ helper: ZoomVideoSDKShareHelper?, user: ZoomVideoSDKUser?, status: ZoomVideoSDKReceiveSharingStatus) {
            let videoAspect = ZoomVideoSDKVideoAspect.panAndScan
            let resolution = ZoomVideoSDKVideoResolution._Auto
            switch status {
                    case .start:
                if let usersShareCanvas = user?.getShareCanvas(){
//                            if user?.getID() == userOnMainView?.getID(){
//                                isMainUserSharing = true
//                                usersShareCanvas.subscribe(with: mainView, aspectMode: videoAspect, andResolution: resolution)
//                            } else {
//                                isSecondUserSharing = true
//                                usersShareCanvas.subscribe(with: secondPreview, aspectMode: videoAspect, andResolution: resolution)
//                            }
                        if user?.getID() == userOnMainView?.getID(){
                            subscribeUserView(view: mainView, user: userOnMainView)
                        } else {                        subscribeUserView(view: secondPreview, user: userOnSecondView)
                        }
                    }
                case .stop:
                    if user?.getID() == userOnMainView?.getID(){
                        subscribeUserView(view: mainView, user: userOnMainView)
                    } else {                        
                        subscribeUserView(view: secondPreview, user: userOnSecondView)
                    }
                default:
                    break
            }
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
