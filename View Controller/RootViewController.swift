//
//  RootViewController.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 8/20/18.
//  Copyright © 2018 Becko's Inc. All rights reserved.
//

import UIKit

class RootViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            isModalInPresentation = true
            print("iOS 13 or higher version detected.")

        } else {
            // Fallback on earlier versions
            print("iOS 12 or earlier verison detected.")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



