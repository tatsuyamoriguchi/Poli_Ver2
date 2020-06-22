//
//  Vision+CoreDataProperties.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 9/3/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Vision {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vision> {
        return NSFetchRequest<Vision>(entityName: "Vision")
    }

    @NSManaged public var notes: String?
    @NSManaged public var status: Int16
    @NSManaged public var title: String?
    @NSManaged public var vision4Goal: NSSet?
    @NSManaged public var dataVer: Int32

}

// MARK: Generated accessors for vision4Goal
extension Vision {

    @objc(addVision4GoalObject:)
    @NSManaged public func addToVision4Goal(_ value: Goal)

    @objc(removeVision4GoalObject:)
    @NSManaged public func removeFromVision4Goal(_ value: Goal)

    @objc(addVision4Goal:)
    @NSManaged public func addToVision4Goal(_ values: NSSet)

    @objc(removeVision4Goal:)
    @NSManaged public func removeFromVision4Goal(_ values: NSSet)

}
