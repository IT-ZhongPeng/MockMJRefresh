//
//  UIScrollView+MJRefresh.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/4.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import ObjectiveC
import UIKit
private var MJRefreshHeaderKey = 0
private var MJRefreshFooterKey = 1
extension UIScrollView {
    
    // MARK: - mj_header
   
    @objc public var mj_header: MJRefreshHeader? {
        get {
            return objc_getAssociatedObject(self, &MJRefreshHeaderKey) as? MJRefreshHeader
        }
        set {
            
            if newValue != self.mj_header {
                // 删除旧的，添加新的
                self.mj_header?.removeFromSuperview()
                if let header = newValue {
                    insertSubview(header, at: 0)
                }
                // 存储新的
                objc_setAssociatedObject(
                    self,
                    &MJRefreshHeaderKey,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN)
            }
        }
    }
    
    
    // MARK: - mj_footer
    
    @objc public var mj_footer: MJRefreshFooter? {
        get {
            return objc_getAssociatedObject(self, &MJRefreshFooterKey) as? MJRefreshFooter
        }
        set {
            
            if newValue != self.mj_footer {
                // 删除旧的，添加新的
                self.mj_footer?.removeFromSuperview()
                if let footer = newValue {
                    insertSubview(footer, at: 0)
                }
                // 存储新的
                objc_setAssociatedObject(self, &MJRefreshFooterKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    // MARK: - other
    @objc public var  mj_totalDataCount: Int {
        var totalCount = 0
        if (self is UITableView) {
            let tableView = self as? UITableView

            for section in 0..<(tableView?.numberOfSections ?? 0) {
                totalCount += tableView?.numberOfRows(inSection: section) ?? 0
            }
        } else if (self is UICollectionView) {
            let collectionView = self as? UICollectionView

            for section in 0..<(collectionView?.numberOfSections ?? 0) {
                totalCount += collectionView?.numberOfItems(inSection: section) ?? 0
            }
        }
        return totalCount
    }
    
}
