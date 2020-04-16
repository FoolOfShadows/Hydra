//
//  LabsViewController.swift
//  LIROS
//
//  Created by Fool on 10/30/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Cocoa

class LabsViewController: NSViewController {
    
    @IBOutlet var labView: NSView!
    @IBOutlet weak var labBox: NSView!
    @IBOutlet weak var fluBox: NSBox!
    
    @IBOutlet weak var reviewedCheck: NSButton!
    @IBOutlet weak var fastingCheck: NSButton!
    @IBOutlet weak var labDueMatrix: NSMatrix!
    @IBOutlet weak var addOnCheck: NSButton!
    @IBOutlet weak var other1View: NSTextField!
    @IBOutlet weak var other1DxCombo: NSComboBox!
    @IBOutlet weak var other2View: NSTextField!
    @IBOutlet weak var other2DxCombo: NSComboBox!
    
    var lastNameID = String()
    
    var currentPatient = LabPatient(theText: "")
    
    //Create an array of the tag number and string value for the fields in the lab box
    var labFields:[(Int, String?)] { return getTextfieldsIn(labBox)}
    
    //weak var currentPTVNDelegate: ptvnDelegate?
    //var theData = PTVN(theText: "")
    
    //let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up the choices for the dx comboboxes in the lab box
        clearLabs(self)
    }
    
    //Scrapes a view for all the textfields in a view
    //and returns an array of tuples containing the fields tag
    //and string value
    func getTextfieldsIn(_ view: NSView) -> [(Int, String?)] {
        var results = [(Int, String?)]()
        
        for item in view.subviews {
            if let isTextfield = item as? NSTextField {
                if isTextfield.isEditable {
                    results.append((isTextfield.tag, isTextfield.stringValue))
                }
            } else {
                results += getTextfieldsIn(item)
            }
        }
        return results.sorted(by: {$0.0 < $1.0})
    }
    
    //Populates the choices of the comboboxes in a view based on matching
    //the boxes tag with a switch in the LabDxValues struct
    func populateComboboxSelectionsIn(_ view: NSView, Using theStruct: populateComboBoxProtocol) {
        for item in view.subviews {
            if let isCombobox = item as? NSComboBox {
                if let dxSelections = theStruct.matchValuesFrom(isCombobox.tag) {
                    isCombobox.removeAllItems()
                    isCombobox.addItems(withObjectValues: dxSelections)
                    isCombobox.selectItem(at: 0)
                }
            } else {
                populateComboboxSelectionsIn(item, Using: theStruct)
            }
        }
        
    }
    
    @IBAction func clearLabs(_ sender: Any) {
        labView.clearControllers()
        populateComboboxSelectionsIn(labBox, Using: LabDxValues())
        //print("\n\n\n\(declinesFlu)\n\n\n")
        //populateComboboxSelectionsIn(fluBox, Using: FluComboboxValues())
    }
    
    @IBAction func select90DayLabs(_ sender: Any) {
        let selection = [2, 3, 4, 17]
        markSelectedLabs(selection)
    }
    
    @IBAction func selectDMLabs(_ sender: Any) {
        let selection = [2, 3, 4, 33, 34]
        markSelectedLabs(selection)
    }
    
    @IBAction func selectThyLabs(_ sender: Any) {
        let selection = [4, 5 ,6]
        markSelectedLabs(selection)
    }
    
    @IBAction func selectRheumLabs(_ sender: Any) {
        let selection = [8, 9, 10, 11, 12, 26]
        markSelectedLabs(selection)
    }
    
    @IBAction func selectYearlyLabs(_ sender: Any) {
        let selection = [2, 3, 4, 17]
        markSelectedLabs(selection)
    }
    
    @IBAction func selectSTDLabs(_ sender: Any) {
        let selection = [14, 15, 30, 45]
        markSelectedLabs(selection)
    }
    

    //Marks a selection of labs in the lab box based on their tag
    //values received as the parameter.  Also sets the dx to
    //the second choice in the combo box
    func markSelectedLabs(_ tags:[Int]) {
        for item in tags {
            for box in labBox.subviews {
                if item == box.tag {
                    guard let box = box as? NSComboBox else { continue }
                    box.selectItem(at: 1)
                }
                
            }
        }
    }
    @IBAction func setUpLabPrinting(_ sender: Any?) {
        let pasteBoard = NSPasteboard.general
        guard let profileViewData = pasteBoard.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) else { return }
        if !profileViewData.contains("SOCIAL SECURITY NUMBER")  || !profileViewData.contains("DOB:") {
            let theAlert = NSAlert()
            theAlert.messageText = "You need to copy the data from the Profile tab of the patient's chart in order to proceed.  Also, make sure to click the elipsis to show the date of birth."
            theAlert.beginSheetModal(for: self.view.window!) { (NSModalResponse) -> Void in
                let returnCode = NSModalResponse
                print (returnCode)
            }
        } else {
            currentPatient = LabPatient(theText: profileViewData)
            print("MC1: \(currentPatient.medicare)")
            performSegue(withIdentifier: "setUpPrintLabs", sender: self)
        }
    }
    
