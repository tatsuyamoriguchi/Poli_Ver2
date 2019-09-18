//
//  Access2Calendar.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 8/9/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import Foundation
import EventKit
import EventKitUI
import UIKit

class Access2Calendar {
    
    
    
    func authorizeCalendar() -> Bool {
        
        let eventStore = EKEventStore()
 
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            insertEvent(store: eventStore)
            return true
        case .denied:
            print("Access Denied")
            return false
        case .notDetermined:
            eventStore.requestAccess(to: .event, completion:
                {[weak self] (granted: Bool, error: Error?) -> Void in
                    if granted {
                        self?.insertEvent(store: eventStore)
                        
                    }else {
                        print("Access Denied")
                    }
            })
            return true
            
        default:
            print("Case default")
            return false
        }
    }
    
    
    

    func insertEvent(store: EKEventStore) {

        let startDate = Date()
        let endDate = startDate.addingTimeInterval(60 * 60)
        let title = "Test Event Title"
        let notes = "Hello this is a note."
        
        
        let event = EKEvent(eventStore: store)
        
        event.calendar = store.defaultCalendarForNewEvents
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
    
        
        do {
            try store.save(event, span: .thisEvent)
            
            
        } catch {
            print("Error saving event in calendar")
            
        }
        
    }
    
    
}
