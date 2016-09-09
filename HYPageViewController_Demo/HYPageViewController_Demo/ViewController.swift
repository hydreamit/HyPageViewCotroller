//
//  ViewController.swift
//  HYPageViewController_Demo
//
//  Created by jsb06 on 16/9/7.
//  Copyright © 2016年 hy. All rights reserved.
//

import UIKit

class ViewController: HYPageViewController_ScrollView {
    
    private lazy var titleArr = ["新闻", "娱乐啪啪啪", "体育", "中国足球", "国际足球", "轻松一刻", "军事天地新闻", "十万个为什么"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAllChildController()
        
//        dispatch_after(dispatch_time(3, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
//            self.addAllChildController()
//            self.startIndex = 5
//            self.refreshPageView()
//        }
        
    }
    
    private func addAllChildController() {
        for titleStr in titleArr{
            let pageVc = TestViewController()
                pageVc.title = titleStr
            addChildViewController(pageVc)
        }
    }

}

