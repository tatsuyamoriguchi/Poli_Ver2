//
//  Locale.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 9/19/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import Foundation
import UIKit

class LocaleConvert {
    
    func currency2String(value: Int32) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale.current
        currencyFormatter.maximumFractionDigits = 0
        currencyFormatter.generatesDecimalNumbers = false
        // We'll force unwrap with the !, if you've got defined data you may need more error checking
        let priceString = currencyFormatter.string(from: NSNumber(value: value))!
        print(priceString) // Displays $9,999.99 in the US locale
        return priceString
    }
}
