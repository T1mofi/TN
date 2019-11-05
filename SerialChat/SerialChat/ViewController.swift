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
    @IBOutlet weak var speedPopUpButton: NSPopUpButton!
    @IBOutlet weak var parityPopUpButton: NSPopUpButton!
    @IBOutlet weak var stopBitsPopUpButton: NSPopUpButton!
    @IBOutlet weak var byteSizePopUpButton: NSPopUpButton!
    
    
    // MARK: - Properies
    
    var isConnectedToPort = false
    let speeds = ["1200", "2400", "4800", "9600", "19200", "38400", "57600", "115200"]
    
    var isValidConnetionSettiongs: Bool {
        let byteSize = Float(byteSizePopUpButton.itemTitle(at: byteSizePopUpButton.indexOfSelectedItem))
        
        let stopBits = Float(stopBitsPopUpButton.itemTitle(at: stopBitsPopUpButton.indexOfSelectedItem))
        
        if (byteSize == 5) && (stopBits == 2) {
            return false
        }
        
        if ((byteSize == 6) || (byteSize == 7) || (byteSize == 8)) && (stopBits == 1.5) {
            return false
        }
        
        return true
    }
                
    
    //TODO: move to init()
    var serialPort:SerialPort = SerialPort(path: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speedPopUpButton.addItems(withTitles: speeds)
        speedPopUpButton.selectItem(at: 3)
    }
    
    // MARK: - IBOutlets
    
    @IBAction func connectButtonClicked(_ sender: Any) {
        if isConnectedToPort == true{
            disconnectFromPort()
        } else {
            guard connectToPort() == true else { return }
            
            //Run the serial port reading function in another thread
            DispatchQueue.global(qos: .userInteractive).async {
                self.backgroundRead()
            }

            //Run the serial port reading function in another thread
            DispatchQueue.global(qos: .userInteractive).async {
                self.waitForInput()
            }
            
            inputTextField.isEnabled = true
            isConnectedToPort = true
            connectButton.title = "Disconnect"
            debugTextView.stringValue = "Connected to port\n\n" + self.debugTextView.stringValue
            toggleConnectionSettingsButtonsEnabling()
        }
    }
    
    func disconnectFromPort() {
        serialPort.closePort()
        isConnectedToPort = false
        inputTextField.isEnabled = false
        connectButton.title = "Connect"
        debugTextView.stringValue = "Disconnected\n\n" + self.debugTextView.stringValue
        toggleConnectionSettingsButtonsEnabling()
    }
    
    func toggleConnectionSettingsButtonsEnabling() {
        portPopUpButton.isEnabled.toggle()
        speedPopUpButton.isEnabled.toggle()
        parityPopUpButton.isEnabled.toggle()
        stopBitsPopUpButton.isEnabled.toggle()
        byteSizePopUpButton.isEnabled.toggle()
    }
    
    func connectToPort() -> Bool {
        
        guard isValidConnetionSettiongs == true else {
            self.debugTextView.stringValue = "Cannot connect invalid connections settings\n\n" + self.debugTextView.stringValue
            return false
        }
        
        do {

            let portNumber = portPopUpButton.indexOfSelectedItem + 4
            
            let serialPortName = "/dev/ttys00" + String(portNumber)
            
            serialPort = SerialPort(path: serialPortName)
            
            // Open and congugurate serial port
            try serialPort.openPort()
            serialPort.setSettings(receiveRate: .baud9600,
                                   transmitRate: .baud9600,
                                   minimumBytesToRead: 1)

        } catch PortError.failedToOpen {
            self.debugTextView.stringValue = "Can't connect to serial port\n\n" + self.debugTextView.stringValue
        } catch {
            print("Error: \(error)")
        }
        
        return true
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
                        
                        // if there are new characters
                        if (currentInputText.count > tempInputText.count) {
                            
                            let range = currentInputText.index(currentInputText.startIndex, offsetBy: tempInputText.count)..<currentInputText.endIndex
                            let dff = currentInputText[range]
                            print(dff)
                            
                            for diff in dff {
                                
                                if (diff >= "а") && (diff <= "я") || (diff >= "А") && (diff <= "Я") {
                                    self.inputTextField.stringValue = tempInputText
                                    print("Russian sumbols did not support")
                                } else {
                                    do {
                                        print("will write \(diff)")
                                        var _ = try self.serialPort.writeChar(String(diff))
                                    } catch PortError.failedToOpen {
                                        print("Serial port failed to open. You might need root permissions.")
                                    } catch {
                                        print("Error: \(error)")
                                    }
                                }
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

