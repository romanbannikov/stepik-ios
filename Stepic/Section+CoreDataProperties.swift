//
//  Section+CoreDataProperties.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Section {

    @NSManaged var managedId: NSNumber?
    @NSManaged var managedPosition: NSNumber?
    @NSManaged var managedTitle: String?
    @NSManaged var managedBeginDate: NSDate?
    @NSManaged var managedSoftDeadline: NSDate?
    @NSManaged var managedHardDeadline: NSDate?
    @NSManaged var managedActive: NSNumber?
    
    @NSManaged var managedLoaded: NSNumber?

    
    @NSManaged var managedCourse : Course?

    
    class var entity : NSEntityDescription {
        return NSEntityDescription.entityForName("Section", inManagedObjectContext: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Section.entity, insertIntoManagedObjectContext: CoreDataHelper.instance.context)
    }
    
    var id : Int {
        set(newId){
            self.managedId = newId
        }
        get {
            return managedId?.integerValue ?? -1
        }
    }

    var position : Int {
        set(value){
            self.managedPosition = value
        }
        get {
            return managedPosition?.integerValue ?? -1
        }
    }

    var title : String {
        set(value){
            self.managedTitle = value
        }
        get {
            return managedTitle ?? "No title"
        }
    }
    
    var beginDate : NSDate? {
        set(date){
            self.managedBeginDate = date
        }
        get {
            return managedBeginDate
        }
    }
    
    var softDeadline: NSDate? {
        set(date){ 
            self.managedSoftDeadline = date
        }
        get{
            return managedSoftDeadline
        }
    }
    
    var hardDeadline: NSDate? {
        set(date){ 
            self.managedHardDeadline = date
        }
        get{
            return managedHardDeadline
        }
    }

    
    var isActive : Bool {
        set(value){
            self.managedActive = value
        }
        get {
            return managedActive?.boolValue ?? false
        }
    }
    
    var loaded : Bool {
        set(value){
            self.managedLoaded = value
        }
        get {
            return managedLoaded?.boolValue ?? false
        }
    }
    
    var course : Course? {
        return managedCourse
    }
}