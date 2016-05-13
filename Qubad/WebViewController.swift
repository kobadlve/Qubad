//
//  WebViewController.swift
//  Qubad
//
//  Created by 小林聖哉 on 2016/05/09.
//  Copyright © 2016年 koba. All rights reserved.
//

import UIKit
import SSKeychain
import Alamofire

class WebViewController: UIViewController {

    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet var navigateItem: [UINavigationItem]!
    
    enum KeyChain: String {
        case Service = "qiita"
        case Account = "user"
        case Passwd = "passwd"
    }
    
    internal enum Method: String {
        case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
    }
    
    var articleURL: String!
    var articleTitle: String!
    var itemID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigateItem[0].title = articleTitle
        let url = NSURL(string: articleURL)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
        
        // Set Swipe Gesture
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(WebViewController.dismissView))
        gesture.direction = UISwipeGestureRecognizerDirection.Right
        self.webView.addGestureRecognizer(gesture)
    }
    
    @IBAction func stockButton(sender: AnyObject) {
        let url = "https://qiita.com/api/v1/items/" + itemID + "/stock"
        Alamofire.request(.PUT, url, parameters: ["token": getToken()!])
            .responseJSON { response in
                guard response.result.value != nil else {
                    print("stock error")
                    return
                }
                let alert = UIAlertController(title: "Stock comleted!", message: "", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(defaultAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    @IBAction func backView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissView() {
        dismissViewControllerAnimated(true, completion: nil)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
