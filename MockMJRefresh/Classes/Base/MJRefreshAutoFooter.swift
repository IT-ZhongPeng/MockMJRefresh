//
//  MJRefreshAutoFooter.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/5.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit

open class MJRefreshAutoFooter: MJRefreshFooter{
    /// 当底部控件出现多少时就自动刷新(默认为1.0，也就是底部控件完全出现时，才会自动刷新)
    public var triggerAutomaticallyRefreshPercent: CGFloat = 0.0
   
    
    public var automaticallyRefresh: Bool = false
//    private var lastHidden: Bool = false
    public override var isHidden: Bool{
        willSet{
            
            let lastHidden = self.isHidden
            
            if  !lastHidden && newValue {
                self.state = .idle
                scrollView?.mj_insetB -= mj_h
            } else if lastHidden && !newValue {
                scrollView?.mj_insetB += mj_h

                // 设置位置
                mj_y = scrollView?.mj_contentH ?? 0
            }
        }
    }
    
    /// 自动触发次数, 默认为 1, 仅在拖拽 ScrollView 时才生效,
    /// 如果为 -1, 则为无限触发

    public var autoTriggerTimes = 0{
        didSet{
            leftTriggerTimes = autoTriggerTimes
        }
    }
    
    /// 一个新的拖拽
    private var triggerByDrag = false
    private var leftTriggerTimes = 0
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if (newSuperview != nil) {
            // 新的父控件
            if isHidden == false {
                scrollView?.mj_insetB += mj_h
            }
            
            // 设置位置
            mj_y = scrollView?.mj_contentH ?? 0
        } else {
            // 被移除了
            if isHidden == false {
                scrollView?.mj_insetB -= mj_h
            }
        }
    }
    
    
    open override func prepare() {
        super.prepare()
        // 默认底部控件100%出现时才会自动刷新
        triggerAutomaticallyRefreshPercent = 1.0
        
        // 设置为默认状态
        automaticallyRefresh = true
        
        autoTriggerTimes = 1
        
    }
    
    override func scrollViewContentSizeDidChange(_ change: [AnyHashable : Any]?) {
        super.scrollViewContentSizeDidChange(change)
        // 设置位置
        mj_y = scrollView?.mj_contentH ?? 0 + ignoredScrollViewContentInsetBottom
    }
    
    
    override func scrollViewContentOffsetDidChange(_ change: [AnyHashable : Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        
        if state != .idle || !automaticallyRefresh || mj_y == 0 {
            return
        }
        
        let temp_mj_insetT: CGFloat = scrollView?.mj_insetT ?? 0
        let temp_mj_contentH: CGFloat = scrollView?.mj_contentH ?? 0
        let temp_mj_h: CGFloat = scrollView?.mj_h ?? 0
        if temp_mj_insetT + temp_mj_contentH > temp_mj_h {
            // 内容超过一个屏幕
            // 这里的_scrollView.mj_contentH替换掉self.mj_y更为合理
            
            let temp_mj_offsetY: CGFloat = scrollView?.mj_offsetY ?? 0
            let temp_mj_insetB: CGFloat = scrollView?.mj_insetB ?? 0
            
            if temp_mj_offsetY >= temp_mj_contentH - temp_mj_h + mj_h * triggerAutomaticallyRefreshPercent + temp_mj_insetB - mj_h {
                // 防止手松开时连续调用
                let old = change?["old"] as? CGPoint  ?? CGPoint.zero
                let new = change?["new"] as? CGPoint ?? CGPoint.zero
                if new.y <= old.y {
                    return
                }
                
                if scrollView?.isDragging  ?? false{
                    triggerByDrag = true
                }
                // 当底部刷新控件完全出现时，才刷新
                beginRefreshing()
            }
        }
    }
    
    
    override func scrollViewPanStateDidChange(_ change: [AnyHashable : Any]?) {
        super.scrollViewPanStateDidChange(change)
        
        if state != .idle {
            return
        }
        
        if self.scrollView == nil {
            return
        }
        
        
        let panState:UIPanGestureRecognizer.State = scrollView!.panGestureRecognizer.state
        
        switch panState {
        // 手松开
        case UIPanGestureRecognizer.State.ended:
            if scrollView!.mj_insetT + scrollView!.mj_contentH <= scrollView!.mj_h {
                // 不够一个屏幕
                if scrollView!.mj_offsetY >= -scrollView!.mj_insetT {
                    // 向上拽
                    triggerByDrag = true
                    beginRefreshing()
                }
            } else {
                // 超出一个屏幕
                if scrollView!.mj_offsetY >= scrollView!.mj_contentH + scrollView!.mj_insetB - scrollView!.mj_h {
                    triggerByDrag = true
                    beginRefreshing()
                }
            }
        case UIPanGestureRecognizer.State.began:
            resetTriggerTimes()
        default:
            break
        }
    }
    
    func unlimitedTrigger() -> Bool {
        return leftTriggerTimes == -1
    }
    
    public override func beginRefreshing() {
        if triggerByDrag && leftTriggerTimes <= 0 && !unlimitedTrigger() {
           return
       }
        super.beginRefreshing()
    }

    func resetTriggerTimes() {
        leftTriggerTimes = autoTriggerTimes
    }

    open override func stateSetAction(oldState: MJRefreshState, newState: MJRefreshState) {
        super.stateSetAction(oldState: oldState, newState: newState)
        
        if self.scrollView == nil{
            return
        }
        
        if state == .refreshing {
            executeRefreshingCallback()
        }else if (state == .noMoreData || state == .idle) {
            if triggerByDrag {
                if !unlimitedTrigger() {
                    leftTriggerTimes -= 1
                }
                triggerByDrag = false
            }
            
            if .refreshing == oldState {
                if scrollView!.isPagingEnabled {
                    var offset = scrollView!.contentOffset
                    offset.y -= scrollView!.mj_insetB
                    UIView.animate(withDuration: TimeInterval(MJRefreshSlowAnimationDuration), animations: {
                        self.scrollView!.contentOffset = offset

                        if self.endRefreshingAnimationBeginAction != nil{
                            self.endRefreshingAnimationBeginAction!()
                        }
                    }) { finished in
                        if self.endRefreshingCompletionBlock != nil {
                            self.endRefreshingCompletionBlock!()
                        }
                    }
                    return
                }

                if endRefreshingCompletionBlock != nil{
                    endRefreshingCompletionBlock!()
                }
            }

        }

        
    }
}
