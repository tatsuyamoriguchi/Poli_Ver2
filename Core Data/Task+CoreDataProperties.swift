//
//  Task+CoreDataProperties.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 9/14/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var isDone: Bool
    @NSManaged public var isImportant: Bool
    @NSManaged public var toDo: String?
    @NSManaged public var url: URL?
    @NSManaged public var goalAssigned: Goal?
    @NSManaged public var reward4Task: Reward?
    @NSManaged public var repeatTask: NSNumber?
    @NSManaged public var dataVer: Int32
}
