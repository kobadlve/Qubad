//
//  ProfileViewController.swift
//  Qubad
//
//  Created by 小林聖哉 on 2016/05/09.
//  Copyright © 2016年 koba. All rights reserved.
//

import UIKit
import SSKeychain
import AlamofireImage
import Alamofire
import SwiftyJSON
import RealmSwift
import Realm


class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    enum KeyChain: String {
        case Service = "qiita"
        case Account = "user"
        case Passwd = "passwd"
    }
    
    internal enum Method: String {
        case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
    }
    
    enum Api: String {
        case URL = "https://qiita.com/api/v1/stocks"
        case User = "https://qiita.com/api/v1/user"
        case Stocks = "https://qiita.com/api/v1/users/"
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var contributionView: UIView!
    @IBOutlet weak var contributionLabel: UILabel!
    @IBOutlet weak var followersView: UIView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var itemsView: UIView!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var articleTableView: UITableView!
    
    var realm: Realm!
    var articles: [[String: AnyObject?]] = []
    var stockArticles: [[String: AnyObject?]] = []
    var segmentIndex: Int!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        articleTableView.delegate = self
        articleTableView.dataSource = self
        
        // Set View config
        contributionView.backgroundColor = UIColor(patternImage: UIImage(named: "graph")!.af_imageScaledToSize(CGSizeMake(70, 70)))
        followersView.backgroundColor = UIColor(patternImage: UIImage(named: "follower")!.af_imageScaledToSize(CGSizeMake(70, 70)))
        itemsView.backgroundColor = UIColor(patternImage: UIImage(named: "stocked")!.af_imageScaledToSize(CGSizeMake(70, 70)))
        contributionLabel.font = UIFont.boldSystemFontOfSize(contributionLabel.font.pointSize)
        followersLabel.font = UIFont.boldSystemFontOfSize(contributionLabel.font.pointSize)
        itemsLabel.font = UIFont.boldSystemFontOfSize(contributionLabel.font.pointSize)
        contributionLabel.layer.borderColor = UIColor.blackColor().CGColor
        contributionLabel.layer.borderWidth = 0.5
        contributionLabel.layer.cornerRadius = 5
        contributionLabel.layer.masksToBounds = true
        followersLabel.layer.borderColor = UIColor.blackColor().CGColor
        followersLabel.layer.borderWidth = 0.5
        followersLabel.layer.cornerRadius = 5
        followersLabel.layer.masksToBounds = true
        itemsLabel.layer.borderColor = UIColor.blackColor().CGColor
        itemsLabel.layer.borderWidth = 0.5
        itemsLabel.layer.cornerRadius = 5
        itemsLabel.layer.masksToBounds = true
        segmentIndex = 0
        getUserInfo()
    }
    
    // MARK: - TableView Delegate, DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentIndex == 1 {
            return stockArticles.count
        } else {
            return articles.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
        var article: [String: AnyObject?]
        if segmentIndex == 1 {
            article = stockArticles[indexPath.row]
        } else {
            article = articles[indexPath.row]
        }
        cell.textLabel?.text = article["title"] as? String
        let count = article["stock_count"] as? Int
        cell.detailTextLabel?.text = (count?.description)! + " Stocks"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let loadingView = WebViewController(nibName: "WebViewController", bundle: nil)
        var article: [String: AnyObject?]
        if segmentIndex == 1 {
            article = stockArticles[indexPath.row]
        } else {
            article = articles[indexPath.row]
        }
        print(article["url"])
        loadingView.articleTitle = article["title"] as? String
        loadingView.articleURL =  article["url"] as? String
        loadingView.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.presentViewController(loadingView, animated: true, completion: nil)
    }
    
    // MARK: - Button Action
    
    @IBAction func updateButton(sender: AnyObject) {
        articles = []
        stockArticles = []
        articleTableView.reloadData()
        getUserInfo()
    }
    
    @IBAction func settingButton(sender: AnyObject) {
        if let view = view.subviews.last as? SettingsView {
            view.removeFromSuperview()
        } else {
            let settingView = SettingsView(frame: CGRect(x: 100, y: 50, width: 250, height: 400))
            settingView.profileView = self
            self.view.addSubview(settingView)
        }
    }
    
    @IBAction func swichViewControl(sender: AnyObject) {
        if sender.selectedSegmentIndex == 0 {
            segmentIndex = 0
            articleTableView.reloadData()
        } else {
            segmentIndex = 1
            articleTableView.reloadData()
        }
    }
    
    // MARK: - Get User Info
    
    func getUserInfo() {
        var realm: Realm!
        let user = UserInfo()
        Alamofire.request(.GET, Api.User.rawValue, parameters: ["token": getToken()!])
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                
                let json = JSON(object)
                user.name = json["name"].stringValue
                user.url_name = json["url_name"].stringValue
                user.profile_image_url = json["profile_image_url"].stringValue
                user.url = json["url"].stringValue
                user.descriptions = json["description"].stringValue
                user.website_url = json["website_url"].stringValue
                user.organization = json["organization"].stringValue
                user.location = json["location"].stringValue
                user.facebook = json["facebook"].stringValue
                user.linkedin = json["linkedin"].stringValue
                user.twitter = json["twitter"].stringValue
                user.gihub = json["github"].stringValue
                user.follwers = json["followers"].intValue
                user.following_users = json["following_users"].intValue
                user.item = json["items"].intValue
                do {
                    realm = try Realm()
                    try realm.write {
                        realm.add(user)
                    }
                } catch {
                    print("userinfo error")
                }
                self.getStockCount()
        }
    }
    
    func getStockCount() {
        var realm: Realm!
        let user = UserInfo()
        do {
            realm = try Realm()
            for data in realm.objects(UserInfo) {
                user.url_name = data.url_name
            }
        } catch {
            print("getStock error")
        }
        let name = user.url_name
        let url = Api.Stocks.rawValue + name + "/items"
        Alamofire.request(.GET, url)
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                let json = JSON(object)
                var contributionCount = 0
                json.forEach { (_, json) in json["body"].stringValue
                    contributionCount += json["stock_count"].intValue
                }
                //user.contribution = contributionCount
                do {
                    realm = try Realm()
                    realm.beginWrite()
                    if let currentObject = realm.objects(UserInfo).last {
                        currentObject.contribution = contributionCount
                    }
                    try realm.commitWrite()
                } catch {
                    print("getStock error")
                }
                let currentObject = realm.objects(UserInfo).last!
                let imageURL = NSURL(string: currentObject.profile_image_url)!
                self.contributionLabel?.text = String(currentObject.contribution)
                self.followersLabel?.text = String(currentObject.follwers)
                self.itemsLabel?.text = String(currentObject.item)
                self.profileImageView.af_setImageWithURL(imageURL, placeholderImage: UIImage(named: "noimage"))
                self.getMyArticle(currentObject)
                self.getStockedArticles()
        }
    }
    
    func getToken() -> NSObject? {
        
        let lookupQuery = SSKeychainQuery()
        lookupQuery.service = KeyChain.Service.rawValue
        lookupQuery.account = KeyChain.Account.rawValue
        do {
            try lookupQuery.fetch()
            
            if let readDictionary = lookupQuery.passwordObject as? [String: NSObject] {
            return readDictionary["passwd"]
            } else {
                return nil
            }
        } catch {
            print("Get Token error")
            return nil
        }
    }
    
    // MARK: - Get Articles
    
    func getMyArticle(currentObject: UserInfo ) {
        let url = "https://qiita.com/api/v1/users/" + currentObject.url_name + "/items"
        Alamofire.request(.GET, url).responseJSON { response in
            guard let object = response.result.value else {
                return
            }
            let json = JSON(object)
            json.forEach { (_, json) in
                let article: [String: AnyObject?] = [
                    "title": json["title"].string,
                    "url": json["url"].string,
                    "stock_count": json["stock_count"].intValue
                ]
                self.articles.append(article)
            }
            self.articleTableView.reloadData()
        }
    }
    
    func getStockedArticles() {
        Alamofire.request(.GET, Api.URL.rawValue, parameters: ["token": getToken()!])
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                let json = JSON(object)
                json.forEach { (_, json) in
                    let article: [String: AnyObject?] = [
                        "title": json["title"].string,
                        "url": json["url"].string,
                        "stock_count": json["stock_count"].int
                    ]
                    self.stockArticles.append(article)
                }
                self.articleTableView.reloadData()
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
