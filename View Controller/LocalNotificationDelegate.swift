//
//  LocalNotificationDelegate.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 8/19/18.
//  Copyright © 2018 Becko's Inc. All rights reserved.
//

import Foundation
import UserNotifications
import CoreData
import UIKit

class LocalNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    var tasks = [Task]()
    var userName: String! = nil
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == "yes" {
           
            
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let sb = UIStoryboard(name: "Main", bundle: nil)
  
            // User needs to tap Logout button in order to change login state to logout.
            // otherwise the state remains as login even though you do need to login when opening the app
            // after wiping out the app (not running on the device)
            // The login state of UserDegfaults is actually different from actual login/logout to the app.
            // If 'login state is true in UserDefaults even despite of the app is not running,
            // Tapping 'Yeees!' from the notification takes you to Today's Task list view with your login
            // information.
            if UserDefaults.standard.bool(forKey: "isLoggedIn") == true {

                let rootVC = sb.instantiateViewController(withIdentifier: "rootNavigator") as! RootViewController
                let newViewController = sb.instantiateViewController(withIdentifier: "todayVC") as! TodaysTasksTableViewController
                appDelegate.window?.rootViewController = rootVC
                rootVC.pushViewController(newViewController, animated: true)
                
            }else {
                // If login state is false in UserDefaults, tapping 'Yeees!' takes you to login view.
                let rootVC = sb.instantiateViewController(withIdentifier: "logInVC") as! LoginViewController
                appDelegate.window?.rootViewController = rootVC
                
                }

        } else {
            
        }
 
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
}
