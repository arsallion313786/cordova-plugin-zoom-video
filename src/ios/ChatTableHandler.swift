//
//  ChatTableHandler.swift
//  NativeBupaZoomApp
//
//  Created by Muhammad Arslan Khalid on 01/10/2024.
//

import UIKit
import ZoomVideoSDK

class ChatTableHandler: NSObject {
    
    private weak var tblView:UITableView!
    private var messages:[ZoomVideoSDKChatMessage]!
    init(tblView: UITableView!, messages:[ZoomVideoSDKChatMessage]) {
        self.tblView = tblView;
        self.messages = messages;
        super.init();
        self.registerNib();
        self.confireTableView();
    }
    
    
    func reloadData(messages:[ZoomVideoSDKChatMessage]? = nil){
        if let messages{
            self.messages = messages
        }
        self.tblView.reloadData();
    }
    
}

//MARK: Utility Methods
extension ChatTableHandler{
    func registerNib(){
        self.tblView.register(UINib(nibName: "ZoomChatCell", bundle: nil), forCellReuseIdentifier: "ZoomChatCell");
    }
    
    func confireTableView(){
        self.tblView.dataSource = self;
        
        self.tblView.estimatedRowHeight = 92;
        self.tblView.rowHeight = UITableView.automaticDimension;
    }
}

//MARK: TableView DataSource Methods
extension ChatTableHandler:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.messages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell  = tableView.dequeueReusableCell(withIdentifier: "ZoomChatCell") as? ZoomChatCell else {fatalError("ZoomChatCell not registered")}
        let msg = self.messages[indexPath.row];
        cell.lblUsername.text = msg.senderUser?.getName() ?? "unknown";
        cell.lblChatContent.text = msg.content ?? "N/A";
        cell.lblTime.text = Date(timeIntervalSince1970: TimeInterval(msg.timeStamp)).getStringFromDate();
        //Date(timeIntervalSince1970: TimeInterval(msg.timeStamp)).formatted(.dateTime);
        return cell;
        
    }
}


extension Date{
    func getStringFromDate() -> String{
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "dd/MM/yyyy, hh:mm:ss a";
        dateFormatter.locale = Locale(identifier: "en_US");
        return dateFormatter.string(from: self);
    }
}


