//
//  MJRefreshConst.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/4.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit

let MJRefreshLabelFont:UIFont = UIFont.systemFont(ofSize: 14)

let MJRefreshLabelTextColor:UIColor = UIColor (red: 90/255.0, green:  90/255.0, blue:  90/255.0, alpha: 1)

let MJRefreshLabelLeftInset: CGFloat = 25.0
let MJRefreshHeaderHeight: CGFloat = 54.0
let MJRefreshFooterHeight: CGFloat = 44.0
let MJRefreshFastAnimationDuration: CGFloat = 0.25
let MJRefreshSlowAnimationDuration: CGFloat = 0.4

let MJRefreshKeyPathContentOffset = "contentOffset"
let MJRefreshKeyPathContentInset = "contentInset"
let MJRefreshKeyPathContentSize = "contentSize"
let MJRefreshKeyPathPanState = "state"

let MJRefreshHeaderLastUpdatedTimeKey = "MJRefreshHeaderLastUpdatedTimeKey"

let MJRefreshHeaderIdleText = "MJRefreshHeaderIdleText"
let MJRefreshHeaderPullingText = "MJRefreshHeaderPullingText"
let MJRefreshHeaderRefreshingText = "MJRefreshHeaderRefreshingText"

let MJRefreshAutoFooterIdleText = "MJRefreshAutoFooterIdleText"
let MJRefreshAutoFooterRefreshingText = "MJRefreshAutoFooterRefreshingText"
let MJRefreshAutoFooterNoMoreDataText = "MJRefreshAutoFooterNoMoreDataText"

let MJRefreshBackFooterIdleText = "MJRefreshBackFooterIdleText"
let MJRefreshBackFooterPullingText = "MJRefreshBackFooterPullingText"
let MJRefreshBackFooterRefreshingText = "MJRefreshBackFooterRefreshingText"
let MJRefreshBackFooterNoMoreDataText = "MJRefreshBackFooterNoMoreDataText"

let MJRefreshHeaderLastTimeText = "MJRefreshHeaderLastTimeText"
let MJRefreshHeaderDateTodayText = "MJRefreshHeaderDateTodayText"
let MJRefreshHeaderNoneLastDateText = "MJRefreshHeaderNoneLastDateText"
