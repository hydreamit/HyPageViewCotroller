//
//  HYPageViewController.swift
//  HYPageViewController_Demo
//
//  Created by jsb06 on 16/9/7.
//  Copyright © 2016年 hy. All rights reserved.
//


/*
 ScrollView没有循环利用， 应用于少量的pageView
 */


import UIKit

class HYPageViewController_ScrollView: UIViewController {
    
    let ScreenW = UIScreen.mainScreen().bounds.width
    let ScreenH = UIScreen.mainScreen().bounds.height
    let scale: CGFloat = 1.25
    let titleScrollViewH: CGFloat = 44
    var titleBtnMargin: CGFloat = 25
    let titleBottomLineH: CGFloat = 2
    var animaTime = 0.25
    var startIndex = 0
    
    private var refreshingPageView = true
    private var isInitialized = false
    var lastOffSetX: CGFloat = 0
    var isClickBtn = false
    
    private lazy var titleBtns = [UIButton]()
    var selectedBtn = UIButton()
   
    private lazy var titleScrollView: UIScrollView = {
        let titleScrollView: UIScrollView = UIScrollView()
            titleScrollView.showsHorizontalScrollIndicator = false
     return titleScrollView;
    }()
    private lazy var contentScrollView: UIScrollView = {
        let contentScrollView: UIScrollView = UIScrollView()
            contentScrollView.opaque = true
            contentScrollView.pagingEnabled = true
            contentScrollView.bounces = false
            contentScrollView.showsHorizontalScrollIndicator = false
            contentScrollView.delegate = self
     return contentScrollView;
    }()
    private lazy var titleBottomLine: UIView = {
        let titleBottomLine: UIView = UIView()
            titleBottomLine.backgroundColor = UIColor.redColor()
     return titleBottomLine
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initConfig()
    }
    override func viewWillAppear(animated: Bool) {
        if !isInitialized {
           setUpAllTitle()
           isInitialized = true
           refreshingPageView = false
        }
    }
    
    func refreshPageView(){
        for view in titleScrollView.subviews {
            view.removeFromSuperview()
        }
        titleBtns.removeAll()
        refreshingPageView = true
        setUpAllTitle()
        refreshingPageView = false
    }
}


extension HYPageViewController_ScrollView {
    private func initConfig() {
        automaticallyAdjustsScrollViewInsets = false
        view.addSubview(titleScrollView)
        view.addSubview(contentScrollView)
        titleScrollView.frame = CGRect(x: 0, y: 64, width: view.bounds.size.width, height: titleScrollViewH)
        contentScrollView.frame = CGRect(x: 0, y: CGRectGetMaxY(titleScrollView.frame), width: view.bounds.size.width, height: view.bounds.size.height - CGRectGetMaxY(titleScrollView.frame))
    }
    
  
    
