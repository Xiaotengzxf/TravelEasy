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
    fileprivate var data : [[String : AnyObject]] = []
    
    func addData(_ data:[[String : AnyObject]],city:@escaping (_ city:[String : AnyObject])->Void){
        self.data = data
        self.action = city
    }
    
    func reloadData(){
        let nib = UINib(nibName: "CollectionViewCell", bundle: Bundle.main)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        self.collectionView.reloadData()
    }
    
     ////////////////////  UICollectionViewDataSource   ////////////////////
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return data.count;
    }
    
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.addData(self.data[indexPath.row])
        cell.layer.cornerRadius = 3
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.hexStringToColor("e0e1e2").cgColor
        return cell;
    }
    
    ////////////////////  UICollectionViewDelegateFlowLayout   ////////////////////
    
    /** 每一个cell的大小 **/
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = UIScreen.main.bounds.size.width
        let itemWidth = (width - 68) / 3
        let itemHeight = itemWidth * 50 / 168
        return CGSize(width: itemWidth , height: itemHeight)
    }
    
    /** 设置每组的cell的边界 **/
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(15, 15, 15, 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
     ////////////////////  UICollectionViewDelegate   ////////////////////
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.hexStringToColor("e0e1e2")
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.white
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let city : [String : AnyObject] = data[indexPath.row]
        self.action(city)

    }

    
}
