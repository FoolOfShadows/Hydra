//
//  CurrentMedsController.swift
//  SampleCheckOutTab
//
//  Created by Fool on 8/16/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Cocoa

class PMCurrentMedsController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
	
	@IBOutlet weak var currentMedsTableView: NSTableView!
	
	var medicationsString = String()
	var medListArray = [String]()
	var chosenMeds = [String]()
	
	//let unwantedBits = ["(- = currently taking; x = not currently taking; ? = unsure)\n", "- Patient has no implantable device", "- Implantable devices"]
	
	weak var medReloadDelegate: scriptTableDelegate?
	
	

    override func viewDidLoad() {
        super.viewDidLoad()
		//medicationsString = cleanArray()
		medListArray = getArrayFrom(medicationsString)
		self.currentMedsTableView.reloadData()
    }
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return medListArray.count
	}
	
	func getArrayFrom(_ medsString:String) -> [String] {
		let returnArray = medsString.removeWhiteSpace().components(separatedBy: "\n").filter { $0 != "" && $0 != "  " && !$0.lowercased().starts(with: "stop") && !$0.lowercased().starts(with: "start")}
		//returnArray = returnArray.map { $0.replacingOccurrences(of: "- ", with: "") }
		print(returnArray)
		return returnArray
	}
	

	
	//Set up the tableview with the data from the medList array
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
		
		vw.textField?.stringValue = medListArray[row]
		
		return vw
	}
    
	
	
	@IBAction func getDataFromSelectedRow(_ sender:Any) {
		let currentRow = currentMedsTableView.row(for: sender as! NSView)

		if (sender as! NSButton).state == .on {
			chosenMeds.append(medListArray[currentRow])
		} else if (sender as! NSButton).state == .off {
			chosenMeds = chosenMeds.filter { $0 != medListArray[currentRow] }
		}
		//print(chosenMeds)
		
	}
	
	@IBAction func getDataFromSelectedRowsText(_ sender:Any) {
        let currentRow = currentMedsTableView.row(for: sender as! NSView)
        let currentCellView = currentMedsTableView.rowView(atRow: currentRow, makeIfNecessary: false)?.view(atColumn: 1) as! NSTableCellView
        guard let currentText = currentCellView.textField?.stringValue else { return }
        
        
        if (sender as! NSButton).state == .on {
            chosenMeds.append(currentText)
            //chosenMeds.append(medListArray[currentRow])
        } else if (sender as! NSButton).state == .off {
            chosenMeds = chosenMeds.filter { $0 != currentText}
            //chosenMeds = chosenMeds.filter { $0 != medListArray[currentRow] }
        }
		
		
	}
	
//    func cleanArray() -> String {
//        var results = medicationsString
//        for item in unwantedBits {
//            results = results.replacingOccurrences(of: item, with: "")
//        }
//        return results
//    }
	
	@IBAction func returnResults(_ sender:Any) {
		let firstVC = presentingViewController as! PhoneMessageVC
		firstVC.wantedMeds += chosenMeds
		medReloadDelegate?.currentMedsWillBeDismissed(sender: self)
		self.dismiss(self)
	}
}
