//
//  HYPageViewController_CollectionView.swift
//  HYPageViewController_Demo
//
//  Created by jsb06 on 16/9/7.
//  Copyright © 2016年 hy. All rights reserved.
//


/*
 CollectionView循环利用， 可应用于大量的pageView
 */


import UIKit

class HYPageViewController_CollectionView: UIViewController {
    
    let ScreenW = UIScreen.mainScreen().bounds.width
    let ScreenH = UIScreen.mainScreen().bounds.height
    let scale: CGFloat = 1.25
    let titleScrollViewH: CGFloat = 44
    let titleBtnMargin: CGFloat = 25
    let titleBottomLineH: CGFloat = 2
    var lastOffSetX: CGFloat = 0
    
    private lazy var titleBtns = [UIButton]()
    var selectedBtn = UIButton()
    var isInitialized = false
    
    private lazy var collectionView: UICollectionView = {
        let collectionView: UICollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: MainLayout())
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.pagingEnabled = true
            collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    private lazy var titleScrollView: UIScrollView = {
        let titleScrollView: UIScrollView = UIScrollView()
        titleScrollView.showsHorizontalScrollIndicator = false
        return titleScrollView;
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
        }
    }
}

class MainLayout: UICollectionViewFlowLayout {
    override func prepareLayout() {
        super.prepareLayout()
        itemSize = (collectionView?.bounds.size)!
        scrollDirection = .Horizontal
        minimumLineSpacing = 0
    }
}

extension HYPageViewController_CollectionView {
    private func initConfig() {
        automaticallyAdjustsScrollViewInsets = false
        view.addSubview(titleScrollView)
        view.addSubview(collectionView)
        
        titleScrollView.frame = CGRect(x: 0, y: 64, width: view.bounds.size.width, height: titleScrollViewH)
        collectionView.frame = CGRect(x: 0, y: CGRectGetMaxY(titleScrollView.frame), width: view.bounds.size.width, height: view.bounds.size.height - CGRectGetMaxY(titleScrollView.frame))
        
    }
    
    private func setUpAllTitle() {
        let childCount = childViewControllers.count
        let titleBtnH = titleScrollView.frame.size.height
        var btnX: CGFloat = titleBtnMargin
        for i in 0..<childCount {
            let btn = UIButton()
            btn.addTarget(self, action: #selector(HYPageViewController_CollectionView.clickBtn(_:)), forControlEvents: .TouchUpInside)
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
            
            if i == 0 {
                clickBtn(btn)
            }
        }
        
        if childCount > 0 {
            setUpTitleBottomLine(titleBtns.first!)
            titleScrollView.addSubview(titleBottomLine)
        }
        
        titleScrollView.contentSize = CGSize(width:btnX  , height: 0)
        collectionView.contentSize = CGSize(width: ScreenW * CGFloat(childCount), height: 0)
    }
    
    private func setUpTitleBottomLine(btn: UIButton){
        titleBottomLine.frame.size.height = titleBottomLineH
        titleBottomLine.frame.size.width = btn.frame.size.width + 10
        titleBottomLine.center.x = btn.center.x
        titleBottomLine.frame.origin.y = titleScrollViewH - titleBottomLineH
    }
    
    @objc private func clickBtn(btn: UIButton) {
        setUpSelBtn(btn)
        UIView.animateWithDuration(0.25) {
            self.titleBottomLine.frame.size.width = btn.frame.size.width + 10
            self.titleBottomLine.center.x = btn.center.x
        }
        collectionView.contentOffset = CGPoint(x: view.bounds.width * CGFloat(btn.tag), y: 0)
    }
    
    private func setUpSelBtn(btn: UIButton) {
        
        selectedBtn.transform = CGAffineTransformIdentity
        selectedBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        setSelBtnToCenter(btn)
        
        btn.transform = CGAffineTransformMakeScale(scale, scale)
        btn.setTitleColor(UIColor.redColor(), forState: .Normal)
        
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
        titleScrollView.setContentOffset(CGPoint(x: offSetX, y: 0), animated: true)
    }
    
}

extension HYPageViewController_CollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childViewControllers.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        let vc = childViewControllers[indexPath.row]
        vc.view.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        cell.contentView.addSubview(vc.view)
        return cell
        
    }
}


extension HYPageViewController_CollectionView: UIScrollViewDelegate{
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let offSetX = scrollView.contentOffset.x
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
        lastOffSetX = offSetX
        
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / view.bounds.size.width
        setUpSelBtn(titleBtns[Int(index)])
        UIView.animateWithDuration(0.25) {
            self.titleBottomLine.frame.size.width = self.titleBtns[Int(index)].frame.size.width + 10
            self.titleBottomLine.center.x = self.titleBtns[Int(index)].center.x
        }
    }
}



