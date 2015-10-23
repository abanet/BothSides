//
//  UIImage+extension.swift
//  Both Sides
//
//  Created by Alberto Banet Masa on 19/10/15.
//  Copyright © 2015 abanet. All rights reserved.
//

import UIKit

extension UIImage {
    var topHalf: UIImage {
        return UIImage(CGImage: CGImageCreateWithImageInRect(CGImage, CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width, height: size.height/2)))!, scale: 1, orientation: imageOrientation)
    }
    var bottomHalf: UIImage {
        return UIImage(CGImage: CGImageCreateWithImageInRect(CGImage, CGRect(origin: CGPoint(x: 0,  y: CGFloat(Int(size.height)-Int((size.height/2)))),  size: CGSize(width: size.width, height: CGFloat(Int(size.height)-Int((size.height/2))))))!, scale: 1, orientation: imageOrientation)
    }
    var leftHalf: UIImage {
        return UIImage(CGImage: CGImageCreateWithImageInRect(CGImage, CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width/2, height: size.height)))!, scale: 1, orientation: imageOrientation)
    }
    var rightHalf: UIImage {
        return UIImage(CGImage: CGImageCreateWithImageInRect(CGImage, CGRect(origin: CGPoint(x: CGFloat(Int(size.width)-Int((size.width/2))), y: 0), size: CGSize(width: CGFloat(Int(size.width)-Int((size.width/2))), height: size.height)))!, scale: 1, orientation: imageOrientation)
    }
}