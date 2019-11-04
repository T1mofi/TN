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
    
    // MARK: - IBOutlets

    @IBOutlet weak var inputTextField: NSTextField!
    @IBOutlet weak var outputTextField: NSTextField!
    @IBOutlet weak var debugTextView: NSTextField!
    
    @IBOutlet weak var connectButton: NSButton!
    
    @IBOutlet weak var portPopUpButton: NSPopUpButton!
    
    // MARK: - Properys
    
    var isConnectedToPort = false
    
    //TODO: move to init()
    var serialPort:SerialPort = SerialPort(path: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBOutlets
    
    @IBAction func connectButtonClicked(_ sender: Any) {
        if isConnectedToPort == true{
            disconnectFromPort()
        } else {
            workWithPort()
        }
    }
    
    override func viewWillDisappear() {
//        self.serialPort.closePort()
//        print("Port should close")
    }
    
    func disconnectFromPort() {
        serialPort.closePort()
        isConnectedToPort = false
        inputTextField.isEnabled = false
        connectButton.title = "Connect"
        debugTextView.stringValue = "Disconnected\n\n" + self.debugTextView.stringValue
    }
    
    func workWithPort() {
        
        let portNumber = portPopUpButton.indexOfSelectedItem + 1
        
        let serialPortName = "/dev/ttys00" + String(portNumber)
        
        do {
            
            serialPort = SerialPort(path: serialPortName)
            
            print("Attempting to open port")
            try serialPort.openPort()
            serialPort.setSettings(receiveRate: .baud9600,
                                   transmitRate: .baud9600,
                                   minimumBytesToRead: 1)
            
            inputTextField.isEnabled = true
            isConnectedToPort = true
            connectButton.title = "Disconnect"
            debugTextView.stringValue = "Connected to port\n\n" + self.debugTextView.stringValue
            
            

            //Run the serial port reading function in another thread
            DispatchQueue.global(qos: .userInteractive).async {
                self.backgroundRead()
            }

            //Run the serial port reading function in another thread
            DispatchQueue.global(qos: .userInteractive).async {
                self.waitForInput()
            }

        } catch PortError.failedToOpen {
            print("Serial port failed to open. You might need root permissions.")
            DispatchQueue.main.async {
                self.debugTextView.stringValue = "Cannot connect to serial port\n\n" + self.debugTextView.stringValue
            }
        } catch {
            print("Error: \(error)")
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

                            do {
                                print("will write \(diff)")
                                var _ = try self.serialPort.writeChar(String(diff))
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
                DispatchQueue.main.async {
                    self.outputTextField.stringValue += String(readCharacter)
                }
            } catch {
                print("Error: \(error) after read")
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

