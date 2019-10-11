//
//  ViewController.swift
//  SerialChat
//
//  Created by Timofei Sikorski on 10/10/19.
//  Copyright © 2019 SikorskiIT. All rights reserved.
//

import Cocoa
import SwiftSerial // https://github.com/yeokm1/SwiftSerial.git

class ViewController: NSViewController {

    @IBOutlet weak var inputTextField: NSTextField!
    @IBOutlet weak var outputTextFiel: NSTextField!
    @IBOutlet weak var debugTextField: NSTextFieldCell!
    
    //TODO: move to init()
    var serialPort:SerialPort = SerialPort(path: "ttys")
    
    //TODO: Delete before release
    @IBAction func inputTextFieldDidEdited(_ sender: Any) {
        outputTextFiel.stringValue = inputTextField.stringValue
    }
    
    @IBAction func ttysDidEdited(_ sender: Any) {
        let serialPortName = debugTextField.stringValue
        serialPort = SerialPort(path: "/dev/ttys002")
        
//        //DEBUG: debug
//        var arguments = CommandLine.arguments
//        arguments.append("/dev/ttys002")
//        guard arguments.count >= 2 else {
//            print("Need serial port name like  /dev/tty001 as the first argument.")
//            exit(1)
//        }
//        print("Connect to both serial ports before you continue to use this program")
//        let portName = arguments[1]
//        serialPort = SerialPort(path: portName)
//
//        do {
//
//            print("Attempting to open port: \(portName)")
//            try serialPort.openPort()
//            print("Serial port \(portName) opened successfully.")
//            defer {
//                serialPort.closePort()
//                print("Port Closed")
//            }
//
//        } catch PortError.failedToOpen {
//            print("Serial port \(portName) failed to open. You might need root permissions.")
//        } catch {
//            print("Error: \(error)")
//        }
        
        
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
                            
//                            self.outputTextFiel.stringValue += String(diff)
                            var _ = try serialPort.writeChar
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
            } catch {
                print("Error: \(error)")
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
                serialPort.closePort()
                print("Port Closed")
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
//                    var _ = try serialPort.writeChar(enteredKey)
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


}

