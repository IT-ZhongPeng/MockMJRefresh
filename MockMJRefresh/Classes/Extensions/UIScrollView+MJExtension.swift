//
//  UIScrollView+MJExtension.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/4.
//  Copyright © 2020 nmxy. All rights reserved.
//

import UIKit

internal extension UIScrollView {
    var mj_inset: UIEdgeInsets {
        get {
            if #available(iOS 11, *) {
                return self.adjustedContentInset
            } else {
                return self.contentInset
            }
        }
    }
    var mj_insetT: CGFloat {
        get { return mj_inset.top }
        set {
            var inset = self.contentInset
            inset.top = newValue
            if #available(iOS 11, *) {
                inset.top -= self.safeAreaInsets.top
            }
            self.contentInset = inset
        }
    }
    var mj_insetB: CGFloat {
        get { return mj_inset.bottom }
        set {
            var inset = self.contentInset
            inset.bottom = newValue
            if #available(iOS 11, *) {
                inset.bottom -= self.safeAreaInsets.bottom
            }
            self.contentInset = inset
        }
    }
    var mj_insetL: CGFloat {
        get { return mj_inset.left }
        set {
            var inset = self.contentInset
            inset.left = newValue
            if #available(iOS 11, *) {
                inset.left -= self.safeAreaInsets.left
            }
            self.contentInset = inset
        }
    }
    var mj_insetR: CGFloat {
        get { return mj_inset.right }
        set {
            var inset = self.contentInset
            inset.right = newValue
            if #available(iOS 11, *) {
                inset.right -= self.safeAreaInsets.right
            }
            self.contentInset = inset
        }
    }
    
    
    var mj_offsetX: CGFloat {
        get { return contentOffset.x }
        set {
            var offset = self.contentOffset
            offset.x = newValue
            self.contentOffset = offset
        }
    }
    var mj_offsetY: CGFloat {
        get { return contentOffset.y }
        set {
            var offset = self.contentOffset
            offset.y = newValue
            self.contentOffset = offset
        }
    }
    
    
    var mj_contentW: CGFloat {
        get { return contentSize.width }
        set {
            var size = self.contentSize
            size.width = newValue
            self.contentSize = size
        }
    }
    var mj_contentH: CGFloat {
        get { return contentSize.height }
        set {
            var size = self.contentSize
            size.height = newValue
            self.contentSize = size
        }
    }
}



