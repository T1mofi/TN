//
//  ViewController.swift
//  SerialChat
//
//  Created by Timofei Sikorski on 10/10/19.
//  Copyright © 2019 SikorskiIT. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var inputTextField: NSTextField!
    @IBOutlet weak var outputTextFiels: NSTextField!
    
    @IBAction func inputTextFieldDidEdited(_ sender: Any) {
        outputTextFiels.stringValue = inputTextField.stringValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.waitForInput()
        }
        
    }
    
    func waitForInput() {
        
        var tempInputText = self.inputTextField.stringValue
        
        // Check for input in infinite loop
        while true {
            
            DispatchQueue.main.sync {
                let currentInputText = self.inputTextField.stringValue
                
                // If user input char in middle of string
                let difference = zip(tempInputText, currentInputText).filter{ $0 != $1 }
                if !difference.isEmpty {
                    self.inputTextField.stringValue = tempInputText
                } else {
                
                    if (tempInputText != currentInputText) {
                        if (currentInputText.count > tempInputText.count) {
                            let diff = currentInputText[currentInputText.index(before: currentInputText.endIndex)]
                            
                            self.outputTextFiels.stringValue += String(diff)
                        }
                        tempInputText = currentInputText
                    }
                    
                }
            }
            
        }
            
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

