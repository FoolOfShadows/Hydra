//
//  resultsViewController.swift
//  ScriptsFromPTVNs
//
//  Created by Fool on 2/8/18.
//  Copyright © 2018 Fulgent Wake. All rights reserved.
//

import Cocoa

class resultsViewController: NSViewController {
	@IBOutlet var resultsView: NSTextView!
	var results = String()
    var requester = String()
	
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        
		
		let theUserFont:NSFont = NSFont.systemFont(ofSize: 18)
		let fontAttributes = NSDictionary(object: theUserFont, forKey: kCTFontAttributeName as! NSCopying)
        resultsView.typingAttributes = fontAttributes as! [NSAttributedString.Key : Any]
		resultsView.string = "NEEDED \(requester)  (\(formatter.string(from: today)))\n\(results)"
    }
    
}
