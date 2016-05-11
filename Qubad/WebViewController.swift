//
//  WebViewController.swift
//  Qubad
//
//  Created by 小林聖哉 on 2016/05/09.
//  Copyright © 2016年 koba. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet var navigateItem: [UINavigationItem]!
    @IBAction func backView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    var articleURL: String!
    var articleTitle: String!
    
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

    func dismissView() {
        dismissViewControllerAnimated(true, completion: nil)
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
