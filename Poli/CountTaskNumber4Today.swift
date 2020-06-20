//
//  CountTaskNumber4Today.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 6/16/20.
//  Copyright © 2020 Becko's Inc. All rights reserved.
//

import CoreData
import UIKit

class CountTaskNumber4Today {
    
    var tasks: Array<Any>?
    var today = Date()
    
    
    func countTask() -> Int {
        let total: Int
        if let tasks = getArrayOfTasksDueTillToday() {

            total = tasks.count
            return total
        
        } else {
            print("countTask() tasks returns nil")
            return 0
        }
    }
    
    func getArrayOfTasksDueTillToday() -> Array<Any>?{

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        let donePredicate = NSPredicate(format: "isDone == %@", NSNumber(value: false))
        var andPredicate: NSCompoundPredicate
        
        //var taskDate = Task.date
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        let startDate: Date = Date()
        
        let dateFrom = calendar.startOfDay(for: startDate)
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        
        let todayPredicate: NSPredicate = NSPredicate(format: "date < %@", dateTo! as CVarArg)
        
        andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [todayPredicate, donePredicate])
        
        fetchRequest.predicate = andPredicate
        
        // Declare sort descriptor
        let sortByGoalAssigned = NSSortDescriptor(key: #keyPath(Task.goalAssigned.goalTitle), ascending: true)
        let sortByToDo = NSSortDescriptor(key: #keyPath(Task.toDo), ascending: true)
        let sortByDate = NSSortDescriptor(key: #keyPath(Task.date), ascending: true)
        
        // Sort fetchRequest array data
        fetchRequest.sortDescriptors = [sortByGoalAssigned, sortByDate, sortByToDo]
        
        
        do {
            tasks = try context.fetch(fetchRequest)
        } catch {
            print("Unable to fetch for Today Task")
        }
        
        return tasks
    }
}
