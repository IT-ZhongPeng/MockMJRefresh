//
//  MJRefreshNormalHeader.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/5.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit

public class MJRefreshNormalHeader: MJRefreshStateHeader{
    
    public lazy var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView ()
        if #available(iOS 13.0, *) {
            loadingView.style = UIActivityIndicatorView.Style.medium
        }else{
            loadingView.style = UIActivityIndicatorView.Style.gray
        }
        loadingView.hidesWhenStopped = true
        return loadingView
    }()
    
    public lazy var arrowView: UIImageView  = {
        let arrowView: UIImageView = UIImageView (image: Bundle.mj_arrowImage())
        return arrowView
    }()
    
    public override func setUpUI() {
        super.setUpUI()
        self.addSubview(self.loadingView)
        self.addSubview(self.arrowView)
    }
    
    public override func placeSubviews() {
        super.placeSubviews()
        
        // 箭头的中心点
        var arrowCenterX: CGFloat = mj_w * 0.5
        if !stateLabel.isHidden {
            let stateWidth = stateLabel.mj_textWidth
            var timeWidth: CGFloat = 0.0
            if !lastUpdatedTimeLabel.isHidden {
                timeWidth = lastUpdatedTimeLabel.mj_textWidth
            }
            let textWidth = CGFloat(max(stateWidth, timeWidth))
            arrowCenterX -= textWidth / 2 + labelLeftInset
        }
        let arrowCenterY: CGFloat = mj_h * 0.5
        let arrowCenter = CGPoint(x: arrowCenterX, y: arrowCenterY)
        
        // 箭头
        if arrowView.constraints.count == 0 {
            arrowView.mj_size = arrowView.image?.size ?? CGSize (width: 15, height: 15)
            arrowView.center = arrowCenter
        }
        
        // 圈圈
        if loadingView.constraints.count == 0 {
            loadingView.center = arrowCenter
        }
        
        arrowView.tintColor = stateLabel.textColor
        
    }
    
    
    public override func stateSetAction(oldState: MJRefreshState, newState: MJRefreshState) {
        super.stateSetAction(oldState: oldState, newState: newState)
        
        // 根据状态做事情
        if state == .idle {
            if oldState == .refreshing {
                arrowView.transform = CGAffineTransform.identity
                
                UIView.animate(withDuration: TimeInterval(MJRefreshSlowAnimationDuration), animations: {
                    self.loadingView.alpha = 0.0
                }) { finished in
                    // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
                    if self.state != .idle {
                        return
                    }
                    
                    self.loadingView.alpha = 1.0
                    self.loadingView.stopAnimating()
                    self.arrowView.isHidden = false
                }
            } else {
                loadingView.stopAnimating()
                arrowView.isHidden = false
                UIView.animate(withDuration: TimeInterval(MJRefreshFastAnimationDuration), animations: {
                    self.arrowView.transform = CGAffineTransform.identity
                })
            }
        }else if self.state == .pulling {
            loadingView.stopAnimating()
            arrowView.isHidden = false
            UIView.animate(withDuration: TimeInterval(MJRefreshFastAnimationDuration), animations: {
                self.arrowView.transform = CGAffineTransform(rotationAngle: 0.000001 - .pi)
            })
        } else if self.state == .refreshing {
            loadingView.alpha = 1.0 // 防止refreshing -> idle的动画完毕动作没有被执行
            loadingView.startAnimating()
            arrowView.isHidden = true
        }

    }
    
}