    private func setUpAllTitle() {
        let childCount = childViewControllers.count
        let titleBtnH = titleScrollView.frame.size.height
        var btnX: CGFloat = titleBtnMargin
    
        for i in 0..<childCount {
            let btn = UIButton()
                btn.addTarget(self, action: #selector(HYPageViewController_ScrollView.clickBtn(_:)), forControlEvents: .TouchUpInside)
                btn.setTitle(childViewControllers[i].title, forState: .Normal)
                btn.titleLabel?.font = UIFont.systemFontOfSize(15)
                btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
                btn.tag = i
            titleBtns.append(btn)
            titleScrollView.addSubview(btn)
            
            btn.frame.origin.x = btnX
            btn.frame.origin.y = 0
            btn.sizeToFit()
            btn.frame.size.height = titleBtnH
            btnX += (btn.frame.size.width + titleBtnMargin)
        }
        
        if childCount > 0 && btnX < ScreenW {
            titleBtnMargin += (ScreenW - btnX) / CGFloat(childCount + 1)
            btnX = titleBtnMargin
            for btn in titleBtns {
                btn.frame.origin.x = btnX
                btnX += (btn.frame.size.width + titleBtnMargin)
            }
        }
        
        titleScrollView.contentSize = CGSize(width:btnX  , height: 0)
        contentScrollView.contentSize = CGSize(width: ScreenW * CGFloat(childCount), height: 0)
       
        
        if childCount > 0 {
            let startSelIndex = startIndex < childCount ? startIndex : 0
            clickBtn(titleBtns[startSelIndex])
            setUpTitleBottomLine(titleBtns[startSelIndex])
            titleScrollView.addSubview(titleBottomLine)
        }
    }
    
    private func setUpTitleBottomLine(btn: UIButton){
        titleBottomLine.frame.size.height = titleBottomLineH
        titleBottomLine.frame.size.width = btn.frame.size.width + 10
        titleBottomLine.center.x = btn.center.x
        titleBottomLine.frame.origin.y = titleScrollViewH - titleBottomLineH
    }
    
    @objc private func clickBtn(btn: UIButton) {
        isClickBtn = true
        setUpSelBtn(btn)
        addChildView(btn.tag)
        UIView.animateWithDuration(refreshingPageView ? 0 : animaTime) {
            self.contentScrollView.contentOffset = CGPoint(x: self.view.bounds.width * CGFloat(btn.tag), y: 0)
        }
    }
    
    private func setUpSelBtn(btn: UIButton) {
        
        UIView.animateWithDuration(refreshingPageView ? 0 : animaTime) {
            self.selectedBtn.transform = CGAffineTransformIdentity
            self.selectedBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            
            btn.transform = CGAffineTransformMakeScale(self.scale, self.scale)
            btn.setTitleColor(UIColor.redColor(), forState: .Normal)
            
            self.titleBottomLine.frame.size.width = btn.frame.size.width + 10
            self.titleBottomLine.center.x = btn.center.x
        }

        setSelBtnToCenter(btn)
        
        selectedBtn = btn
    }
    
    private func setSelBtnToCenter(btn: UIButton){
        
        if titleScrollView.contentSize.width <= ScreenW {
            return
        }
        
        var offSetX = btn.center.x - view.bounds.size.width * 0.5
        if offSetX < 0 {
            offSetX = 0
        }
        let maxOffSetX = titleScrollView.contentSize.width - view.bounds.size.width
        if offSetX > maxOffSetX {
            offSetX = maxOffSetX
        }
        UIView.animateWithDuration(refreshingPageView ? 0 : animaTime) {
          self.titleScrollView.contentOffset = CGPoint(x: offSetX, y: 0)
        }
    }
    
    private func addChildView(index: Int) {
        let vc = childViewControllers[index]
        if  vc.view.superview != nil {
            return
        }
        vc.view.frame = CGRect(x: CGFloat(index) * view.bounds.size.width, y: 0, width: view.bounds.size.width, height: contentScrollView.bounds.size.height)
        contentScrollView.addSubview(vc.view)
    }
}


extension HYPageViewController_ScrollView: UIScrollViewDelegate{
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let offSetX = scrollView.contentOffset.x
        let offsetDelta = offSetX - lastOffSetX
        lastOffSetX = offSetX
        
        if isClickBtn {
            isClickBtn = false
            return
        }
        
        let index = Int(offSetX / view.bounds.size.width)
        let leftBtn = titleBtns[index]
        var rightBtn: UIButton?
        if index + 1 < titleBtns.count {
            rightBtn = titleBtns[index + 1]
        }
        
        let scaleRight = (scrollView.contentOffset.x / view.bounds.size.width) - CGFloat(index)
        let scaleLeft = 1 - scaleRight
        let currentScale = scale - 1
        
        leftBtn.transform = CGAffineTransformMakeScale(scaleLeft * currentScale + 1, scaleLeft * currentScale + 1)
        if let rBtn = rightBtn {
            rBtn.transform = CGAffineTransformMakeScale(scaleRight * currentScale + 1, scaleRight * currentScale + 1)
        }

        let leftColor = UIColor(colorLiteralRed: Float(scaleLeft), green: 0, blue: 0, alpha: 1)
        let rightColor = UIColor(colorLiteralRed: Float(scaleRight), green: 0, blue: 0, alpha: 1)
        leftBtn.setTitleColor(leftColor, forState: .Normal)
        rightBtn?.setTitleColor(rightColor, forState: .Normal)
        
        var offx: CGFloat = 0
        var offW: CGFloat = 0
        if let rBtn = rightBtn {
            offx = rBtn.frame.origin.x - leftBtn.frame.origin.x
            offW = rBtn.frame.size.width - leftBtn.frame.size.width
        }
        titleBottomLine.frame.size.width += (offW * offsetDelta / ScreenW)
        titleBottomLine.center.x +=  (offx * offsetDelta / ScreenW)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / view.bounds.size.width
        setUpSelBtn(titleBtns[Int(index)])
        addChildView(Int(index))
    }
}



