//
//  Course.swift
//  
//
//  Created by Alexander Karpov on 25.09.15.
//
//

import Foundation
import CoreData
import SwiftyJSON

@objc
class Course: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    convenience init(json: JSON) {
        self.init()
        id = json["id"].intValue
        title = json["title"].stringValue
        courseDescription = json["description"].stringValue
        coverURLString = Constants.sharedConstants.stepicURLString + json["cover"].stringValue
        
        beginDate = Parser.sharedParser.dateFromTimedateJSON(json["begin_date_source"])
        endDate = Parser.sharedParser.dateFromTimedateJSON(json["last_deadline"])
        
//        if beginDate == nil {
//            print("begin date for \(title) is nil!!!")
//        }
//        
//        if endDate == nil {
//            print("end date for \(title) is nil!!!")
//        }
        
        enrolled = json["enrollment"].string != nil
        featured = json["is_featured"].boolValue
        
        summary = json["summary"].stringValue
        workload = json["workload"].stringValue
        introURL = json["intro"].stringValue
        format = json["course_format"].stringValue
        audience = json["target_audience"].stringValue
        certificate = json["certificate"].stringValue
        requirements = json["requirements"].stringValue
        
    }
    
    class func getCourses(featured: Bool? = nil, enrolled: Bool? = nil) throws -> [Course] {
        let request = NSFetchRequest(entityName: "Course")
        let descriptor = NSSortDescriptor(key: "managedId", ascending: false)
        var predicate = NSPredicate(value: true)
        
        if let f = featured {
            let p = NSPredicate(format: "managedFeatured == %@", f as NSNumber)
            predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicate, p])
        }
        
        if let e = enrolled {
            let p = NSPredicate(format: "managedEnrolled == %@", e as NSNumber)
            predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicate, p])
        }
        
        request.predicate = predicate
        request.sortDescriptors = [descriptor]
        
        do {
            let results = try CoreDataHelper.instance.context.executeFetchRequest(request)
            return results as! [Course]
        }
        catch {
            throw FetchError.RequestExecution
        }
    }
    
    class func deleteAll() {
        do {
            let c = try getCourses()
            for course in c {
                CoreDataHelper.instance.context.deleteObject(course)
            }
            CoreDataHelper.instance.save()
        }
        catch {
            print("Error while deleting course objects")
        }    
    }
}

extension NSTimeInterval {
    init(timeString: String) {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        self = formatter.dateFromString(timeString)!.timeIntervalSince1970
    }
}