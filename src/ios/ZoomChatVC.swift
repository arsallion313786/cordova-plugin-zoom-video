//
//  ZoomChatVC.swift
//  NativeBupaZoomApp
//
//  Created by Muhammad Arslan Khalid on 01/10/2024.
//

import UIKit
import ZoomVideoSDK

final class ZoomChatVC: UIViewController {
    
    @IBOutlet private weak var tblView:UITableView!
    @IBOutlet private weak var bottomConstraint:NSLayoutConstraint!
    @IBOutlet private weak var inputField:UITextField!
    
    private var arrChatMessages:[ZoomVideoSDKChatMessage] = [ZoomVideoSDKChatMessage]();
    private var chatTableHandler:ChatTableHandler!
    
    required init?(arrChatMessages:[ZoomVideoSDKChatMessage], coder: NSCoder) {
            self.arrChatMessages = arrChatMessages
            super.init(coder: coder)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.methodsOnViewLoaded()
    }
    
//    override func keyboardWillChangeFrame(to frame: CGRect) {
//        if(frame != CGRect.zero){
//            self.bottomConstraint.constant = -(frame.height - AppConstants.safeArea.bottom);
//        }
//        else{
//            self.bottomConstraint.constant = 0;
//        }
//        self.view.layoutIfNeeded(animated: true);
//        
//    }
    
    func reloadData(messages:[ZoomVideoSDKChatMessage]?){
        self.chatTableHandler.reloadData(messages: messages);
    }

}

//MARK: Btn Action Methods
private extension ZoomChatVC{
    @IBAction func btnSendChatMessagePressed(_ sender:UIButton){
        if(self.inputField.text?.isEmpty == false){
            ZoomVideoSDK.shareInstance()?.getChatHelper()?.sendChat(toAll: self.inputField.text);
            self.inputField.text = "";
        }
    }
}

//MARK: Utility Methods
private extension ZoomChatVC{
    func methodsOnViewLoaded(){
        self.configureTablehandler();
    }
    
    func configureTablehandler(){
        self.chatTableHandler = ChatTableHandler(tblView: self.tblView, messages: self.arrChatMessages);
    }
}
