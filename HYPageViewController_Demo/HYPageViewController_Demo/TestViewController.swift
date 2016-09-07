//
//  TestViewController.swift
//  HYPageViewController_Demo
//
//  Created by jsb06 on 16/9/7.
//  Copyright © 2016年 hy. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.frame = self.view.bounds
    }
    
    lazy var tableView: UITableView = {
         let tableView = UITableView(frame: CGRectZero, style: .Plain)
             tableView.backgroundColor = self.randomColor()
             tableView.delegate = self
             tableView.dataSource = self
             tableView.contentInset.top = 0.5
      return tableView
    }()

    func randomColor() -> UIColor {
        let r = CGFloat(arc4random_uniform(256))
        let g = CGFloat(arc4random_uniform(256))
        let b = CGFloat(arc4random_uniform(256))
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1)
    }
}

extension TestViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if  cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = "\(indexPath.row)  " + self.title!
        return cell!
    }
}
