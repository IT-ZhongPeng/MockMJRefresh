//
//  UILable+MJExtension.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/4.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit

internal extension UILabel{
    
    public class func mj_label() -> Self {
        let label = self.init()
        label.font = MJRefreshLabelFont
        label.textColor = MJRefreshLabelTextColor
        label.autoresizingMask = .flexibleWidth
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        return label
    }
    
    public var mj_textWidth: CGFloat{
        var stringWidth: CGFloat = 0
               let size = CGSize (width: 100000, height: 100000)

               
               if attributedText != nil {
                   if attributedText?.length == 0 {
                       return 0
                   }
                   
                   
                   stringWidth = attributedText?.boundingRect(
                       with: size,
                       options: .usesLineFragmentOrigin,
                       context: nil).size.width ?? 0.0
               } else {
                   if text?.count == 0 {
                       return 0
                   }
                   assert(font != nil, "请检查 mj_label's `font` 是否设置正确")
                   stringWidth = text?.boundingRect(
                       with: size,
                       options: .usesLineFragmentOrigin,
                       attributes: [
                           NSAttributedString.Key.font: font ?? UIFont.systemFont(ofSize: 14)
                       ],
                       context: nil).size.width ?? 0.0
               }
               return stringWidth
    }
    
}
