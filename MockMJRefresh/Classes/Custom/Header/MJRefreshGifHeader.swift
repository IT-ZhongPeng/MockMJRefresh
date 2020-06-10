//
//  MJRefreshGifHeader.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/5.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit

open class MJRefreshGifHeader: MJRefreshStateHeader{
    
    /// 所有状态对应的动画图片
    var stateImages: [String : [UIImage]] = [String : [UIImage]]()
    
    /// 所有状态对应的动画时间
    var stateDurations: [String : NSNumber] =  [String : NSNumber]()
    
    public lazy var gifView: UIImageView = {
        let gifView = UIImageView ()
        return gifView
    }()
    
    open override func setUpUI() {
        super.setUpUI()
        
        self.addSubview(self.gifView)
    }
    
    // MARK: - 公共方法
    public func setImages(_ images: [UIImage]?, duration: TimeInterval, for state: MJRefreshState) {
        if images == nil {
            return
        }

        if let images = images {
            stateImages["\(state)"] = images
        }
        stateDurations["\(state)"] = NSNumber(value: duration)

        // 根据图片设置控件的高度
        let image = images?.first
        if (image?.size.height ?? 0.0) > mj_h {
            mj_h = image?.size.height ?? 15
        }
    }

    public func setImages(_ images: [UIImage]?, for state: MJRefreshState) {
        setImages(images, duration: Double(images?.count ?? 0) * 0.1, for: state)
    }

    open override func prepare() {
         super.prepare()
         self.labelLeftInset = 20
     }
    
    open override func pullingPercentSetAction() {
        super.pullingPercentSetAction()
        let images = self.stateImages["\(MJRefreshState.idle)"]
        if state != .idle || images?.count == 0 {
            return
        }
        // 停止动画
        gifView.stopAnimating()
        // 设置当前需要显示的图片
        var index = CGFloat(images?.count ?? 0) * pullingPercent
        if index >= CGFloat(images?.count ?? 0) {
            index = CGFloat(images?.count ?? 0) - 1
        }
        gifView.image = images?[Int(index)]
        
    }
    
 
    
    open override func placeSubviews() {
        super.placeSubviews()
        if self.gifView.constraints.count > 0 {
            return
        }
        
        gifView.frame = bounds
        if stateLabel.isHidden && lastUpdatedTimeLabel.isHidden {
            gifView.contentMode = .center
        } else {
            gifView.contentMode = .right

            let stateWidth = stateLabel.mj_textWidth
            var timeWidth: CGFloat = 0.0
            if !lastUpdatedTimeLabel.isHidden {
                timeWidth = lastUpdatedTimeLabel.mj_textWidth
            }
            let textWidth = CGFloat(max(stateWidth, timeWidth))
            gifView.mj_w = mj_w * 0.5 - textWidth * 0.5 - labelLeftInset
        }
        
    }
    
    open override func stateSetAction(oldState: MJRefreshState, newState: MJRefreshState) {
        super.stateSetAction(oldState: oldState, newState: newState)
        // 根据状态做事情
        if state == .pulling || state == .refreshing {
            let images = stateImages["\(state!)"]
            if images?.count == 0 {
                return
            }

            gifView.stopAnimating()
            if images?.count == 1 {
                // 单张图片
                gifView.image = images?.last
            } else {
                // 多张图片
                gifView.animationImages = images
                gifView.animationDuration = CFTimeInterval((stateDurations["\(state!)"])?.doubleValue ?? 0.25)
                gifView.startAnimating()
            }
        } else if state == .idle {
            gifView.stopAnimating()
        }
    }
    
}
