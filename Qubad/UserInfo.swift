//
//  UserInfo.swift
//  Qubad
//
//  Created by 小林聖哉 on 2016/05/02.
//  Copyright © 2016年 koba. All rights reserved.
//

import Foundation
import RealmSwift

class UserInfo: Object {
    dynamic var name = ""
    dynamic var url_name = ""
    dynamic var profile_image_url = ""
    dynamic var url = ""
    dynamic var descriptions = ""
    dynamic var website_url = ""
    dynamic var organization = ""
    dynamic var location = ""
    dynamic var facebook = ""
    dynamic var linkedin = ""
    dynamic var twitter = ""
    dynamic var gihub = ""
    dynamic var follwers = 0
    dynamic var following_users = 0
    dynamic var item = 0
    dynamic var contribution = 0
    
}
