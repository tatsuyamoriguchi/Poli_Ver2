//
//  LocationAuth.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 8/9/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//
// To authorize to use location service for Calendar EventKit

import Foundation
import CoreLocation
import UserNotifications

class LocationAuth {
    
    let locationManager = CLLocationManager()
    
    func enableBasicLocationServices() {
        locationManager.delegate = self as? CLLocationManagerDelegate
        
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined:
             locationManager.requestAlwaysAuthorization()
//            locationManager.requestWhenInUseAuthorization()
            print("enableBasicLocationServices() switch.notDetemined was executed.")
            break
            
        case .restricted, .denied:
            disableMyLocationBasedFeatures()
            print("enableBasicLocationServices() switch.restriced, .denied was executed.")
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            enableMyLocationWhenInUseFeatures()
            print("enableBasicLocationServices() switch.authorizedWhenInUse, .authorizedAlways was executed.")
            
            break
           
        default:
                print("switch default")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .restricted, .denied:
            disableMyLocationBasedFeatures()
            print("locationManager() switch.restriced, denied was executed.")
            
            break
            
        case .authorizedWhenInUse:
            enableMyLocationWhenInUseFeatures()
            print("locationManager() .authorizedWhenInUse.enableMyLocationWhenInUseFeatures(), denied was executed.")
            break
            
        case .notDetermined, .authorizedAlways:
            print("locationManager() .notDetermined, .authorizedAlways, denied was executed.")
            break
            
        default:
            print("switch default")
            
        }
    }
    
    
    func enableMyLocationWhenInUseFeatures() {
        UserDefaults.standard.set(true, forKey: "location")
        print("UserDefaults set to true")
    }
    
    func disableMyLocationBasedFeatures() {
        UserDefaults.standard.set(false, forKey: "location")
        print("UserDefaults set to false")
    }

}