//    @IBAction func setUpLabPrinting(_ sender: Any?) {
//        print("Opening Lab Printing Setup")
//        //Make sure the user is on the Profile tab
//        let pasteBoard = NSPasteboard.general
//        guard let profileViewData = pasteBoard.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) else { return }
//        if !profileViewData.contains("SOCIAL SECURITY NUMBER") {
//            //Create an alert to let the user know they aren't on the Profile tab
//            //After notifying the user, break out of the program
//            let theAlert = NSAlert()
//            theAlert.messageText = "You need to copy the data from the Profile tab of the patients chart in order to proceed."
//            theAlert.beginSheetModal(for: self.view.window!) { (NSModalResponse) -> Void in
//                let returnCode = NSModalResponse
//                print(returnCode)}
//            //Display warning and escape
//            //return
//        }
//        print("Creating Patient")
//        currentPatient = LabPatient(theText: profileViewData)
//        print("Name: \(currentPatient.ptInnerName)")
//        performSegue(withIdentifier: "setUpPrintLabs", sender: self)
//    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "setUpPrintLabs" {
            print("Segueing")
            if let toViewController = segue.destinationController as? LabSetUpPrintViewController {
                let processedLabs = processLabsForNote()
                if !processedLabs.isEmpty {
                    toViewController.labPrintVersion = processLabsForPrint().joined(separator: "\n")
                    toViewController.labNoteVersion = "Labs ordered: \(processedLabs.joined(separator: ", "))"
                    toViewController.addOnResult = addOnCheck.state.rawValue
                    toViewController.ptDOB = currentPatient.ptDOB
                    toViewController.ptName = currentPatient.ptInnerName
                    toViewController.MC = currentPatient.medicare
                }
            }
        }
    }
    
    func processLabsForNote() -> [String] {
        var results = Labs().processLabDataForNote(labFields)
        if let otherLabResults = processOtherLabsForNote(data: [other1View.stringValue, other2View.stringValue]) {
            if !otherLabResults.isEmpty {
            results.append(otherLabResults)
            }
        }
        
        return results
    }
    
    func processOtherLabsForNote(data:[String]) -> String? {
        var results = [String]()
        for item in data {
            if !item.isEmpty {
                results.append(item)
            }
        }
        
        return results.joined(separator: ", ")
    }
    
    func processLabsForPrint() -> [String] {
        var results = Labs().processLabDataForPrint(labFields)
        if let otherLabResults = processOtherLabsForPrint(data: [(other1View.stringValue, other1DxCombo.stringValue), (other2View.stringValue, other2DxCombo.stringValue)]) {
            results.append(otherLabResults)
        }
        return results
    }
    
    func processOtherLabsForPrint(data:[(String, String)]) -> String? {
        var results = [String]()
        for item in data {
            if !item.0.isEmpty {
                results.append("\(item.0) - \(item.1)")
            }
        }
        
        return results.joined(separator: "\n")
    }
    
    @IBAction func onlyOneCheckAtATime(_ sender:NSButton) {
        let fluCheckboxes = fluBox.getListOfButtons()
        for box in fluCheckboxes {
            if box.tag != sender.tag {
                box.state = .off
            }
        }
    }
    
    private func createPatientObject(withHandler handler: @escaping () -> Void) {
	//Need Name, DOB, Whether MC is primary

    }
}
