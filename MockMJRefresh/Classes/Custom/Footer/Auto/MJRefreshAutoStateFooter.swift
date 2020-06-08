//
//  MJRefreshAutoStateFooter.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/5.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit

open class MJRefreshAutoStateFooter: MJRefreshAutoFooter{
    
    private var stateTitles: [String : String] = [String : String]()
    
    public var isRefreshingTitleHidden: Bool = false
    
    public lazy var stateLabel: UILabel = {
        let stateLabel  = UILabel.mj_label()
        stateLabel.isUserInteractionEnabled = true
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
    
    @objc private func stateLabelClick(){
        if self.state == .idle {
            self.beginRefreshing()
        }
    }
    
    open override func setUpUI() {
        super.setUpUI()
        self.addSubview(self.stateLabel)
    }
    
    open override func prepare() {
        super.prepare()
        
       // 初始化间距
        labelLeftInset = MJRefreshLabelLeftInset

        // 初始化文字
        setTitle(Bundle.mj_localizedString(forKey: MJRefreshAutoFooterIdleText), for: .idle)
        setTitle(Bundle.mj_localizedString(forKey: MJRefreshAutoFooterRefreshingText), for: .refreshing)
        setTitle(Bundle.mj_localizedString(forKey: MJRefreshAutoFooterNoMoreDataText), for: .noMoreData)

        // 监听label
        stateLabel.isUserInteractionEnabled = true
        stateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stateLabelClick)))
    }
    
    public override func placeSubviews() {
        super.placeSubviews()
        
        if self.stateLabel.constraints.count > 0 { return }
        
        self.stateLabel.frame = self.bounds
        
    }
    
    open override func stateSetAction(oldState: MJRefreshState, newState: MJRefreshState) {
        super.stateSetAction(oldState: oldState, newState: newState)
        
        if self.isRefreshingTitleHidden  && state == .refreshing{
            self.stateLabel.text = "";
        }else{
            self.stateLabel.text = self.stateTitles["\(newState)"];
        }
        
    }

    
}
