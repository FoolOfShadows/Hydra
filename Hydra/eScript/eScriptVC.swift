//
//  ViewController.swift
//  eScripts
//
//  Created by Fool on 9/7/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Cocoa

class eScriptVC: NSViewController {

	@IBOutlet var scriptText: NSTextView!
	
	var fileLabelName = String()
	var patientName = String()
	var _undoManager = UndoManager()
	override var undoManager: UndoManager? {
		return _undoManager
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        //scriptUndoManager = scriptText.undoManager
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "eScript"
    }

	@IBAction func processPFData(_ sender: Any) {
		
		//Get the clipboard to process
		let pasteBoard = NSPasteboard.general
		let theText = pasteBoard.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text"))
		
		//Get name and DOB
		guard let ptNameAgeDOB = nameAgeDOB(theText) else { return }
		patientName = ptNameAgeDOB.0.capitalized
		let ptPharmacy = ptNameAgeDOB.1
		let pharmWithLocation = checkPharmacyLocationFrom(ptPharmacy)
		let ptDOB = ptNameAgeDOB.2
		fileLabelName = getFileLabellingName(patientName)
		//print(fileLabelName)
		
		//Get script data
		let finalScriptData = getScriptDataFrom(theText)
        
        let processDate = Date()
        let processDateFormatter = DateFormatter()
        processDateFormatter.dateFormat = "MM/dd/yy"
        let processRequestDate = processDateFormatter.string(from: processDate)
		
		let theUserFont:NSFont = NSFont.systemFont(ofSize: 18)
		let fontAttributes = NSDictionary(object: theUserFont, forKey: NSAttributedString.Key.font as NSCopying)
		scriptText.typingAttributes = fontAttributes as! [NSAttributedString.Key : Any]
		scriptText.string = "MEDICATION REFILL REQUEST - \(processRequestDate)\n\n\(patientName)          DOB: \(ptDOB)\n\n\(pharmWithLocation)\n\(finalScriptData)\n\nRESPONSE:\n"
	}
	
	@IBAction func saveFile(_ sender: Any) {
		guard let fileTextData = scriptText.string.data(using: String.Encoding.utf8) else { return }
		saveExportDialogWithData(fileTextData, andFileExtension: ".txt")
	}
	
	
	func saveExportDialogWithData(_ data: Data, andFileExtension ext: String) {
		//Get the visit date
		let requestDate = Date()
		let labelDateFormatter = DateFormatter()
		labelDateFormatter.dateFormat = "yyMMdd"
		let labelRequestDate = labelDateFormatter.string(from: requestDate)
		
		let savePath = NSHomeDirectory()
		let saveLocation = "Sync/WPCMSharedFiles/zBertha Review/01 The Script Corral"
		
		let saveDialog = NSSavePanel()
		saveDialog.nameFieldStringValue = "\(fileLabelName) RXCOM \(labelRequestDate)"
		saveDialog.directoryURL = NSURL.fileURL(withPath: "\(savePath)/\(saveLocation)")
		saveDialog.begin(completionHandler: {(result: NSApplication.ModalResponse) -> Void in
			if result.rawValue == NSFileHandlingPanelOKButton {
				if let filePath = saveDialog.url {
					if let path = URL(string: String(describing: filePath) + ext) {
						do {
							try data.write(to: path, options: .withoutOverwriting)
						} catch {
							let alert = NSAlert()
							alert.messageText = "There is already a file with this name.\n Please choose a different name."
							alert.beginSheetModal(for: self.view.window!) { (NSModalResponse) -> Void in
								let returnCode = NSModalResponse
								print(returnCode)
							}
						}
					}
				}

			}})
	}
    
    @IBAction func addVisitDates(_ sender: Any) {
        //Get the clipboard to process
        let pasteBoard = NSPasteboard.general
        guard let theText = pasteBoard.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) else { return }
        
        var lastAppointment:String {return getLastAptInfoFrom(theText)}
        var nextAppointment:String {return getNextAptInfoFrom(theText)}
        
        let currentResults = scriptText.string
        let finalScriptData = currentResults.replacingOccurrences(of: "\n\nRESPONSE:", with: "\n\nLast Apt: \(lastAppointment)\nNext Apt: \(nextAppointment)")
        
        let theUserFont:NSFont = NSFont.systemFont(ofSize: 18)
        let fontAttributes = NSDictionary(object: theUserFont, forKey: NSAttributedString.Key.font as NSCopying)
        scriptText.typingAttributes = fontAttributes as! [NSAttributedString.Key : Any]
        //let count = Int(scriptText.string.count)
        //scriptText.shouldChangeText(in: NSMakeRange(0, count), replacementString: "\(finalScriptData)\n\nRESPONSE:\n")
        scriptText.string = "\(finalScriptData)\n\nRESPONSE:\n"
        scriptText.didChangeText()
        
    }
	
	@IBAction func addScript(_ sender: Any) {
		
		//Get the clipboard to process
		let pasteBoard = NSPasteboard.general
		let theText = pasteBoard.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text"))
		
		let currentResults = scriptText.string
		
		guard let ptNameAgeDOB = nameAgeDOB(theText) else { return }
		/*if ptNameAgeDOB.0.capitalized != patientName*/
        let newNameComponents = Set(ptNameAgeDOB.0.capitalized.components(separatedBy: " "))
        let oldNameComponents = Set(patientName.components(separatedBy: " "))
        //print("New Set: \(newNameComponents)\nOldSet: \(oldNameComponents)\n\(newNameComponents.isSubset(of: oldNameComponents))\n\(oldNameComponents.isSubset(of: newNameComponents))")
        
        if !newNameComponents.isSubset(of: oldNameComponents) && !oldNameComponents.isSubset(of: newNameComponents) {
            //print("\(ptNameAgeDOB.0.capitalized) :: \(patientName)")
			//After notifying the user, break out of the program
			let theAlert = NSAlert()
			theAlert.messageText = "The refill information you're trying to add is for \(ptNameAgeDOB.0.capitalized) rather than \(patientName)."
			theAlert.beginSheetModal(for: NSApplication.shared.mainWindow!) { (NSModalResponse) -> Void in
				let returnCode = NSModalResponse
				print(returnCode)
			}
			return
		}
		
		//Get script data
		var finalScriptData = "\n\n\(ptNameAgeDOB.1)\n\(getScriptDataFrom(theText))"
        //print(finalScriptData)
		
		finalScriptData = currentResults.replacingOccurrences(of: "\n\nRESPONSE:", with: finalScriptData)
		
		let theUserFont:NSFont = NSFont.systemFont(ofSize: 18)
		let fontAttributes = NSDictionary(object: theUserFont, forKey: NSAttributedString.Key.font as NSCopying)
		scriptText.typingAttributes = fontAttributes as! [NSAttributedString.Key : Any]
		let count = Int(scriptText.string.count)
		scriptText.shouldChangeText(in: NSMakeRange(0, count), replacementString: "\(finalScriptData)\n\nRESPONSE:\n")
		scriptText.string = "\(finalScriptData)\n\nRESPONSE:\n"
		scriptText.didChangeText()

	}
	
	func registerUndoAddScript(_ previous:String) {
		undoManager?.prepare(withInvocationTarget: self.addScript(self))
		undoManager?.setActionName("Add Script")
	}
	
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

