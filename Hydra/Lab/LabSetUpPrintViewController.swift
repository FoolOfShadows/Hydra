//
//  LabPrintingViewController.swift
//  LIROS
//
//  Created by Fool on 11/1/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Cocoa

class LabSetUpPrintViewController: NSViewController {
	
	@IBOutlet weak var patientNameView: NSTextField!
	@IBOutlet weak var patientDOBView: NSTextField!
	@IBOutlet weak var currentDateView: NSTextField!
	@IBOutlet weak var mcPrimaryMatrix: NSMatrix!
	
	var labPrintVersion = String()
	var labNoteVersion = String()
	var addOnResult = Int()
    var ptName = String()
    var ptDOB = String()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MM/dd/YYYY"
		currentDateView.stringValue = dateFormatter.string(from: Date())
        patientNameView.stringValue = ptName
        patientDOBView.stringValue = ptDOB
    }
	
	
    @IBAction func printLab(_ sender: Any) {
        var mcPrimary = String()
        if mcPrimaryMatrix.selectedCell()!.tag == 1 {
            mcPrimary = "YES"
        } else if mcPrimaryMatrix.selectedCell()!.tag == 0 {
            mcPrimary = "NO"
        }
        var addOn = String()
        if addOnResult == 1 {
            addOn = "— ADD ON LAB —"
        }
        
        let patientInfo = ("NAME:  \(patientNameView.stringValue)" + "\t\t" + "M/C PRIMARY:  \(mcPrimary)"
            + "\n"
            + "\(patientDOBView.stringValue)" + "\n\n"
            + addOn
            + "\n\n"
            + "DATE ORDERED:  \(currentDateView.stringValue)")
        let headerLabels = ("TEST" + "\t" + " - " + "\t" + "DX CODE")
        
        let labOrderOutputText = "\(headerInfo)" + "\n\n"
            + "\(patientInfo)" + "\n\n"
            + "\(headerLabels)" + "\n"
            + "\(labPrintVersion)" + "\n\n\n\n"
            + "Dawn Whelchel, MD" + "\n\n\n\n"
            + "\(labNoteVersion)"
        
        //Create a view to hold the final text so it can be passed to the NSPrintOperation
        let printView = NSTextView()
        //Set the size of the view or the text won't appear on the page
        printView.setFrameSize(NSSize(width: 680, height: 0))
        //Transfer the final string to the TextView's string property
        printView.string = labOrderOutputText
        //printView.sizeToFit()
        //print(printView.string)
        let printInfo = NSPrintInfo.shared
        //printInfo.orientation = .portrait
        //printInfo.verticalPagination = .autoPagination
        printInfo.leftMargin = 40
        //printInfo.rightMargin = 20
        //printInfo.isHorizontallyCentered = false
        printInfo.isVerticallyCentered = false
        //printInfo.topMargin = 0
        printInfo.bottomMargin = 40
        let operation: NSPrintOperation = NSPrintOperation(view: printView, printInfo: printInfo)
        operation.run()
        
        self.view.window?.close()
    }
	
}
