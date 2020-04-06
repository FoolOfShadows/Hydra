//
//  criteriaViewController.swift
//  ScriptsFromPTVNs
//
//  Created by Fool on 2/8/18.
//  Copyright © 2018 Fulgent Wake. All rights reserved.
//

import Cocoa

//Controller for the initial view where the search parameters are set
class criteriaViewController: NSViewController {

	@IBOutlet weak var timeSelectorMatrix: NSMatrix!
	@IBOutlet weak var currentDate: NSTextField!
	@IBOutlet weak var onDate: NSDatePicker!
	@IBOutlet weak var afterDate: NSDatePicker!
	@IBOutlet weak var betweenStartDate: NSDatePicker!
	@IBOutlet weak var betweenEndDate: NSDatePicker!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
	
	var basePath = NSHomeDirectory()
	var selectorTag = Int()
	var chosenItems = [String]()
    var foundData = [VisitData]()
    var resultData = String()
	
    let disGroup = DispatchGroup()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let today = Date()
		let formatter = DateFormatter()
		formatter.dateFormat = "M/d/yy"
		currentDate.stringValue = formatter.string(from: today)
		onDate.dateValue = Date()
		afterDate.dateValue = Date()
		betweenStartDate.dateValue = Date()
		betweenEndDate.dateValue = Date()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        //This is where and how to give the window of a view
        //opened by a segue a title
        self.view.window?.title = "PTVN Scraper"
    }
	
	func processTheDirectory() -> [URL] {
        if let theSelectorTag = timeSelectorMatrix.selectedCell()?.tag {
            selectorTag = theSelectorTag
        }
		
		/*Addend the path to the WPCMSharedFiles folder for the office machines to create a default selection.
		This requires all the computers this code runs on to have a folder named WPCMSharedFiles
		in their home directory.*/
		var originFolderURL: URL
		switch selectorTag {
		case 0:
			originFolderURL = URL(fileURLWithPath: "\(basePath)/WPCMSharedFiles/zDoctor Review/06 Dummy Files")
		default:
			originFolderURL = URL(fileURLWithPath: "\(basePath)/WPCMSharedFiles/zDonna Review/01 PTVN Files")
		}
		
        //print("OriginFolder set to: \(originFolderURL)")
		return originFolderURL.getFilesInDirectoryWhereNameContains(["PTVN"])
	}
    
    
    func getFilesForDateSelection(_ selection:[URL]) -> [URL]? {
        var theResults = [URL]()
        //let theFileURLs = processTheDirectory()
        //print("The tag selected is \(selectorTag)")
        switch selectorTag {
        case 0:
            let today = Date()
            print(today)
            theResults = getFileNamesFrom(selection, forDate: (start: today, end: nil), status: .on)
        case 1:
            print(onDate.dateValue)
            theResults = getFileNamesFrom(selection, forDate: (start: onDate.dateValue, end: nil), status: .on)
        case 2:
            theResults = getFileNamesFrom(selection, forDate: (start: afterDate.dateValue, end: nil), status: .after)
            print("The chosen files are \(theResults)")
        case 3:
            theResults = getFileNamesFrom(selection, forDate: (start: betweenStartDate.dateValue, end: betweenEndDate.dateValue), status: .between)
        default:
            print("Find ended up in the default case")
            return nil
        }
        
        return theResults
    }
    
	
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        var theSender:SearchType
        if let button = sender as? NSButton {
            print("\n\nThe sending button is \(button.title)")
            switch button.title {
            case "Rx":
                theSender = .MEDS
            case "Ref":
                theSender = .REF
            case "Front":
                theSender = .FRONT
            case "FU":
                theSender = .FU
            default:
                theSender = .ALL
            }
            if segue.identifier! == "showReport" {
                //print("showReport segue activated")
                if let toViewController = segue.destinationController as? resultsViewController {
                    var results = [String]()
                    if self.chosenItems.isEmpty {
                        let processedFiles = processTheFiles(self.getFilesForDateSelection(processTheDirectory()), for: theSender)
                        print(processedFiles)
                        for file in processedFiles {
                            if !file.tasks.isEmpty && file.tasks != [""] {
                                print("Tasks for patient \(file.ptName) = \(file.tasks)\n\n\(file.reportOutput())")
                                results.append(file.reportOutput())
                            }
                        }
                        toViewController.results = results.joined(separator: "\n\n")
                        toViewController.requester = theSender.rawValue
                    } else {
                        toViewController.results = self.chosenItems.joined(separator: "\n\n")
                    }
                }
            } else if segue.identifier! == "showFU" {
                if let toViewController = segue.destinationController as? resultsViewController {
                    var results = [String]()
                    if self.chosenItems.isEmpty {
                        let processedFiles = processTheFiles(self.getFilesForDateSelection(processTheDirectory()), for: theSender)
                        for file in processedFiles {
                            if !file.tasks.isEmpty && file.tasks != [""] {
                                results.append(file.followupOutput())
                                
                            }
                        }
                        toViewController.results = results.joined(separator: "\n\n")
                        toViewController.requester = theSender.rawValue
                    } else {
                        toViewController.results = self.chosenItems.joined(separator: "\n\n")
                    }
                }
            }
            
            /*else if segue.identifier!.rawValue == "pick" {
                if let toViewController = segue.destinationController as? TaskPickerViewController {
                    let visitDataArray = processTheFiles(self.getFilesForDateSelection(<#[URL]#>), for: theSender)
                    toViewController.visitDataArray = visitDataArray
                }
            }*/
        }
    }

    
    @IBAction func clearChosenItems(_ sender: Any) {
		chosenItems = [String]()
	}
    
    func prepDataForSegue(_ sender:Any?, withSender theSender: SearchType, usingData data: [URL]) {
        var results = [String]()
        
        if self.chosenItems.isEmpty {
            let processedFiles = processTheFiles(self.getFilesForDateSelection(data), for: theSender)
            //print(processedFiles)
            for file in processedFiles {
                if !file.tasks.isEmpty && file.tasks != [""] {
                    //print("Tasks for patient \(file.ptName) = \(file.tasks)")
                    results.append(file.reportOutput())
                }
            }
        }
        if !results.isEmpty {
            resultData = results.joined(separator: "\n\n")
        }
        
    }
}
