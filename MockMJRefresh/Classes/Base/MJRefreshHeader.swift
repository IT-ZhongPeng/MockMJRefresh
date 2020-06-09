//
//  MJRefreshHeader.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/4.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit


let MJRefreshHeaderRefreshing2IdleBoundsKey = "MJRefreshHeaderRefreshing2IdleBounds"
let MJRefreshHeaderRefreshingBoundsKey = "MJRefreshHeaderRefreshingBounds"


public class MJRefreshHeader: MJRefreshComponent{
    
    private var insetTDelta: CGFloat = 0.0
    
    /// 这个key用来存储上一次下拉刷新成功的时间
    public var lastUpdatedTimeKey: String?{
        didSet{
            self.lastUpdatedTimeKeySetAction(self.lastUpdatedTimeKey ?? MJRefreshHeaderLastUpdatedTimeKey)
        }
    }
    
    /// 上一次下拉刷新成功的时间
    var lastUpdatedTime: Date?{
        return UserDefaults.standard.object(forKey: lastUpdatedTimeKey ?? MJRefreshHeaderLastUpdatedTimeKey) as? Date ?? Date ()
    }
    
    /// 忽略多少scrollView的contentInset的top
    public var ignoredScrollViewContentInsetTop: CGFloat = 0.0
    
    /// 默认是关闭状态, 如果遇到 CollectionView 的动画异常问题可以尝试打开
    public var isCollectionViewAnimationBug = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required  public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setUpUI() {
        super.setUpUI()
        // 设置key
        self.lastUpdatedTimeKey = MJRefreshHeaderLastUpdatedTimeKey
    }
    
   @objc public class func header(withRefreshingBlock refreshBlock: @escaping MJRefreshComponentAction) -> Self{
        let cmd = self.init()
        cmd.refreshingBlock = refreshBlock
        return cmd
    }
    
    // MARK: - 覆盖父类的方法
    public override func prepare() {
        super.prepare()
        self.backgroundColor = UIColor.white
        // 设置高度
        self.mj_h = MJRefreshHeaderHeight
    }
    
    public override func placeSubviews() {
        super.placeSubviews()
        
        // 设置y值(当自己的高度发生改变了，肯定要重新调整Y值，所以放到placeSubviews方法中设置y值)
        mj_y = -mj_h - ignoredScrollViewContentInsetTop
    }
    
    
    func resetInset() {
        if #available(iOS 11.0, *) {
        } else {
            // 如果 iOS 10 及以下系统在刷新时, push 新的 VC, 等待刷新完成后回来, 会导致顶部 Insets.top 异常, 不能 resetInset, 检查一下这种特殊情况
            if !(window != nil) {
                return
            }
        }
        
        // sectionheader停留解决
        
