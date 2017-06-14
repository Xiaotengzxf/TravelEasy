//
//  TableViewHeadSectionCell.swift
//  CityListDemo
//
//  Created by ray on 15/12/1.
//  Copyright © 2015年 ray. All rights reserved.
//

import UIKit

class TableViewHeadSectionCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var delegate:CityViewControllerDelegate?
    //回调函数
    var action = {(city:[String : AnyObject]) -> Void in
       
    }

    @IBOutlet weak var collectionView: UICollectionView!
    private var data : [[String : AnyObject]] = []
    
    func addData(data:[[String : AnyObject]],city:(city:[String : AnyObject])->Void){
        self.data = data
        self.action = city
    }
    
    func reloadData(){
        let nib = UINib(nibName: "CollectionViewCell", bundle: NSBundle.mainBundle())
        collectionView.registerNib(nib, forCellWithReuseIdentifier: "cell")
        self.collectionView.reloadData()
    }
    
     ////////////////////  UICollectionViewDataSource   ////////////////////
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return data.count;
    }
    
   
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCell
        cell.addData(self.data[indexPath.row])
        cell.layer.cornerRadius = 3
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.hexStringToColor("e0e1e2").CGColor
        return cell;
    }
    
    ////////////////////  UICollectionViewDelegateFlowLayout   ////////////////////
    
    /** 每一个cell的大小 **/
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let width = UIScreen.mainScreen().bounds.size.width
        let itemWidth = (width - 68) / 3
        let itemHeight = itemWidth * 50 / 168
        return CGSizeMake(itemWidth , itemHeight)
    }
    
    /** 设置每组的cell的边界 **/
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(15, 15, 15, 15)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
     ////////////////////  UICollectionViewDelegate   ////////////////////
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.hexStringToColor("e0e1e2")
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.whiteColor()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let city : [String : AnyObject] = data[indexPath.row]
        self.action(city)

    }

    
}
