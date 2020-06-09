//
//  MJRefreshBackStateFooter.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/5.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit

public class MJRefreshBackStateFooter: MJRefreshBackFooter{
    
    public var stateTitles: [String:String] = [String:String]()
    
    public lazy var stateLabel: UILabel = {
        let stateLabel = UILabel.mj_label()
        return stateLabel
    }()
    
    
    // MARK: - 公共方法
    func setTitle(_ title: String?, for state: MJRefreshState) {
        if title == nil {
            return
        }
        stateTitles["\(state)"] = title ?? ""
        stateLabel.text = stateTitles["\(self.state ?? MJRefreshState.idle )"]
    }

    func title(for state: MJRefreshState) -> String{
        return stateTitles["\(state)"] ?? ""
    }

    public override func setUpUI() {
        super.setUpUI()
        self.addSubview(self.stateLabel)
    }
    public override func prepare() {
        super.prepare()
         // 初始化间距
        self.labelLeftInset = MJRefreshLabelLeftInset

        // 初始化文字
        setTitle(Bundle.mj_localizedString(forKey: MJRefreshBackFooterIdleText), for: .idle)
        setTitle(Bundle.mj_localizedString(forKey: MJRefreshBackFooterPullingText), for: .pulling)
        setTitle(Bundle.mj_localizedString(forKey: MJRefreshBackFooterRefreshingText), for: .refreshing)
        setTitle(Bundle.mj_localizedString(forKey: MJRefreshBackFooterNoMoreDataText), for: .noMoreData)
    }
    
    public override func placeSubviews() {
        super.placeSubviews()
        if stateLabel.constraints.count > 0 {
            return
        }

        // 状态标签
        self.stateLabel.frame = self.bounds
    }
    
    public override func stateSetAction(oldState: MJRefreshState, newState: MJRefreshState) {
        super.stateSetAction(oldState: oldState, newState: newState)
        // 设置状态文字
        self.stateLabel.text = self.stateTitles["\(newState)"]
    }
}