        let temp_mj_offsetY:CGFloat = scrollView?.mj_offsetY ?? 0
        let temp_scrollViewOriginalInset_top:CGFloat = scrollViewOriginalInset?.top ?? 0
        
        
        var insetT =  -temp_mj_offsetY > temp_scrollViewOriginalInset_top ? -temp_mj_offsetY: temp_scrollViewOriginalInset_top
        
        
        insetT = insetT > mj_h + temp_scrollViewOriginalInset_top ? mj_h + temp_scrollViewOriginalInset_top : insetT
        insetTDelta = temp_scrollViewOriginalInset_top - insetT
        // 避免 CollectionView 在使用根据 Autolayout 和 内容自动伸缩 Cell, 刷新时导致的 Layout 异常渲染问题
        if scrollView?.mj_insetT != insetT {
            scrollView?.mj_insetT = insetT
        }
    }
    
    override func scrollViewContentOffsetDidChange(_ change: [AnyHashable : Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        
        if self.state == .refreshing {
            self.resetInset()
            return
        }
        
        
        // 跳转到下一个控制器时，contentInset可能会变
        self.scrollViewOriginalInset = self.scrollView?.mj_inset
        
        // 当前的contentOffset
        let offsetY: CGFloat = self.scrollView?.mj_offsetY ?? 0
        // 头部控件刚好出现的offsetY
        let happenOffsetY: CGFloat = -(self.scrollViewOriginalInset?.top ?? 0)
        
        // 如果是向上滚动到看不见头部控件，直接返回
        // >= -> >
        if offsetY > happenOffsetY { return }
        
        // 普通 和 即将刷新 的临界点
        let normal2pullingOffsetY: CGFloat = happenOffsetY - mj_h
        let pullingPercent: CGFloat = (happenOffsetY - offsetY) / mj_h
        
        if scrollView?.isDragging ?? false {
            // 如果正在拖拽
            self.pullingPercent = pullingPercent
            if state == .idle && offsetY < normal2pullingOffsetY {
                // 转为即将刷新状态
                state = .pulling
            } else if state == .pulling && offsetY >= normal2pullingOffsetY {
                // 转为普通状态
                state = .idle
            }
        } else if state == .pulling {
            // 即将刷新 && 手松开
            // 开始刷新
            beginRefreshing()
        } else if pullingPercent < 1 {
            self.pullingPercent = pullingPercent
        }
    }
    public override func stateSetAction(oldState: MJRefreshState, newState: MJRefreshState) {
        super.stateSetAction(oldState: oldState, newState: newState)
        
        // 根据状态做事情
        if state == .idle {
            if oldState != .refreshing {
                return
            }
            
            headerEndingAction()
        } else if state == .refreshing {
            headerRefreshingAction()
        }
    }
    
    func headerEndingAction() {
        // 保存刷新时间
        UserDefaults.standard.set(Date(), forKey: self.lastUpdatedTimeKey ?? MJRefreshHeaderLastUpdatedTimeKey )
        UserDefaults.standard.synchronize()
        
        // 默认使用 UIViewAnimation 动画
        if !isCollectionViewAnimationBug {
            // 恢复inset和offset
            UIView.animate(withDuration: TimeInterval(MJRefreshSlowAnimationDuration), animations: {
                self.scrollView?.mj_insetT += self.insetTDelta
                
                // endRefreshingAnimateCompletionBlock  endRefreshingAnimationBeginAction
                if self.endRefreshingAnimationBeginAction != nil {
                    self.endRefreshingAnimationBeginAction!()
                }
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
            return
        }
        
        // 由于修改 Inset 会导致 self.pullingPercent 联动设置 self.alpha, 故提前获取 alpha 值, 后续用于还原 alpha 动画
        let viewAlpha = alpha
        
        scrollView?.mj_insetT += insetTDelta
        // 禁用交互, 如果不禁用可能会引起渲染问题.
        scrollView?.isUserInteractionEnabled = false
        
        //CAAnimation keyPath 不支持 contentInset 用Bounds的动画代替
        let boundsAnimation = CABasicAnimation(keyPath: "bounds")
        boundsAnimation.fromValue = NSValue(cgRect: scrollView?.bounds.offsetBy(dx: 0, dy: insetTDelta) ?? CGRect.zero)
        boundsAnimation.duration = CFTimeInterval(MJRefreshSlowAnimationDuration)
        //在delegate里移除
        boundsAnimation.isRemovedOnCompletion = false
        boundsAnimation.fillMode = .both
        boundsAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        boundsAnimation.delegate = self
        boundsAnimation.setValue(MJRefreshHeaderRefreshing2IdleBoundsKey, forKey: "identity")
        
        scrollView?.layer.add(boundsAnimation, forKey: MJRefreshHeaderRefreshing2IdleBoundsKey)
        
        if (endRefreshingAnimationBeginAction != nil) {
            endRefreshingAnimationBeginAction!()
        }
        
        if isAutomaticallyChangeAlpha ?? false {
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = NSNumber(value: Float(viewAlpha))
            opacityAnimation.toValue = NSNumber(value: 0.0)
            opacityAnimation.duration = CFTimeInterval(MJRefreshSlowAnimationDuration)
            opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            layer.add(opacityAnimation, forKey: "MJRefreshHeaderRefreshing2IdleOpacity")
            
            // 由于修改了 inset 导致, pullingPercent 被设置值, alpha 已经被提前修改为 0 了. 所以这里不用置 0, 但为了代码的严谨性, 不依赖其他的特殊实现方式, 这里还是置 0.
            alpha = 0
        }
        
        
    }
    
    
    func headerRefreshingAction() {
        
        // 默认使用 UIViewAnimation 动画
        if !isCollectionViewAnimationBug {
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                
                UIView.animate(withDuration: TimeInterval(MJRefreshFastAnimationDuration), animations: {
                    if self.scrollView?.panGestureRecognizer.state != .cancelled {
                        let temp_ScrollViewOriginalInset_top: CGFloat  = self.scrollViewOriginalInset?.top ?? 0
                        let top: CGFloat = temp_ScrollViewOriginalInset_top + self.mj_h
                        // 增加滚动区域top
                        self.scrollView?.mj_insetT = top
                        // 设置滚动位置
                        var offset = self.scrollView?.contentOffset
                        offset?.y = -top
                        self.scrollView?.setContentOffset(offset ?? CGPoint.zero, animated: false)
                    }
                }) { finished in
                    self.executeRefreshingCallback()
                }
                
            }
            return
        }
        
        if scrollView?.panGestureRecognizer.state != .cancelled {
            
            let top: CGFloat = scrollViewOriginalInset?.top ?? 0 + mj_h
            // 禁用交互, 如果不禁用可能会引起渲染问题.
            scrollView?.isUserInteractionEnabled = false
            
            // CAAnimation keyPath不支持 contentOffset 用Bounds的动画代替
            let boundsAnimation = CABasicAnimation(keyPath: "bounds")
            var bounds = scrollView?.bounds ?? CGRect.zero
            bounds.origin.y = -top
            boundsAnimation.fromValue = NSValue(cgRect: scrollView?.bounds ?? CGRect.zero)
            boundsAnimation.toValue = NSValue(cgRect: bounds)
            boundsAnimation.duration = CFTimeInterval(MJRefreshFastAnimationDuration)
            //在delegate里移除
            boundsAnimation.isRemovedOnCompletion = false
            boundsAnimation.fillMode = .both
            boundsAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            boundsAnimation.delegate = self
            boundsAnimation.setValue(MJRefreshHeaderRefreshingBoundsKey, forKey: "identity")
            scrollView?.layer.add(boundsAnimation, forKey: MJRefreshHeaderRefreshingBoundsKey)
            
            
        } else {
            executeRefreshingCallback()
        }
    }
    
    
    // MARK: - subClass overwrite
    public func lastUpdatedTimeKeySetAction(_ lastUpdatedTimeKey: String){}
    
}

extension MJRefreshHeader: CAAnimationDelegate{
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let identity = anim.value(forKey: "identity") as? String
        if (identity == MJRefreshHeaderRefreshing2IdleBoundsKey) {
            pullingPercent = 0.0
            scrollView?.isUserInteractionEnabled = true
            if endRefreshingCompletionBlock != nil {
                endRefreshingCompletionBlock!()
            }
        } else if (identity == MJRefreshHeaderRefreshingBoundsKey) {
            // 避免出现 end 先于 Refreshing 状态
            if state != .idle {
                let top: CGFloat = scrollViewOriginalInset?.top ?? 0 + mj_h
                scrollView?.mj_insetT = top
                // 设置最终滚动位置
                var offset = scrollView?.contentOffset
                offset?.y = -top
                scrollView?.setContentOffset(offset ?? CGPoint.zero, animated: false)
            }
            scrollView?.isUserInteractionEnabled = true
            executeRefreshingCallback()
        }

    }
    
}
