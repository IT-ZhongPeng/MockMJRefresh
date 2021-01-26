//
//  ViewController.swift
//  MockMJRefresh
//
//  Created by zhaozp on 06/08/2020.
//  Copyright (c) 2020 zhaozp. All rights reserved.
//

import UIKit
import MockMJRefresh


class ViewController: UIViewController {
    
    var dataArr:[String] = [String]()
    
    var num: Int = 0
    
    @IBOutlet weak var mockMJRefreshTB: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.mockMJRefreshTB.mj_header = MJRefreshNormalHeader (refreshingBlock: {[weak self] in
//            guard let self = self else { return }
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                self.dataArr.removeAll()
//                self.testData()
//                self.mockMJRefreshTB.reloadData()
//                if self.dataArr.count >= 5 {
//                    self.mockMJRefreshTB.mj_footer?.resetNoMoreData()
//                }
//                self.mockMJRefreshTB.mj_header?.endRefreshing()
//            }
//
//        })
        
        self.mockMJRefreshTB.mj_header =  MJChiBaoZiHeader.refreshingBlock({[weak self] in

            guard let self = self else { return }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.dataArr.removeAll()
                self.testData()
                self.mockMJRefreshTB.reloadData()
                if self.dataArr.count >= 5 {
                    self.mockMJRefreshTB.mj_footer?.resetNoMoreData()
                }
                self.mockMJRefreshTB.mj_header?.endRefreshing()
            }

        })
//        self.mockMJRefreshTB.mj_footer?.ignoredScrollViewContentInsetBottom = 34.0
        
        self.mockMJRefreshTB.mj_header?.beginRefreshing()
        
        self.mockMJRefreshTB.mj_footer = MJRefreshBackNormalFooter (refreshingBlock: {[weak self] in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                for n in 1...8 {
                    self.num += n
                    self.dataArr.append("\(self.num)")
                }
                self.mockMJRefreshTB.reloadData()
                self.mockMJRefreshTB.mj_footer?.endRefreshing()
//                if self.dataArr.count > 20{
//                    self.mockMJRefreshTB.mj_footer?.endRefreshingWithNoMoreData()
//                }else{
//
//                }
                
            }
        })
        
    }
    
    
    func testData()  {
        
        for n in 1...8 {
            self.num += n
            dataArr.append("\(num)")
        }
    }
    
}

extension ViewController: UITableViewDataSource , UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell ()
        cell.textLabel?.text = "\(indexPath.row)" + "点击去OCController"
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async { [weak self] in
            let vc = secondViewController()
             vc.modalPresentationStyle = .overFullScreen
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
    
}


