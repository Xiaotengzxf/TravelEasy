//
//  CityViewController.swift
//  CityListDemo
//
//  Created by ray on 15/11/24.
//  Copyright © 2015年 ray. All rights reserved.
//

import UIKit
import JLToast
import MBProgressHUD

var citys : [String : [[String : AnyObject]]] = [:]
var cityHeader : [String] = []
var hotCitys : [[String : AnyObject]] = []

protocol CityViewControllerDelegate{
    func selectCity(bStart : Bool  , city:[String : AnyObject])
}

class CityViewController: UIViewController,UISearchBarDelegate,UISearchResultsUpdating,UITableViewDelegate,UITableViewDataSource  {
    
    var searchController: UISearchController!
    @IBOutlet weak var tableview: UITableView!
    
    /** 回调接口*/
    var delegate:CityViewControllerDelegate?
    var searchCityArray : [[String : AnyObject]] = []
    var bStart : Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "选择城市";
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        var frame = searchController.searchBar.frame
        frame.size.height = 44
        searchController.searchBar.frame = frame
        tableview.tableHeaderView = searchController.searchBar
        if cityHeader.count == 0 {
            getCityData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        searchController.searchBar.hidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.searchBar.hidden = true
        searchController.active = false
    }
    
    deinit {
        searchController = nil
    }
  
    /**
      装在城市数据信息
    */
    private func getCityData(){
        if let info = NSUserDefaults.standardUserDefaults().objectForKey("info") as? [String : AnyObject] {
            if let token = info["Token"] as? String {
                let hud = showHUD()
                let manager = URLCollection()
                manager.getRequest(manager.getFlightLocations, params: nil, headers: ["Token" : token]) { [weak self] (json, error) in
                    hud.hideAnimated(true)
                    if let jsonObject = json {
                        if jsonObject["Code"].int == 0 {
                            cityHeader += ["热门城市"]
                            if let hots = jsonObject["Hot"].object as? [[String : AnyObject]] {
                                for hot in hots {
                                    if let bvalue = hot["IsCity"] as? Bool where bvalue {
                                        hotCitys.append(hot)
                                    }
                                }
                            }
                            if var alls = jsonObject["All"].object  as? [[String : AnyObject]] {
                                alls.sortInPlace({ (dict1, dict2) -> Bool in
                                    let pinyin = dict1["Pinyin"] as! String
                                    let pinyin2 = dict2["Pinyin"] as! String
                                    return pinyin < pinyin2
                                })
                                let array : [String] = alls.map({
                                    let pinyin = $0["Pinyin"] as! String
                                    return pinyin.substringToIndex(pinyin.startIndex.advancedBy(1))
                                })
                                var keys = Array(Set(array))
                                keys.sortInPlace(<)
                                cityHeader += keys
                                for key in keys {
                                    var array : [[String : AnyObject]] = []
                                    for all in alls {
                                        let pinyin = all["Pinyin"] as! String
                                        if key == pinyin.substringToIndex(pinyin.startIndex.advancedBy(1)) {
                                            if let bvalue = all["IsCity"] as? Bool where bvalue {
                                                array.append(all)
                                            }
                                        }
                                    }
                                    citys[key] = array
                                }
                            }
                            self?.tableview.reloadData()
                        }else{
                            if let message = jsonObject["Message"].string {
                                JLToast.makeText(message).show()
                            }
                        }
                    }else{
                        JLToast.makeText("网络不给力，请检查网络!").show()
                    }
                }
            }
        }
    }
    
    /**
     将选中城市名称返回并关闭当前页面
    - parameter city: 城市名称
    */
    func selectCity(city:[String : AnyObject]) {
        self.delegate?.selectCity(bStart , city : city)
        self.navigationController?.popViewControllerAnimated(true)
        
    }

   //////////////////// UITableViewDataSource  ////////////////////
    
    func tableView(table: UITableView, numberOfRowsInSection section: Int) -> Int{

        if searchController.active {
            return self.searchCityArray.count
        }else{
            if section == 0 {
                return 1
            }else{
                return citys[cityHeader[section]]?.count ?? 0
            }
        }
    }
   
