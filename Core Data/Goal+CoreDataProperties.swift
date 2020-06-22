//
//  Goal+CoreDataProperties.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 9/3/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Goal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Goal> {
        return NSFetchRequest<Goal>(entityName: "Goal")
    }

    @NSManaged public var goalDescription: String?
    @NSManaged public var goalDone: Bool
    @NSManaged public var goalDueDate: NSDate?
    //@NSManaged public var goalReward: String?
    @NSManaged public var goalRewardImage: NSData?
    @NSManaged public var goalTitle: String?
    @NSManaged public var reward4Goal: Reward?
    @NSManaged public var tasksAssigned: NSSet?
    @NSManaged public var vision4Goal: Vision?
    @NSManaged public var dataVer: Int32

}

// MARK: Generated accessors for tasksAssigned
extension Goal {

    @objc(addTasksAssignedObject:)
    @NSManaged public func addToTasksAssigned(_ value: Task)

    @objc(removeTasksAssignedObject:)
    @NSManaged public func removeFromTasksAssigned(_ value: Task)

    @objc(addTasksAssigned:)
    @NSManaged public func addToTasksAssigned(_ values: NSSet)

    @objc(removeTasksAssigned:)
    @NSManaged public func removeFromTasksAssigned(_ values: NSSet)

}
