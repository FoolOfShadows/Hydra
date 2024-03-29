//
//  DataProcessingModel.swift
//  ScriptsFromPTVNs
//
//  Created by Fool on 2/8/18.
//  Copyright © 2018 Fulgent Wake. All rights reserved.
//

import Cocoa

enum TimeMatched {
	case on
	case before
	case after
	case between
}

func getFileNamesFrom(_ files: [URL], forDate date:(start:Date, end:Date?), status:TimeMatched) -> [URL] {
	//print("Getting matching file names")
	//Convert URL array to String array using compactMap (which replaces flatMap) to filter out nil values
	//let filesAsStrings = files.compactMap {$0.urlIntoCleanString()}
	let formatter = DateFormatter()
	formatter.dateFormat = "yyMMdd"
	var results = [URL]()
	//print(formatter.string(from: date.start))
	switch status {
	case .on: results = files.filter{$0.absoluteString.contains(formatter.string(from: date.start))}
	case .before: results = []
	case .after:
		for item in files {
            guard var itemDate = item.splitFileNameIntoComponents()?.last else { continue }
            if itemDate.contains("f") {
                itemDate = itemDate.replacingOccurrences(of: "f", with: "")
            }
			guard let dateInt = Int(itemDate),
				  let startInt = Int(formatter.string(from: date.start)) else { continue }
			if dateInt >= startInt {
				results.append(item)
			}
		}
	case .between:
		for item in files {
			guard var itemDate = item.splitFileNameIntoComponents()?.last
                else { continue }
            if itemDate.contains("f") {
                itemDate = itemDate.replacingOccurrences(of: "f", with: "")
            }
			guard let dateInt = Int(itemDate),
				let startInt = Int(formatter.string(from: date.start)),
				let endInt = Int(formatter.string(from: date.end!)) else { continue }
			if dateInt >= startInt && dateInt <= endInt {
				results.append(item)
			}
		}
	}
	//print("Matching files: \(results)")
	return results
}

enum SearchType:String {
    case ALL = "SCRIPTS & REFERRALS"
    case MEDS = "SCRIPTS"
    case REF = "REFERRALS"
    case PMH = "PMH CHANGES"
    case FRONT = "XRAY & LAB ORDERS"
    case FU = "FOLLOW UP"
}

func processTheFiles(_ theFiles:[URL]?, for type: SearchType) -> [VisitData] {
    //print("The search type is: \(type)")
    
    var chosenFunction: (String) -> [String]
    
    switch type {
    case .ALL:
        chosenFunction = getMarkedLines(_:)
    case .MEDS:
        chosenFunction = getMedLines(_:)
    case .REF:
        chosenFunction = getRefLines(_:)
    case .PMH:
        chosenFunction = getMarkedLines(_:)
    //FIXME: replace with a function pulling xrays and lab orders
    case .FRONT:
        chosenFunction = getFrontDeskLines(_:)
    case .FU:
        chosenFunction = getFollowupLines(_:)
    }
    
    //print("Processing the files")
    var neededRxs = [VisitData]()
    //var results = ""
    if let thePTVNText = theFiles {
        //print("\n\nFiles passed in for processing are \(thePTVNText)")
        for file in thePTVNText {
            //print(file.absoluteString)
            do {
                let ptvnContents = try String(contentsOf: file, encoding: .utf8)
                //check if its a new or old style PTVN file
                //if it's old, do the following
                if ptvnContents.contains("#PTVNFILE#") {
                    let dobResults = getNewDOBInfo(ptvnContents)
                    let nameResults = getNewNameInfo(ptvnContents)
                    let pharmacyName = getPatientDataOfType("PHARMACY", from: ptvnContents)
                    let markedResults = cleanTheSelection(chosenFunction(ptvnContents), badBits: badBits)
                    if !markedResults.isEmpty {
                        neededRxs.append(VisitData(visitDate: getVisitDate(ptvnContents), dob: dobResults, name: nameResults, pharmacy: pharmacyName, tasks: markedResults))
                        //print(neededRxs)
                    }
                } else {
                    let rxResults = cleanTheSelection(getRxInfo(ptvnContents), badBits: badBits)
                    let dobResults = getDOBInfo(ptvnContents)
                    let nameResults = getNameInfo(ptvnContents)
                    let markedResults = cleanTheSelection(chosenFunction(ptvnContents), badBits: badBits)
                    
                    if (!rxResults.isEmpty) && (!markedResults.isEmpty) {
                        neededRxs.append(VisitData(visitDate: getVisitDate(ptvnContents), dob: dobResults, name: nameResults, tasks: rxResults + markedResults))
                    } else if (!rxResults.isEmpty) || (!markedResults.isEmpty) {
                        neededRxs.append(VisitData(visitDate: getVisitDate(ptvnContents), dob: dobResults, name: nameResults, tasks: rxResults + markedResults))
                    }
                }
            } catch {
                print("Ended up in the CATCH clause")
            }
            //if it's new, process it with a new method
        }
    }
    //print(neededRxs)
    return neededRxs
}

func getVisitDate(_ theText:String) -> Date {
    //print("The Text is\n\(theText)")
    let stringDate = simpleRegExMatch(theText, theExpression: "(?s)#VISITDATE.*VISITDATE#").cleanTheTextOf(["#VISITDATE","VISITDATE#"])
    print("The date is\n\(stringDate)")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yy"
    //print(dateFormatter.date(from: stringDate))
    //FIXME - Force unwrapping is the wrong choice for this
    return dateFormatter.date(from: stringDate)!
    //return Date()
}


