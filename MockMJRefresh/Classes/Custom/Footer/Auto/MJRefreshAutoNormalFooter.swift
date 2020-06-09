//
//  MJRefreshAutoNormalFooter.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/5.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit

public class MJRefreshAutoNormalFooter: MJRefreshAutoStateFooter{
    
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
    
    public override func setUpUI() {
        super.setUpUI()
        self.addSubview(self.loadingView)
    }
    
    public override func placeSubviews() {
        super.placeSubviews()
        
        if loadingView.constraints.count > 0 {
            return
        }

        // 圈圈
        var loadingCenterX: CGFloat = mj_w * 0.5
        if !isRefreshingTitleHidden {
            loadingCenterX -= stateLabel.mj_textWidth * 0.5 + labelLeftInset
        }
        let loadingCenterY: CGFloat = mj_h * 0.5
        loadingView.center = CGPoint(x: loadingCenterX, y: loadingCenterY)
    }
    
    
    public override func stateSetAction(oldState: MJRefreshState, newState: MJRefreshState) {
        super.stateSetAction(oldState: oldState, newState: newState)
        
        // 根据状态做事情
        if state == .noMoreData || state == .idle {
            loadingView.stopAnimating()
        } else if state == .refreshing {
            loadingView.startAnimating()
        }
        
    }
    
}
