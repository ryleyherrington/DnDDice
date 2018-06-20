//
//  Extensions.swift
//  DiceRoller
//
//  Created by Herrington, Ryley on 6/19/18.
//  Copyright © 2018 Herrington. All rights reserved.
//

import Foundation

//MARK: - [safe:]
public extension Collection {
    // Returns the element at the specified index if its within bounds, otherwise nil.
    public subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