func getNameInfo(_ theText:String) -> String {
	var nameInfo = ""
	
	let separatedText = theText.components(separatedBy: "\n")
	//print(separatedText)
	nameInfo = separatedText[0].removeWhiteSpace()
	
	return nameInfo
}

func getNewNameInfo(_ theText:String) -> String {
    guard let nameInfo = theText.findRegexMatchBetween("#PATIENTNAME", and: "PATIENTNAME#") else { return String() }
    return nameInfo.removeWhiteSpace()
}

func getDOBInfo(_ theText:String) -> String {
	var dobInfo = ""
	guard let rawDOBInfo = theText.findRegexMatchBetween("DOB:", and: "Age:") else { return "" }
	dobInfo = rawDOBInfo.removeWhiteSpace()
	return dobInfo
}

func getNewDOBInfo(_ theText:String) -> String {
    var dobInfo = String()
    guard let rawDOBInfo = theText.findRegexMatchBetween("#PATIENTDOB", and: "PATIENTDOB#") else { return dobInfo }
    dobInfo = rawDOBInfo.removeWhiteSpace()
    return dobInfo
}

func getPatientDataOfType(_ type:String, from theText: String) -> String {
    //print("#\(type) \(type)#")
    return theText.findRegexMatchBetween("#\(type)", and: "\(type)#")?.removeWhiteSpace() ?? ""
}

func getRxInfo(_ theText:String) -> [String] {
	var rxInfo = ""
	guard let rawNeededScripts = theText.findRegexMatchBetween("\\*\\*Rx\\*\\*", and: "O\\(PE\\):") else { return [] }
	rxInfo = rawNeededScripts.removeWhiteSpace()
	let rxData = rxInfo.components(separatedBy: "\n")
	return rxData
}

func getMarkedLines(_ theText:String) -> [String] {
	var markedLines = [String]()
	//var results = String()
	let theLines = theText.components(separatedBy: "\n")
	for line in theLines {
		if line.contains("^^") || line.contains("~~") || line.contains("••") {
			let cleanLine = cleanTheSections(line, badBits: ["^^", "••", "~~"])
			markedLines.append(cleanLine)
		}
	}
	return markedLines
}

func getFollowupLines(_ theText:String) -> [String] {
    var markedLines = [String]()
    if !theText.contains("`•") {
        return ["No followup data for this visit"]
    }
    let theLines = theText.components(separatedBy: "\n")
    for line in theLines {
        if line.contains("`•") {
            let cleanLine = cleanTheSections(line, badBits: ["`•"])
            markedLines.append(cleanLine)
        }
    }
    
    return markedLines
}

func getMedLines(_ theText:String) -> [String] {
    var markedLines = [String]()
    //var results = String()
    let theLines = theText.components(separatedBy: "\n")
    for line in theLines {
        if line.contains("~~") {
            let cleanLine = cleanTheSections(line, badBits: ["~~"])
            //let cleanLine = line.replacingOccurrences(of: "~~", with: "")
            markedLines.append(cleanLine)
        } else if line.contains("``") {
            let cleanLine = "UPDATE ONLY: \(cleanTheSections(line, badBits: ["``"]))"
            markedLines.append(cleanLine)
        } else if line.contains("`~") {
            let cleanLine = "RX and UPDATE: \(cleanTheSections(line, badBits: ["`~"]))"
            markedLines.append(cleanLine)
        }
    }
    return markedLines
}

func getRefLines(_ theText:String) -> [String] {
    var markedLines = [String]()
    //var results = String()
    let theLines = theText.components(separatedBy: "\n")
    for line in theLines {
        if line.contains("••") {
            let cleanLine = line.replacingOccurrences(of: "••", with: "")
            markedLines.append(cleanLine)
        }
    }
    return markedLines
}

func getFrontDeskLines(_ theText:String) -> [String] {
    var markedLines = [String]()
    let theLines = theText.components(separatedBy: "\n")
    var lineCount = 0
    for line in theLines {
        if line.contains("••XRAY -") {
            let cleanLine = line.replacingOccurrences(of: "••", with: "")
            markedLines.append(cleanLine)
        } else if line.contains("lab tests") {
            markedLines.append(line)
        } else if line.contains("Labs ordered: ") {
            markedLines.append(line)
        }
        lineCount += 1
    }
    return markedLines
}

//Add specific characters to the beginning of each line
func addCharactersToFront(_ theText:String, theCharacters:String) ->String {
	var returnText = ""
	var newTextArray = [String]()
	let textArray = theText.components(separatedBy: "\n")
	let cleanedTextArray = textArray.filter({!$0.trimmingCharacters(in: NSCharacterSet.whitespaces).isEmpty })
	for line in cleanedTextArray {
		let newLine = theCharacters + line
		newTextArray.append(newLine)
	}
	
	returnText = newTextArray.joined(separator: "\n")
	
	return returnText
}

//Clean extraneous text from the sections
//func cleanTheSections(_ theSection:String, badBits:[String]) -> String {
//    var cleanedText = theSection.removeWhiteSpace()
//    for theBit in badBits {
//        cleanedText = cleanedText.replacingOccurrences(of: theBit, with: "")
//    }
//    return cleanedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//}