    func numberOfSectionsInTableView(table: UITableView) -> Int {

        if searchController.active {
            return 1
        }else{
            return cityHeader.count
        }
        
    }
    
    func tableView(table: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if searchController.active {
            return nil
        }else{
            let view:SectionView = SectionView.viewFromNibNamed()
            view.backgroundColor = UIColor.hexStringToColor("F5F5F5")
            view.addData(cityHeader[section].uppercaseString)
             return view
        }
    }
    
//    func tableView(tableView: UITableView, section: Int) -> CGFloat {
//        
//    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchController.active {
            return 0
        }else{
            return 20
        }
    }
    
    func tableView(table: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if(indexPath.section == 0 && searchController.active == false){
            let width = UIScreen.mainScreen().bounds.size.width
            let row = hotCitys.count % 3 == 0 ? hotCitys.count / 3 : hotCitys.count / 3 + 1
            return 30 + CGFloat(row) * ((width - 68) / 3 * 50 / 168) + CGFloat(row) * 10
        }
        return 40
    }
    
    internal func tableView(table: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let identifierHead = "cellHead"
        let identifier = "cell"
        var cellHead = table.dequeueReusableCellWithIdentifier(identifierHead) as? TableViewHeadSectionCell
        var cell:TableViewCell? = table.dequeueReusableCellWithIdentifier(identifier) as? TableViewCell
        let section = indexPath.section
        
        if section == 0 && searchController.active == false {
            
            if(cellHead == nil){
                let nib:UINib = UINib(nibName: "TableViewHeadSectionCell", bundle: NSBundle.mainBundle())
                table.registerNib(nib, forCellReuseIdentifier: identifierHead)
                cellHead = table.dequeueReusableCellWithIdentifier(identifierHead) as? TableViewHeadSectionCell
            }
            cellHead?.addData(hotCitys , city: selectCity)
            cellHead?.reloadData()
            return cellHead!
            
        }
        if(cell == nil){
            let nib:UINib = UINib(nibName: "TableViewCell", bundle: NSBundle.mainBundle());
            table.registerNib(nib, forCellReuseIdentifier: identifier)
            cell = table.dequeueReusableCellWithIdentifier(identifier) as? TableViewCell
        }
        //添加数据
        if searchController.active {
            cell?.setData(searchCityArray[indexPath.row]["Name"] as! String)
        }else{
            cell?.setData(citys[cityHeader[indexPath.section]]![indexPath.row]["Name"] as! String)
        }
        cell?.selectionStyle = .None
        return cell!
    }
    
    //////////////////// UITableViewDelegate  ////////////////////
    
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableview.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = table.cellForRowAtIndexPath(indexPath) as! TableViewCell
        cell.cityName.textColor = UIColor.hexStringToColor(TEXTCOLOR)
        cell.accessoryView = UIImageView(image: UIImage(named: "icon_selcity_seleted"))
        var city:[String : AnyObject] = [:]
 
            
        if(searchController.active){
            city = searchCityArray[indexPath.row]
        }else{
            let section = indexPath.section
            if(section > 0){//列表城市
                city = citys[cityHeader[indexPath.section]]![indexPath.row]
            }
        }
        
        self.performSelector(#selector(CityViewController.selectCity(_:)), withObject: city, afterDelay: 0.1)
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchCityArray.removeAll()
        if let searchString = searchController.searchBar.text where searchString.characters.count > 0 {
            for array in citys.values {
                for city in array {
                    let pinyin = city["Pinyin"] as? String ?? ""
                    let cityName = city["Name"] as? String ?? ""
                    let predicate = NSPredicate(format: "SELF CONTAINS[c] %@" , searchString)
                    if predicate.evaluateWithObject(pinyin) || predicate.evaluateWithObject(cityName){
                        searchCityArray.append(city)
                    }
                }
            }
            
        }
        
        tableview.reloadData()
        
    }
    
    

    
}
