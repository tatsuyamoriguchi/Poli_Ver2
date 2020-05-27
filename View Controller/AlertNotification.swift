//
//  AlertNotification.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 8/6/18.
//  Copyright © 2018 Becko's Inc. All rights reserved.
//

import Foundation
import UIKit

class AlertNotification: UIViewController {
    
    // Alert with passing title and message
    func alert(title: String, message: String, sender: Any, tag: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let NSL_oK = NSLocalizedString("NSL_oK", value: "OK", comment: "")
//        alert.addAction(UIAlertAction(title: NSL_oK, style: .default, handler: nil))
        

        switch tag {
            
        case "calendar":
            let NSL_cancelButton = NSLocalizedString("NSL_cancelButton", value: "Cancel", comment: "")
            alert.addAction(UIAlertAction(title: NSL_cancelButton, style: .default, handler: nil))

            alert.addAction(UIAlertAction(title: NSL_oK, style: .default, handler: goToSettings))
        
        default:
            alert.addAction(UIAlertAction(title: NSL_oK, style: .default, handler: nil))

        }
        
        
        (sender as AnyObject).present(alert, animated: true, completion: nil)
        print("Alert function executed")
    
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        let messageText = NSMutableAttributedString(string: message, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0)])
        alert.setValue(messageText, forKey: "attributedMessage")
        

    }

    func goToSettings(alert: UIAlertAction!) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

}
