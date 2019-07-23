//
//  UIScreen+sizeType.swift
//  catchThis
//
//  Created by Marcin Slusarek on 23/07/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import UIKit

extension UIScreen {
    
    enum SizeType: CGFloat {
        case Unknown = 0.0
        case iPhone4 = 960.0
        case iPhone5 = 1136.0
        case iPhone6 = 1334.0
        case iPhone6Plus = 1920.0
    }
    
    var sizeType: SizeType {
        let height = nativeBounds.height
        guard let sizeType = SizeType(rawValue: height) else { return .Unknown }
        return sizeType
    }
}
