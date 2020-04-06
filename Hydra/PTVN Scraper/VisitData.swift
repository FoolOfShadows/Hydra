//
//  VisitData.swift
//  PTVN Scraper
//
//  Created by Fool on 2/15/18.
//  Copyright © 2018 Fulgent Wake. All rights reserved.
//

import Foundation

class VisitData {
    var visitDate:Date
	var dateOfBirth:String
	var ptName:String
    var pharmacy:String
	var tasks:[String]
    
    init(visitDate: Date, dob: String, name:String, pharmacy:String = "", tasks:[String]) {
        self.visitDate = visitDate
        self.dateOfBirth = dob
        self.ptName = name
        self.pharmacy = pharmacy
        self.tasks = tasks
    }

}

extension VisitData {
	func reportOutput() -> String {
        return "\(self.ptName)  (\(self.dateOfBirth))     Visit: \(self.visitDate)\n\(self.pharmacy)\n\(addCharactersToFront(self.tasks.joined(separator: "\n"), theCharacters: "- "))"
	}
    func followupOutput() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        if self.tasks.count == 1 {
            var totalDays = Int()
            var approxFUDate = "Unable to calculate correct followup date."
            let theTask = self.tasks[0]
            if !theTask.contains("Schedule follow up appointment in") {
                return "\(self.ptName) (\(self.dateOfBirth))     Visit: \(dateFormatter.string(from:self.visitDate))\n\(addCharactersToFront(theTask, theCharacters: "- "))"
            }
            let daysOut = simpleRegExMatch(theTask, theExpression: "\\d+ (months|weeks|days)")
            let length = simpleRegExMatch(theTask, theExpression: "\\d\\d minutes")
            let chiefComplaint = simpleRegExMatch(theTask, theExpression: "Followup will be for: .*")
            
            let numberDays = Int(simpleRegExMatch(daysOut, theExpression: "\\d+")) ?? 0
            let dwm = simpleRegExMatch(daysOut, theExpression: "(months|weeks|days)")
            
            switch dwm {
            case "months":
                totalDays = numberDays * 30
            case "weeks":
                totalDays = numberDays * 7
            default:
                totalDays = numberDays
            }
            
            
            if totalDays != 0 {
                approxFUDate = dateFormatter.string(from: self.visitDate.addingDays(totalDays)!)
            }
            let output = "Schedule next visit for \(daysOut) from this appointment (around \(approxFUDate)), for \(length).\n\(chiefComplaint)"
            
            return  "\(self.ptName) (\(self.dateOfBirth))     Visit: \(dateFormatter.string(from:self.visitDate))\n\(addCharactersToFront(output, theCharacters: "- "))"
        } else if self.tasks.count == 0 {
            return "\(self.ptName) (\(self.dateOfBirth))     Visit: \(dateFormatter.string(from:self.visitDate))\n- No follow up data included in PTVN for date \(visitDate)"
        }
        return "Unable to calculate follow up information"
    }
}
