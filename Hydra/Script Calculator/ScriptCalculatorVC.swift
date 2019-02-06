//
//  ScriptCalculatorVC.swift
//  Script Calculator
//
//  Created by Fool on 3/21/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Cocoa

class ScriptCalculatorVC: NSViewController, NSTextFieldDelegate {

    
    @IBOutlet weak var lastFilledPicker: NSDatePicker!
    @IBOutlet weak var lastQtyView: NSTextField!
    @IBOutlet weak var daysFilledView: NSTextField!
    @IBOutlet weak var dosageView: NSTextField!
    @IBOutlet weak var timePerDayView: NSTextField!
    @IBOutlet weak var daysFillView: NSTextField!
    @IBOutlet weak var dueView: NSTextField!
    @IBOutlet weak var totalQtyView: NSTextField!
    @IBOutlet weak var lastTilView: NSTextField!
    
   
//    override func viewWillAppear() {
//        super.viewWillAppear()
//        self.lastFilledPicker.becomeFirstResponder()
//        self.lastFilledPicker.nextKeyView = self.lastQtyView
//        self.lastQtyView.nextKeyView = self.daysFilledView
//        self.daysFilledView.nextKeyView = self.dosageView
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        lastFilledPicker.dateValue = Date().addingDays(-30)!
        daysFilledView.stringValue = "30"
        daysFillView.stringValue = "30"
        daysFilledView.delegate = self
        daysFillView.delegate = self
        dosageView.delegate = self
        timePerDayView.delegate = self
        
    }
    
    func controlTextDidChange(_ obj: Notification) {
        calculate(self)
    }
    
    @IBAction func clearView(_ sender: Any) {
        self.view.clearControllers()
    }
    
    @IBAction func calculate(_ sender: Any) {
        if !daysFilledView.stringValue.isEmpty && !daysFillView.stringValue.isEmpty {
        guard let dueDate = lastFilledPicker.dateValue.addingDays(Int(daysFilledView.stringValue)!) else { return }
        dueView.stringValue = dueDate.shortDate()
        
        let totalQty = dosageView.integerValue * timePerDayView.integerValue * daysFillView.integerValue
        
        totalQtyView.stringValue = String(totalQty)
        
        
            print("Last fill: \(daysFilledView.stringValue)\nCurrent fill: \(daysFillView.stringValue)")
        lastTilView.stringValue = dueDate.addingDays(Int(daysFillView.stringValue)!)?.shortDate() ?? "Unable to calculate"
        }
    }
    
    
    
}
