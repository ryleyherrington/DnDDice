//
//  Extensions.swift
//  DiceRoller
//
//  Created by Herrington, Ryley on 6/19/18.
//  Copyright © 2018 Herrington. All rights reserved.
//

import Foundation
import UIKit

//MARK: - [safe:]
public extension Collection {
    // Returns the element at the specified index if its within bounds, otherwise nil.
    public subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

//MARK: - Global Color
public extension UIColor {
    //UIColor(red: 56/255, green: 114/255, blue: 180/255, alpha: 1.0)
    public static let globalColor = UIColor(hex: "#3872B4")

    public convenience init(hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count != 6 {
            self.init(cgColor: UIColor.gray.cgColor)
            return
        }

        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: CGFloat(1.0))
    }
}
