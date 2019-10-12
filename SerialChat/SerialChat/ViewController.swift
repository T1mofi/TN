//
//  ViewController.swift
//  SerialChat
//
//  Created by Timofei Sikorski on 10/10/19.
//  Copyright © 2019 SikorskiIT. All rights reserved.
//

import Cocoa
//import SwiftSerial // https://github.com/yeokm1/SwiftSerial.git

class ViewController: NSViewController {

    @IBOutlet weak var inputTextField: NSTextField!
    @IBOutlet weak var outputTextFiel: NSTextField!
    @IBOutlet weak var debugTextField: NSTextFieldCell!
    
    //TODO: move to init()
    var serialPort:SerialPort = SerialPort(path: "")
    
    //TODO: Delete before release
    @IBAction func inputTextFieldDidEdited(_ sender: Any) {
        outputTextFiel.stringValue = inputTextField.stringValue
    }
    
    @IBAction func ttysDidEdited(_ sender: Any) {
        let serialPortName = "/dev/ttys00" + debugTextField.stringValue
        serialPort = SerialPort(path: serialPortName)
        
        debugTextField.isEnabled = false
        
        //TODO: move to "when port is conected"
        inputTextField.isEnabled = true
        
        workWithPort()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                            
                            do {
                                var _ = try serialPort.writeChar(String(diff))
                            } catch PortError.failedToOpen {
                                print("Serial port failed to open. You might need root permissions.")
                            } catch {
                                print("Error: \(error)")
                            }
                        }
                        tempInputText = currentInputText
                    }
                    
                }
            }
            
        }
            
    }
    
    func backgroundRead() {
        while true{
            do{
                let readCharacter = try serialPort.readChar()
                self.outputTextFiel.stringValue += String(readCharacter)
            } catch {
                print("Error: \(error) after read")
            }
        }
    }
    
    func workWithPort() {
        
        do {

            print("Attempting to open port")
            try serialPort.openPort()
            print("Serial port opened successfully.")
            outputTextFiel.stringValue = "sussesful"
            defer {
//                serialPort.closePort()
//                print("Port Closed")
                print("defer")
            }

            serialPort.setSettings(receiveRate: .baud9600,
                                   transmitRate: .baud9600,
                                   minimumBytesToRead: 1)

//            //Turn off output buffering if not multiple threads will have problems printing
//            setbuf(stdout, nil);


            //Run the serial port reading function in another thread
            DispatchQueue.global(qos: .userInitiated).async {
                self.backgroundRead()
            }

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    self.waitForInput()
                } catch {
                    print("Error: \(error)")
                }
            }

        } catch PortError.failedToOpen {
            print("Serial port failed to open. You might need root permissions.")
        } catch {
            print("Error: \(error)")
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func viewDidDisappear() {
        print("view did dissaper")
        
        serialPort.closePort()
        print("Port Closed")
    }

}

