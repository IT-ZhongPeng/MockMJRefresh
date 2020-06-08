//
//  MJRefreshComponent.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/4.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit

/// 状态枚举
///
/// - idle:         闲置
/// - pulling:      可以进行刷新
/// - refreshing:   正在刷新
/// - willRefresh:  即将刷新
/// - noMoreData:   没有更多数据
public enum MJRefreshState {
    case idle            // 普通闲置状态
    case pulling         // 松开就可以进行刷新的状态
    case refreshing      // 正在刷新中的状态
    case willRefresh    // 即将刷新的状态
    case noMoreData     // 所有数据加载完毕，没有更多的数据了
}

public typealias MJRefreshComponentAction =  () -> Void

open class MJRefreshComponent: UIView{
    
    #warning("用代理实现吧 ！！！")
    /// 回调对象
    public var refreshingTarget: Any?
    /// 回调方法
    public var refreshingAction: Selector?
    
    
    /// 父控件
    private(set) weak var scrollView: UIScrollView?
    
    private var pan: UIPanGestureRecognizer?
    
    /** 记录scrollView刚开始的inset */
    public var  scrollViewOriginalInset: UIEdgeInsets?
    /** 父控件 */
    weak public var _scrollView: UIScrollView?
    
    
    /// 拉拽的百分比(交给子类重写)
    public var pullingPercent: CGFloat = 0.0{
        didSet{
            self.pullingPercentSetAction()
        }
    }
    
    /// 开始刷新后的回调(进入刷新状态后的回调)
    public var beginRefreshingCompletionBlock: MJRefreshComponentAction?
    
    /// 结束刷新的回调
    public var endRefreshingCompletionBlock: MJRefreshComponentAction?
    /// 正在刷新的回调
    var refreshingBlock: MJRefreshComponentAction?
    /** 带动画的结束刷新的回调 */
    public  var endRefreshingAnimationBeginAction: MJRefreshComponentAction?
    
    /// 刷新状态 一般交给子类内部实现
    public var state: MJRefreshState?{
        
        didSet{
            DispatchQueue.main.async { [weak self] in
                self?.stateSetAction(oldState: oldValue ?? .idle, newState: self?.state ?? .idle)
            }
        }
        
    }
    
