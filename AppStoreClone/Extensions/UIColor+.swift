//
//  UIColor+.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2024/01/04.
//

import UIKit

extension UIColor {
    convenience init(r: Int, g: Int, b: Int, a: CGFloat=1.0) {
        self.init(red: CGFloat(r)/255,
                  green: CGFloat(g)/255,
                  blue: CGFloat(b)/255,
                  alpha: a)
    }
}
