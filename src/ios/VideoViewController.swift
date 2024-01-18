//
//  VideoViewController.swift
//  HelloCordova
//
//  Created by Henrique Silva on 17/01/24.
//

import UIKit
import ZoomVideoSDK
import ZoomVideoSDKUIToolkit

class VideoViewController: UIViewController {

    @IBOutlet weak var secondPreview: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var newView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {

        let user = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()
        if let videoHelper = ZoomVideoSDK.shareInstance()?.getVideoHelper() {
            videoHelper.startVideoCanvasPreview(self.newView, andAspectMode: .panAndScan)

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
