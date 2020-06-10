//
//  MJChiBaoZiHeader.swift
//  MockMJRefresh
//
//  Created by nmxy on 2020/6/5.
//  Copyright © 2020 nmxy. All rights reserved.
//

import Foundation
import UIKit

class MJChiBaoZiHeader: MJRefreshGifHeader{
    
    open override func prepare() {
        super.prepare()
        // 设置普通状态的动画图片
        var idleImages: [UIImage] = [UIImage]()
        for i in 1...60 {
            let image = UIImage(named: String(format: "dropdown_anim__000%zd", i))
            if let image = image {
                idleImages.append(image)
            }
        }
        setImages(idleImages, for: MJRefreshState.idle)

        // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
        var refreshingImages: [UIImage] = [UIImage]()
        for i in 1...3 {
            let image = UIImage(named: String(format: "dropdown_loading_0%zd", i))
            if let image = image {
                refreshingImages.append(image)
            }
        }
        setImages(refreshingImages, for: MJRefreshState.pulling)

        // 设置正在刷新状态的动画图片
        setImages(refreshingImages, for: MJRefreshState.refreshing)



    }
    
}
