//
//  ViewController.swift
//  Qubad
//
//  Created by 小林聖哉 on 2016/04/27.
//  Copyright © 2016年 koba. All rights reserved.
//

import UIKit
import SSKeychain
import RealmSwift

class LoginViewController: UIViewController, NSURLSessionDelegate, NSURLSessionDataDelegate {

    enum KeyChain: String {
        case Service = "qiita"
        case Account = "user"
        case Passwd = "passwd"
    }
    
    enum Api: String {
        case URL = "https://qiita.com/api/v1/auth"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.initPasswd()
        self.lookQuery()
    }

    override func viewDidAppear(animated: Bool) {
        if lookQuery() == false {
        let loginAlert = UIAlertController(title: "Login", message: "", preferredStyle: .Alert)
        loginAlert.addTextFieldWithConfigurationHandler({(textField: UITextField!) -> Void in
            textField.placeholder = "username"
        })
        loginAlert.addTextFieldWithConfigurationHandler({(textField: UITextField!) -> Void in
            textField.placeholder = "passwd"
            textField.secureTextEntry = true
        })
        let login = UIAlertAction(title: "Login", style: .Default, handler: { action -> Void in
            self.tryLogin(loginAlert.textFields!)
            if self.lookQuery() == false {
                self.presentViewController(loginAlert, animated: true, completion: nil)
            } else {
                let loadingView = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
                loadingView.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
                self.presentViewController(loadingView, animated: true, completion: nil)
            }
        })
        loginAlert.addAction(login)
        presentViewController(loginAlert, animated: true, completion: nil)
        } else {
//            let loadingView = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
//            loadingView.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
//            self.presentViewController(loadingView, animated: true, completion: nil)
            let loadingView = self.storyboard?.instantiateViewControllerWithIdentifier("MainTab")
            loadingView!.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
            self.presentViewController(loadingView!, animated: true, completion: nil)
        }
    }
    
    // MARK: - SSKeychian
    
    func initPasswd() {
        
        let query = SSKeychainQuery()
        query.service = KeyChain.Service.rawValue
        query.account = KeyChain.Account.rawValue
        query.password = KeyChain.Passwd.rawValue
        
        let dictionary: [String: NSObject] = [
            "passwd": "default"
        ]
        query.passwordObject = dictionary
        do {
            try query.save()
        } catch {
            print("Save Error")
        }
    }
    
    func setPasswd(passwd: String) {
        
        let query = SSKeychainQuery()
        query.service = KeyChain.Service.rawValue
        query.account = KeyChain.Account.rawValue
        query.password = KeyChain.Passwd.rawValue
        
        let dictionary: [String: NSObject] = [
            "passwd": passwd
        ]
        query.passwordObject = dictionary
        query.passwordObject = dictionary
        do {
            try query.save()
        } catch {
            print("Save Error")
        }
    }
    
    func lookQuery() -> Bool {
        
        let lookupQuery = SSKeychainQuery()
        lookupQuery.service = KeyChain.Service.rawValue
        lookupQuery.account = KeyChain.Account.rawValue
        do {
            try lookupQuery.fetch()
        } catch {
            return false
        }
        
        if let readDictionary = lookupQuery.passwordObject as? [String: NSObject] {
            print(readDictionary["passwd"])
            if readDictionary["passwd"] == "default" {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    // MARK: - Login
    
    private func tryLogin(textFeild: [UITextField]) {
        
        let semaphore = dispatch_semaphore_create(0)
        let username = textFeild[0].text
        let passwd = textFeild[1].text
        
        let url = NSURL(string: Api.URL.rawValue)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let params: [String: AnyObject] = [
            "url_name": username!,
            "password": passwd! ]
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.init(rawValue: 2))
        } catch {
            print("create HTTPBody Error")
        }
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { data, response, error in
            if let res = response as? NSHTTPURLResponse {
                print("HttpReponse -> \(res.statusCode)")
                if res.statusCode == 200 {
                    if error == nil {
                        do {
                            if let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary {
                                self.setPasswd((result["token"] as? String)!)
                            }
                        } catch {
                            print("json data error")
                        }
                    } else {
                        print(error)
                    }
                    dispatch_semaphore_signal(semaphore)
                } else {
                    dispatch_semaphore_signal(semaphore)
                }
            }
        })
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
}
