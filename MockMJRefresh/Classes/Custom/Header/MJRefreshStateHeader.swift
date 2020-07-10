//
//  MJRefreshStateHeader.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/5.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit


open class MJRefreshStateHeader: MJRefreshHeader{
    /// 利用这个block来决定显示的更新时间文字
    public var lastUpdatedTimeText: ((_ lastUpdatedTime: Date?) -> String)?
    
    /// 文字距离圈圈、箭头的距离
     public var labelLeftInset: CGFloat = 0.0
    
    /// 所有状态对应的文字
    private var stateTitles: [String : String] = [String : String]()
    
    // MARK: - 公共方法
   public func setTitle(_ title: String?, for state: MJRefreshState) {
        if title == nil {
            return
        }
        
        self.stateTitles["\(state)"] = title ?? ""
        stateLabel.text = stateTitles["\(String(describing: self.state))"]
    }
    
    
    public lazy var  stateLabel: UILabel = {
        let stateLabel = UILabel.mj_label()
        return stateLabel
    }()
    
    public lazy var lastUpdatedTimeLabel: UILabel = {
        let lastUpdatedTimeLabel = UILabel.mj_label()
        return lastUpdatedTimeLabel
    }()
    
    
    public override func lastUpdatedTimeKeySetAction(_ lastUpdatedTimeKey: String) {
        super.lastUpdatedTimeKeySetAction(lastUpdatedTimeKey)
        
        if self.lastUpdatedTimeLabel.isHidden {
            return
        }
        
        let lastUpdatedTime: Date? = UserDefaults.standard.object(forKey: lastUpdatedTimeKey) as? Date
        
        if self.lastUpdatedTimeText != nil {
            self.lastUpdatedTimeLabel.text = self.lastUpdatedTimeText!(lastUpdatedTime ?? Date())
            return
        }
        
        if lastUpdatedTime != nil {
            // 1.获得年月日
            let calendar = Calendar(identifier: .gregorian)
            let unitFlags: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
            let cmp1 = calendar.dateComponents(unitFlags, from: lastUpdatedTime ?? Date())
            let cmp2 = calendar.dateComponents(unitFlags, from: Date())

            // 2.格式化日期
            let formatter = DateFormatter()
            var isToday = false
            if cmp1.day == cmp2.day {
                // 今天
                formatter.dateFormat = " HH:mm"
                isToday = true
            } else if cmp1.year == cmp2.year {
                // 今年
                formatter.dateFormat = "MM-dd HH:mm"
            } else {
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
            }
            let time = formatter.string(from: lastUpdatedTime ?? Date())
            
            
            let temp_LastTime_Text: String =  Bundle.mj_localizedString(forKey: MJRefreshHeaderLastTimeText) ?? ""
            let temp_DateTody_Text = isToday ? Bundle.mj_localizedString(forKey: MJRefreshHeaderDateTodayText) ?? "" : ""
            lastUpdatedTimeLabel.text =   temp_LastTime_Text + temp_DateTody_Text + time


        }else{
            let temp_LastTime_Text: String =  Bundle.mj_localizedString(forKey: MJRefreshHeaderLastTimeText) ?? ""
            let temp_NoneLastDate_Text: String =  Bundle.mj_localizedString(forKey: MJRefreshHeaderNoneLastDateText) ?? ""
            lastUpdatedTimeLabel.text = temp_LastTime_Text +  temp_NoneLastDate_Text
        }
        
    }
    
    open override func setUpUI() {
        super.setUpUI()
        self.addSubview(self.stateLabel)
        self.addSubview(self.lastUpdatedTimeLabel)
    }
    
    open override func prepare() {
        super.prepare()
        
        // 初始化间距
        self.labelLeftInset = MJRefreshLabelLeftInset

        // 初始化文字
        setTitle(Bundle.mj_localizedString(forKey: MJRefreshHeaderIdleText), for: .idle)
        setTitle(Bundle.mj_localizedString(forKey: MJRefreshHeaderPullingText), for: .pulling)
        setTitle(Bundle.mj_localizedString(forKey: MJRefreshHeaderRefreshingText), for: .refreshing)

    }
    
    open override func placeSubviews() {
        super.placeSubviews()
        
        if self.stateLabel.isHidden {
            return
        }
        
        let noConstrainsOnStatusLabel = stateLabel.constraints.count == 0
        
        if lastUpdatedTimeLabel.isHidden {
            // 状态
            if noConstrainsOnStatusLabel {
                stateLabel.frame = bounds
            }
        } else {
            let stateLabelH: CGFloat = mj_h * 0.5
            // 状态
            if noConstrainsOnStatusLabel {
                stateLabel.mj_x = 0
                stateLabel.mj_y = 0
                stateLabel.mj_w = mj_w
                stateLabel.mj_h = stateLabelH
            }

            // 更新时间
            if lastUpdatedTimeLabel.constraints.count == 0 {
                lastUpdatedTimeLabel.mj_x = 0
                lastUpdatedTimeLabel.mj_y = stateLabelH
                lastUpdatedTimeLabel.mj_w = mj_w
                lastUpdatedTimeLabel.mj_h = mj_h - lastUpdatedTimeLabel.mj_y
            }
        }
    }
    
    
    open override func stateSetAction(oldState: MJRefreshState, newState: MJRefreshState) {
        super.stateSetAction(oldState: oldState, newState: newState)
        
        // 设置状态文字
        self.stateLabel.text = self.stateTitles["\(newState)"];
        
        // 重新设置key（重新显示时间）
        self.lastUpdatedTimeKey = self.lastUpdatedTimeKey;
        
    }
    
}
