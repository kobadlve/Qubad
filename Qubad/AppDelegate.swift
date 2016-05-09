//
//  AppDelegate.swift
//  Qubad
//
//  Created by 小林聖哉 on 2016/04/27.
//  Copyright © 2016年 koba. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
        let config = Realm.Configuration(
            // 新しいスキーマバージョンを設定します。以前のバージョンより大きくなければなりません。
            // （スキーマバージョンを設定したことがなければ、最初は0が設定されています）
            schemaVersion: 1,
            
            // マイグレーション処理を記述します。古いスキーマバージョンのRealmを開こうとすると
            // 自動的にマイグレーションが実行されます。
            migrationBlock: { migration, oldSchemaVersion in
                // 最初のマイグレーションの場合、`oldSchemaVersion`は0です
                if (oldSchemaVersion < 1) {
                    // 何もする必要はありません！
                    // Realmは自動的に新しく追加されたプロパティと、削除されたプロパティを認識します。
                    // そしてディスク上のスキーマを自動的にアップデートします。
                }
        })
        
        // デフォルトRealmに新しい設定を適用します
        Realm.Configuration.defaultConfiguration = config
        
        // Realmファイルを開こうとしたときスキーマバージョンが異なれば、
        // 自動的にマイグレーションが実行されます
        let realm = try! Realm()
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

