//
//  MJRefreshAutoGifFooter.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/5.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit

open class  MJRefreshAutoGifFooter: MJRefreshAutoStateFooter{
    
    /// 所有状态对应的动画图片
    var stateImages: [String : [UIImage]] = [String : [UIImage]]()
    
    /// 所有状态对应的动画时间
    var stateDurations: [String : NSNumber] =  [String : NSNumber]()
    
    public lazy var gifView: UIImageView = {
        let gifView = UIImageView ()
        return gifView
    }()
    
    public override func setUpUI() {
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
    
    open override func placeSubviews() {
        super.placeSubviews()
        
        if gifView.constraints.count > 0 {
            return
        }

        gifView.frame = bounds
        if isRefreshingTitleHidden {
            gifView.contentMode = .center
        } else {
            gifView.contentMode = .right
            gifView.mj_w = mj_w * 0.5 - labelLeftInset - stateLabel.mj_textWidth * 0.5
        }
        
    }
    
    
    open override func stateSetAction(oldState: MJRefreshState, newState: MJRefreshState) {
        super.stateSetAction(oldState: oldState, newState: newState)
        // 根据状态做事情
        if newState == .refreshing {
            let images = stateImages["\(newState)"]
            if images?.count == 0 {
                return
            }

            gifView.isHidden = false
            gifView.stopAnimating()
            if images?.count == 1 {
                // 单张图片
                gifView.image = images?.last
            } else {
                // 多张图片
                gifView.animationImages = images
                gifView.animationDuration = CFTimeInterval((stateDurations["\(newState)"])?.doubleValue ?? 0.25)
                gifView.startAnimating()
            }
            
        } else if newState == .noMoreData || newState == .idle {
            gifView.stopAnimating()
            gifView.isHidden = true
        }
        
    }
    
}
