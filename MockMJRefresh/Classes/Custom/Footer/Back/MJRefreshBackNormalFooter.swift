//
//  MJRefreshBackNormalFooter.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/5.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit

open class MJRefreshBackNormalFooter: MJRefreshBackStateFooter{

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
            arrowCenterX -= labelLeftInset + stateLabel.mj_textWidth * 0.5
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
    
    
    open override func stateSetAction(oldState: MJRefreshState, newState: MJRefreshState) {
        super.stateSetAction(oldState: oldState, newState: newState)
        
        // 根据状态做事情
        if state == .idle {
            if oldState == .refreshing {
                arrowView.transform = CGAffineTransform(rotationAngle: 0.000001 - .pi)
                UIView.animate(withDuration: TimeInterval(MJRefreshSlowAnimationDuration), animations: {
                    self.loadingView.alpha = 0.0
                }) { finished in
                    // 防止动画结束后，状态已经不是idle
                    if self.state != .idle {
                        return
                    }

                    self.loadingView.alpha = 1.0
                    self.loadingView.stopAnimating()

                    self.arrowView.isHidden = false
                }
            } else {
                arrowView.isHidden = false
                loadingView.stopAnimating()
                UIView.animate(withDuration: TimeInterval(MJRefreshFastAnimationDuration), animations: {
                    self.arrowView.transform = CGAffineTransform(rotationAngle: 0.000001 - .pi)
                })
            }
        }else if state == .pulling {
            arrowView.isHidden = false
            loadingView.stopAnimating()
            UIView.animate(withDuration: TimeInterval(MJRefreshFastAnimationDuration), animations: {
                self.arrowView.transform = CGAffineTransform.identity
            })
        } else if state == .refreshing {
            arrowView.isHidden = true
            loadingView.startAnimating()
        } else if state == .noMoreData {
            arrowView.isHidden = true
            loadingView.stopAnimating()
        }

        
    }
    
    
}
