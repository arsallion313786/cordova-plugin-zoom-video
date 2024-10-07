//
//  Bupa+View.swift
//  NativeBupaZoomApp
//
//  Created by Muhammad Arslan Khalid on 26/09/2024.
//

import Foundation
import UIKit

extension UIView{
    func roundEdges()
    {
        self.layer.masksToBounds = true;
        self.layer.cornerRadius = self.frame.size.height / 2.0;
    }
    
    func roundEdges(corners:UIRectCorner, radius: CGFloat) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.frame = self.bounds
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
    
    func roundEdgesWithShadow(corners:UIRectCorner, radius: CGFloat, color: UIColor = .black,
                              alpha: Float = 0.5,
                              x: CGFloat = 0,
                              y: CGFloat = 2,
                              blur: CGFloat = 4,
                              spread: CGFloat = 0) {
        
        let shadowLayer:CAShapeLayer = CAShapeLayer()
        
        
        shadowLayer.fillColor = self.backgroundColor?.cgColor;
        
        shadowLayer.shadowColor = color.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: x, height: y)
        shadowLayer.shadowOpacity = alpha
        shadowLayer.shadowRadius = radius
        if spread == 0 {
            shadowLayer.path = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowLayer.path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        }
        
        layer.insertSublayer(shadowLayer, at: 0)
    }
    
    
    
    
    func roundEdges(radius: CGFloat)
    {
        self.layer.masksToBounds = true;
        self.layer.cornerRadius = radius;
    }
}


extension CALayer {
    func applyShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0)
    {
        masksToBounds = false
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
