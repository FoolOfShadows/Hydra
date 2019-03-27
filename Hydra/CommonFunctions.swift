//
//  CommonFunctions.swift
//  Hydra
//
//  Created by Fool on 2/6/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Foundation
//Parse a string containing a full name into it's components and returns
//the version of the name we use to label files
func getFileLabellingName(_ name: String) -> String {
    var fileLabellingName = String()
    var ptFirstName = ""
    var ptLastName = ""
    var ptMiddleName = ""
    var ptExtraName = ""
    let extraNameBits = ["Sr", "Jr", "II", "III", "IV", "MD"]
    
    func checkForMatchInSets(_ arrayToCheckIn: [String], arrayToCheckFor: [String]) -> Bool {
        var result = false
        for item in arrayToCheckIn {
            if arrayToCheckFor.contains(item) {
                result = true
                break
            }
        }
        return result
    }
    
    //Break the string apart into the various name bits, removing Practice Fusion's
    //'preferred' name in the process, identifying it by the parentheses
    let nameComponents = name.components(separatedBy: " ").filter {!$0.contains("(")}
    print(nameComponents)
    
    
    let extraBitsCheck = checkForMatchInSets(nameComponents, arrayToCheckFor: extraNameBits)
    
    if extraBitsCheck == true {
        ptLastName = nameComponents[nameComponents.count-2]
        ptExtraName = nameComponents[nameComponents.count-1]
    } else {
        ptLastName = nameComponents[nameComponents.count-1]
        ptExtraName = ""
    }
    
    if nameComponents.count > 2 {
        if nameComponents[nameComponents.count - 2] == "Van" {
            ptLastName = "Van " + ptLastName
        }
    }
    
    //Get first name
    ptFirstName = nameComponents[0]
    
    //Get middle name
    if (nameComponents.count == 3 && extraBitsCheck == true) || nameComponents.count < 3 {
        ptMiddleName = ""
    } else {
        ptMiddleName = nameComponents[1]
    }
    
    fileLabellingName = "\(ptLastName)\(ptFirstName)\(ptMiddleName)\(ptExtraName)"
    fileLabellingName = fileLabellingName.replacingOccurrences(of: " ", with: "")
    fileLabellingName = fileLabellingName.replacingOccurrences(of: "-", with: "")
    fileLabellingName = fileLabellingName.replacingOccurrences(of: "'", with: "")
    fileLabellingName = fileLabellingName.replacingOccurrences(of: "(", with: "")
    fileLabellingName = fileLabellingName.replacingOccurrences(of: ")", with: "")
    fileLabellingName = fileLabellingName.replacingOccurrences(of: "\"", with: "")
    
    
    return fileLabellingName
}

//Clean extraneous text from the sections
func cleanTheSections(_ theSection:String, badBits:[String]) -> String {
    var cleanedText = theSection.removeWhiteSpace()
    for theBit in badBits {
        cleanedText = cleanedText.replacingOccurrences(of: theBit, with: "")
    }
    cleanedText = cleanedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    return cleanedText
}
