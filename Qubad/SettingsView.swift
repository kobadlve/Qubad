//
//  SettingsView.swift
//  Qubad
//
//  Created by 小林聖哉 on 2016/05/09.
//  Copyright © 2016年 koba. All rights reserved.
//

import UIKit
import SSKeychain

class SettingsView: UIView {
    
    enum keyChain: String {
        case service = "qiita"
        case account = "user"
        case passwd = "passwd"
    }
    
    var profileView: ProfileViewController!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var settingTableView: UITableView!
    
    @IBAction func logoutButton(sender: AnyObject) {
        let alertController = UIAlertController(title: "Logout OK?", message: "", preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: { Void in
            SSKeychain.deletePasswordForService(keyChain.service.rawValue, account: keyChain.account.rawValue)
            self.profileView.dismissViewControllerAnimated(true, completion: nil)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(defaultAction)
        alertController.addAction(cancel)
        profileView.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        comminInit()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        comminInit()
    }
    
    
    private func comminInit() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "SettingsView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil).first as! UIView
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|",
            options:NSLayoutFormatOptions(rawValue: 0),
            metrics:nil,
            views: bindings))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",
            options:NSLayoutFormatOptions(rawValue: 0),
            metrics:nil,
            views: bindings))
    }
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
}