    public var isAutomaticallyChangeAlpha: Bool?
    
    
    var isAutoChangeAlpha: Bool{
        return self.isAutomaticallyChangeAlpha ?? false
    }
    
    
    var autoChangeAlpha: Bool?{
        didSet{
            self.automaticallyChangeAlpha = autoChangeAlpha ?? false
        }
    }
    
    
    public  var automaticallyChangeAlpha: Bool?{
        didSet{
            if self.isRefreshing() { return }
            
            if (automaticallyChangeAlpha ?? false) {
                self.alpha = self.pullingPercent
            } else {
                self.alpha = 1.0
            }
            
        }
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepare()
        self.setUpUI()
        self.state = .idle
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience public init (refreshingBlock refreshBlock: @escaping MJRefreshComponentAction){
        self.init()
        self.refreshingBlock = refreshBlock
    }
    
    
    open func  prepare(){
        // 基本属性
        autoresizingMask = .flexibleWidth
        backgroundColor = UIColor.clear
    }
    
    
    open func setUpUI() {}
    
    open func pullingPercentSetAction(){}
    
    
    open override func layoutSubviews() {
        placeSubviews()
        super.layoutSubviews()
    }
    
    public func placeSubviews() { }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        // 如果不是UIScrollView，不做任何事情
        if newSuperview != nil && !(newSuperview is UIScrollView) {
            return
        }
        
        // 旧的父控件移除监听
        removeObservers()
        
        if newSuperview != nil {
            // 新的父控件
            // 记录UIScrollView
            scrollView = newSuperview as? UIScrollView
            
            // 设置宽度
            mj_w = scrollView?.mj_w ?? 0
            // 设置位置
            mj_x = -(scrollView?.mj_insetL ?? 0)
            
            // 设置永远支持垂直弹簧效果
            scrollView?.alwaysBounceVertical = true
            // 记录UIScrollView最开始的contentInset
            self.scrollViewOriginalInset = scrollView?.mj_inset
            
            // 添加监听
            addObservers()
        }
    }
    
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if state == .willRefresh {
            // 预防view还没显示出来就调用了beginRefreshing
            state = .refreshing
        }
    }
    
    // MARK: - KVO监听
    func addObservers() {
        let options: NSKeyValueObservingOptions = [.new, .old]
        scrollView?.addObserver(self, forKeyPath: MJRefreshKeyPathContentOffset, options: options, context: nil)
        scrollView?.addObserver(self, forKeyPath: MJRefreshKeyPathContentSize, options: options, context: nil)
        pan = scrollView?.panGestureRecognizer
        pan?.addObserver(self, forKeyPath: MJRefreshKeyPathPanState, options: options, context: nil)
    }
    
    func removeObservers() {
        superview?.removeObserver(self, forKeyPath: MJRefreshKeyPathContentOffset)
        superview?.removeObserver(self, forKeyPath: MJRefreshKeyPathContentSize)
        pan?.removeObserver(self, forKeyPath: MJRefreshKeyPathPanState)
        pan = nil
    }
    
    
    open func stateSetAction(oldState: MJRefreshState, newState: MJRefreshState) {
        self.setNeedsLayout()
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // 遇到这些情况就直接返回
        if !isUserInteractionEnabled {
            return
        }
        
        // 这个就算看不见也需要处理
        if (keyPath == MJRefreshKeyPathContentSize) {
            scrollViewContentSizeDidChange(change)
        }
        
        // 看不见
        if isHidden {
            return
        }
        if (keyPath == MJRefreshKeyPathContentOffset) {
            scrollViewContentOffsetDidChange(change)
        } else if (keyPath == MJRefreshKeyPathPanState) {
            scrollViewPanStateDidChange(change)
        }
    }
    
    
    func scrollViewContentOffsetDidChange(_ change: [AnyHashable : Any]?) { }
    
    func scrollViewContentSizeDidChange(_ change: [AnyHashable : Any]?) {}
    
    func scrollViewPanStateDidChange(_ change: [AnyHashable : Any]?) {}
    
    
    // MARK: - 公共方法
    // MARK: 设置回调对象和回调方法
    #warning("用代理实现吧 ！！！")
    func setRefreshingTarget(_ target: Any?, refreshingAction action: Selector) {
        refreshingTarget = target
        refreshingAction = action
    }
    
    
    // MARK: 进入刷新状态
    public func beginRefreshing() {
        UIView.animate(withDuration: TimeInterval(MJRefreshFastAnimationDuration), animations: {
            self.alpha = 1.0
        })
        pullingPercent = 1.0
        // 只要正在刷新，就完全显示
        if (window != nil) {
            self.state = .refreshing
        } else {
            // 预防正在刷新中时，调用本方法使得header inset回置失败
            if state != .refreshing {
                self.state = .willRefresh
                // 刷新(预防从另一个控制器回到这个控制器的情况，回来要重新刷新一下)
                setNeedsDisplay()
            }
        }
    }
    
    
    public  func beginRefreshing(withCompletionBlock completionBlock: @escaping () -> Void) {
        beginRefreshingCompletionBlock = completionBlock
        
        beginRefreshing()
    }
    
    // MARK: 结束刷新状态
    public func endRefreshing() {
        DispatchQueue.main.async { [weak self] in
            self?.state = .idle
        }
    }
    
    public func endRefreshing(withCompletionBlock completionBlock: @escaping () -> Void) {
        endRefreshingCompletionBlock = completionBlock
        
        endRefreshing()
    }
    
    // MARK: 是否正在刷新
    public func isRefreshing() -> Bool {
        return state == .refreshing || state == .willRefresh
    }
    
    // MARK: 根据拖拽进度设置透明度
    public func setPullingPercent(_ pullingPercent: CGFloat) {
        self.pullingPercent = pullingPercent
        
        if isRefreshing() {
            return
        }
        
        if isAutomaticallyChangeAlpha ?? false {
            alpha = pullingPercent
        }
    }
    
    // MARK: - 内部方法
    func executeRefreshingCallback() {
        
        DispatchQueue.main.async {
            if self.refreshingBlock != nil{
                self.refreshingBlock!()
            }
            
            if self.beginRefreshingCompletionBlock != nil{
                self.beginRefreshingCompletionBlock!()
            }
        }
        
        
    }
    
}
