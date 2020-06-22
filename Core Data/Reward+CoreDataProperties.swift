//
//  Reward+CoreDataProperties.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 9/3/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Reward {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reward> {
        return NSFetchRequest<Reward>(entityName: "Reward")
    }

    @NSManaged public var title: String?
    @NSManaged public var value: Int32
    @NSManaged public var reward4Goal: NSSet?
    @NSManaged public var reward4Task: NSSet?
    @NSManaged public var dataVer: Int32
    

}

// MARK: Generated accessors for reward4Goal
extension Reward {

    @objc(addReward4GoalObject:)
    @NSManaged public func addToReward4Goal(_ value: Goal)

    @objc(removeReward4GoalObject:)
    @NSManaged public func removeFromReward4Goal(_ value: Goal)

    @objc(addReward4Goal:)
    @NSManaged public func addToReward4Goal(_ values: NSSet)

    @objc(removeReward4Goal:)
    @NSManaged public func removeFromReward4Goal(_ values: NSSet)

}

// MARK: Generated accessors for reward4Task
extension Reward {

    @objc(addReward4TaskObject:)
    @NSManaged public func addToReward4Task(_ value: Task)

    @objc(removeReward4TaskObject:)
    @NSManaged public func removeFromReward4Task(_ value: Task)

    @objc(addReward4Task:)
    @NSManaged public func addToReward4Task(_ values: NSSet)

    @objc(removeReward4Task:)
    @NSManaged public func removeFromReward4Task(_ values: NSSet)

}
