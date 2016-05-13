//
//  ArticlesViewController.swift
//  Qubad
//
//  Created by 小林聖哉 on 2016/05/13.
//  Copyright © 2016年 koba. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ArticlesViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleSearchBar: UISearchBar!
    @IBOutlet weak var articleTableView: UITableView!
    
    var articles: [[String: AnyObject?]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleSearchBar.delegate = self
        titleSearchBar.placeholder = "Title"
        titleSearchBar.showsCancelButton = true
        articleTableView.delegate = self
        articleTableView.dataSource = self
        
        getNewArticles()
    }
    
    // MARK: - SearchBar Delegaete
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchTitleArticles(searchBar.text!)
        searchBar.resignFirstResponder()
    }
    
    // MARK: - TableView Delegate, DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
        let article = articles[indexPath.row]
        cell.textLabel?.text = article["title"] as? String
        let count = article["stock_count"] as? Int
        cell.detailTextLabel?.text = (count?.description)! + " Stocks"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let loadingView = WebViewController(nibName: "WebViewController", bundle: nil)
        let article = articles[indexPath.row]
        loadingView.articleTitle = article["title"] as? String
        loadingView.articleURL =  article["url"] as? String
        loadingView.itemID = article["uuid"] as? String
        loadingView.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.presentViewController(loadingView, animated: true, completion: nil)
    }
    
    // MARK: - Get Articles
    
    func getNewArticles() {
        Alamofire.request(.GET, "https://qiita.com/api/v1/items")
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                let json = JSON(object)
                json.forEach { (_, json) in
                    let article: [String: AnyObject?] = [
                        "title": json["title"].string,
                        "url": json["url"].string,
                        "uuid": json["uuid"].string,
                        "stock_count": json["stock_count"].int
                    ]
                    self.articles.append(article)
                }
                self.articleTableView.reloadData()
        }
    }
    
    func searchTitleArticles(keyword: String) {
        articles = []
        let param = [ "q": keyword, ]
        
        Alamofire.request(.GET, "https://qiita.com/api/v1/search", parameters: param)
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                let json = JSON(object)
                json.forEach { (_, json) in
                    let article: [String: AnyObject?] = [
                        "title": json["title"].string,
                        "url": json["url"].string,
                        "uuid": json["uuid"].string,
                        "stock_count": json["stock_count"].int
                    ]
                    self.articles.append(article)
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
