//
//  NSBundle+MJRefresh.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/4.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit



extension Bundle{
    
    static var refreshBundle: Bundle? = nil
    
    class func mj_refreshBundle() -> Bundle{
        if refreshBundle == nil {
            // 这里不使用mainBundle是为了适配pod 1.x和0.x
            refreshBundle = Bundle (path: Bundle(for: MJRefreshComponent.self).path(forResource: "MJRefresh", ofType: "bundle") ?? "")
        }
        return refreshBundle ?? Bundle.main
    }
    
    
     static var arrowImage: UIImage? = nil

    class func mj_arrowImage() -> UIImage? {
        if arrowImage == nil {
            arrowImage = (UIImage(contentsOfFile: self.mj_refreshBundle().path(forResource: "MJRefreshArrow@2x", ofType: "png") ?? ""))?.withRenderingMode(.alwaysTemplate)
        }
        return arrowImage
    }
    
    
    class func mj_localizedString(forKey key: String?) -> String? {
        return self.mj_localizedString(forKey: key, value: nil)
    }

    
    static var mj_localizedStringBundle: Bundle? = nil

    class func mj_localizedString(forKey key: String?, value: String?) -> String? {
        var value = value
        if mj_localizedStringBundle == nil {
            var language = MJRefreshConfig.defaultConfig.languageCode
            // 如果配置中没有配置语言
            if language == nil {
                // （iOS获取的语言字符串比较不稳定）目前框架只处理en、zh-Hans、zh-Hant三种情况，其他按照系统默认处理
                language = NSLocale.preferredLanguages.first
            }

            if language?.hasPrefix("en") ?? false {
                language = "en"
            } else if language?.hasPrefix("zh") ?? false {
                if (language as NSString?)?.range(of: "Hans").location != NSNotFound {
                    language = "zh-Hans" // 简体中文
                } else {
                    // zh-Hant\zh-HK\zh-TW
                    language = "zh-Hant" // 繁體中文
                }
            } else if language?.hasPrefix("ko") ?? false {
                language = "ko"
            } else if language?.hasPrefix("ru") ?? false {
                language = "ru"
            } else if language?.hasPrefix("uk") ?? false {
                language = "uk"
            } else {
                language = "en"
            }

            // 从MJRefresh.bundle中查找资源
            mj_localizedStringBundle = Bundle(path: Bundle.mj_refreshBundle().path(forResource: language, ofType: "lproj") ?? "")
        }
        value = mj_localizedStringBundle?.localizedString(forKey: key ?? "", value: value, table: nil)
        return Bundle.main.localizedString(forKey: key ?? "", value: value, table: nil)
    }


    
    
}
