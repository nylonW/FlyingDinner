//
//  ScreenShareHelper.swift
//  catchThis
//
//  Created by Marcin Slusarek on 23/07/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import UIKit

class ScreenShareHelper {
    static var app: ScreenShareHelper = {
        return ScreenShareHelper()
    }()
    
    func captureScreen(in view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func shareImage(image: UIImage, in vc: UIViewController) {
        let activityItem: [AnyObject] = [image as AnyObject]
        let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        vc.present(avc, animated: true, completion: nil)
    }
    
    func captrueAndShare(in vc: UIViewController) {
        shareImage(image: captureScreen(in: vc.view), in: vc)
        
    }
}
