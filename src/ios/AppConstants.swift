//
//  AppConstants.swift
//  Runner
//
//  Created by Muhammad Arslan Khalid on 02/10/2024.
//

import Foundation
import UIKit
struct AppConstants {
    
    static var safeArea: UIEdgeInsets {
        var padding: UIEdgeInsets = UIEdgeInsets.zero
        var window: UIWindow?
    
        if #available(iOS 13, *) {
            window = UIApplication.shared.connectedScenes.filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
        }
        else {
            window = UIApplication.shared.keyWindow
        }
        
        if let b = window?.safeAreaInsets {
            padding = b
        }
        return padding
    }
}
