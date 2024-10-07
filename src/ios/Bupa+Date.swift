//
//  Bupa+Date.swift
//  NativeBupaZoomApp
//
//  Created by Muhammad Arslan Khalid on 01/10/2024.
//

import Foundation
extension Date{
    func dHMS(fromDate:Date) -> (d:Int, h:Int, m:Int, s:Int){
        let component =  Calendar.current.dateComponents([.day,.hour,.minute,.second], from: fromDate, to: self)
        return(component.day ?? 0, component.hour ?? 0, component.minute ?? 0, component.second ?? 0)
    }
}
