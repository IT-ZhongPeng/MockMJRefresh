//
//  MJRefreshFooter.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/5.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit

open class MJRefreshFooter: MJRefreshComponent{
    /// 忽略多少scrollView的contentInset的bottom
    public var ignoredScrollViewContentInsetBottom: CGFloat = 0.0
    
    /// 文字距离圈圈、箭头的距离
    public var labelLeftInset: CGFloat = 0.0
    
    
    // MARK: - 重写父类的方法
    
    open override func prepare() {
        super.prepare()
        self.backgroundColor = UIColor.clear
        // 设置自己的高度
        self.mj_h = MJRefreshFooterHeight
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc open class func footer(withRefreshingBlock refreshBlock: @escaping MJRefreshComponentAction) -> Self{
        let cmd = self.init()
        cmd.refreshingBlock = refreshBlock
        return cmd
    }
    
    
    // MARK: - 公共方法
    @objc public func endRefreshingWithNoMoreData() {
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else { return }
            self.state = .noMoreData
        }
    }
    
    
    @objc public func resetNoMoreData(){
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else { return }
            self.state = .idle
        }
    }
 
    
}
