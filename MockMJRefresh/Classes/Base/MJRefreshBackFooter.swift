//
//  MJRefreshBackFooter.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/5.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit

public class MJRefreshBackFooter: MJRefreshFooter{
    
    var lastRefreshCount = 0
    var lastBottomDelta: CGFloat = 0.0
    
    // MARK: - 初始化
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.scrollViewContentSizeDidChange(nil)
    }
    
    // MARK: - 实现父类方法
    override func scrollViewContentOffsetDidChange(_ change: [AnyHashable : Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        
        // 当前的contentOffset
        let currentOffsetY = scrollView?.mj_offsetY ?? 0
        
        // 尾部控件刚好出现的offsetY
        let happenOffsetY = self.happenOffsetY()
        // 如果是向下滚动到看不见尾部控件，直接返回
        if (currentOffsetY <= happenOffsetY) {return}
        
        let pullingPercent = (currentOffsetY - happenOffsetY) / mj_h
        
        // 如果已全部加载，仅设置pullingPercent，然后返回
        if (self.state == .noMoreData) {
            self.pullingPercent = pullingPercent;
            return;
        }
        
        if scrollView?.isDragging ?? false{
            self.pullingPercent = pullingPercent
            // 普通 和 即将刷新 的临界点
            let normal2pullingOffsetY: CGFloat = happenOffsetY + mj_h
            
            if state == .idle && currentOffsetY > normal2pullingOffsetY {
                // 转为即将刷新状态
                self.state = .pulling
            } else if state == .pulling && currentOffsetY <= normal2pullingOffsetY {
                // 转为普通状态
                self.state = .idle
            }
        } else if state == .pulling {
            // 即将刷新 && 手松开
            // 开始刷新
            beginRefreshing()
        } else if pullingPercent < 1 {
            self.pullingPercent = pullingPercent
        }
        
        
    }
    
    
    override func scrollViewContentSizeDidChange(_ change: [AnyHashable : Any]?) {
        super.scrollViewContentSizeDidChange(change)
        
        // 内容的高度
        let contentHeight: CGFloat = scrollView?.mj_contentH ?? 0 + self.ignoredScrollViewContentInsetBottom
        // 表格的高度
        let temp_mj_h: CGFloat = scrollView?.mj_h ?? 0.0
        let temp_scrollViewOriginalInset_top: CGFloat = scrollViewOriginalInset?.top ?? 0.0
        let temp_scrollViewOriginalInset_bottom :CGFloat = scrollViewOriginalInset?.bottom ?? 0.0
        let scrollHeight: CGFloat = temp_mj_h - temp_scrollViewOriginalInset_top - temp_scrollViewOriginalInset_bottom + self.ignoredScrollViewContentInsetBottom
        // 设置位置和尺寸
        mj_y = max(contentHeight, scrollHeight)
    }
    
    public override func stateSetAction(oldState: MJRefreshState, newState: MJRefreshState) {
        super.stateSetAction(oldState: oldState, newState: newState)
        
        // MARK: - 根据状态来设置属性
        if self.state == .noMoreData ||  self.state == .idle {
            // 刷新完毕
            if .refreshing == oldState {
                UIView.animate(withDuration: TimeInterval(MJRefreshSlowAnimationDuration), animations: {
                    if self.endRefreshingAnimationBeginAction != nil {
                        self.endRefreshingAnimationBeginAction!()
                    }
                    
                    self.scrollView?.mj_insetB -= self.lastBottomDelta
                    // 自动调整透明度
                    if self.isAutomaticallyChangeAlpha ?? false {
                        self.alpha = 0.0
                    }
                }) { finished in
                    self.pullingPercent = 0.0
                    
                    if self.endRefreshingCompletionBlock != nil{
                        self.endRefreshingCompletionBlock!()
                    }
                }
                
                let deltaH = heightForContentBreakView()
                // 刚刷新完毕
                let temp_mj_totalDataCount:Int = self.scrollView?.mj_totalDataCount ?? 0
                if .refreshing == oldState && deltaH > 0 &&  temp_mj_totalDataCount != lastRefreshCount {
                    self.scrollView?.mj_offsetY = self.scrollView?.mj_offsetY ?? 0.0
                }
            }else if state == .refreshing{
                // 记录刷新前的数量
                lastRefreshCount = scrollView?.mj_totalDataCount ?? 0
                
                UIView.animate(withDuration: TimeInterval(MJRefreshFastAnimationDuration), animations: {
                    let temp_scrollViewOriginalInset_bottom: CGFloat = self.scrollViewOriginalInset?.bottom ?? 0
                    var bottom: CGFloat = self.mj_h + temp_scrollViewOriginalInset_bottom
                    let deltaH = self.heightForContentBreakView()
                    if deltaH < 0 {
                        // 如果内容高度小于view的高度
                        bottom -= deltaH
                    }
                    let temp_mj_insetB: CGFloat = self.scrollView?.mj_insetB ?? 0
                    self.lastBottomDelta = bottom - temp_mj_insetB
                    self.scrollView?.mj_insetB = bottom
                    self.scrollView?.mj_offsetY = self.happenOffsetY() + self.mj_h
                }) { finished in
                    self.executeRefreshingCallback()
                }
            }
        }else if state == .refreshing{
            // 记录刷新前的数量
            lastRefreshCount = scrollView?.mj_totalDataCount ?? 0

            UIView.animate(withDuration: TimeInterval(MJRefreshFastAnimationDuration), animations: {
                var bottom: CGFloat = self.mj_h + (self.scrollViewOriginalInset?.bottom ?? 0)
                let deltaH = self.heightForContentBreakView()
                if deltaH < 0 {
                    // 如果内容高度小于view的高度
                    bottom -= deltaH
                }
                self.lastBottomDelta = bottom - (self.scrollView?.mj_insetB ?? 0)
                self.scrollView?.mj_insetB = bottom
                self.scrollView?.mj_offsetY = self.happenOffsetY() + self.mj_h
            }) { finished in
                self.executeRefreshingCallback()
            }

        }
    }
    
    
    //MARK: - 私有方法
    private func heightForContentBreakView() -> CGFloat{
        let h = (self.scrollView?.frame.size.height ?? 0 ) - (self.scrollViewOriginalInset?.bottom ?? 0)  - (self.scrollViewOriginalInset?.top  ?? 0)
        return (self.scrollView?.contentSize.height ?? 0) - h
    }
    
    private func happenOffsetY() -> CGFloat{
        let deltaH = heightForContentBreakView()
        if deltaH > 0 {
            return deltaH - (self.scrollViewOriginalInset?.top ?? 0)
        } else {
            return -(self.scrollViewOriginalInset?.top ?? 0)
        }
        
    }
    
}

