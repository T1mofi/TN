//
//  ViewController.swift
//  SerialChatUIThroughtCode
//
//  Created by Timofei Sikorski on 11/8/19.
//  Copyright © 2019 Sikorski. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {
    
    // MARK: - Views
    let rootStackView: NSStackView = {
        let stackView = NSStackView()

        stackView.orientation = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 20

        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()
    
    let inputView: NamedTextFieldView = {
        let namedTextField = NamedTextFieldView(named: "Input", placeholder: "Write text here")
        
        namedTextField.translatesAutoresizingMaskIntoConstraints = false
        
        namedTextField.textField.isEnabled = false
        
        return namedTextField
    }()
    
    let outputView: NamedTextFieldView = {
        let namedTextField = NamedTextFieldView(named: "Output", placeholder: "")
        
        namedTextField.textField.isSelectable = false
        
        namedTextField.translatesAutoresizingMaskIntoConstraints = false
        
        return namedTextField
    }()
    
    let debugView: DebugView = {
        let debugView = DebugView(named: "Debug", placeholder: "")
        
        debugView.textField.isSelectable = false
        
        debugView.translatesAutoresizingMaskIntoConstraints = false
        
        return debugView
    }()
    
    // MARK: - Properies
    var isConnectedToPort = false

    var isValidConnetionSettiongs: Bool {
        
        let byteSizePopUpButton = debugView.byteSizePropertyView.popUpButton
        let byteSize = Float(byteSizePopUpButton.itemTitle(at: byteSizePopUpButton.indexOfSelectedItem))
        
        let stopBitsPopUpButton = debugView.stopBitsPropertyView.popUpButton
        let stopBits = Float(stopBitsPopUpButton.itemTitle(at: stopBitsPopUpButton.indexOfSelectedItem))
        
        if (byteSize == 5) && (stopBits == 2) {
            return false
        }
        
        if ((byteSize == 6) || (byteSize == 7) || (byteSize == 8)) && (stopBits == 1.5) {
            return false
        }
        
        return true
    }
                
    var serialPort:SerialPort = SerialPort(path: "")
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.heightAnchor.constraint(equalToConstant: 600).isActive = true
        view.widthAnchor.constraint(equalToConstant: 450).isActive = true
        
        view.addSubview(rootStackView)
        
        autoLayoutRootStackView()
        
        rootStackView.addArrangedSubview(inputView)
        rootStackView.addArrangedSubview(outputView)
        rootStackView.addArrangedSubview(debugView)
                
        autoLayoutInputContainerView()
        autoLayoutOutputContainerView()
        autoLayoutDebugContainerView()
        
        
        // Set Actions
        debugView.connectButton.target = self
        debugView.connectButton.action = #selector(ViewController.connecttButtonClicked)
        
        inputView.textField.delegate = self
    }
    
    // MARK: - Actions
    @objc func connecttButtonClicked() {
        print("connectingVC")
        
        if isConnectedToPort == true{
            disconnectFromPort()
        } else {
            guard connectToPort() == true else { return }
            
            // TODO: Stop asyn tasks after disconnect
            
            //Run the serial port reading function in another thread
            DispatchQueue.global(qos: .userInteractive).async {
                self.backgroundRead()
            }

            //Run the serial port reading function in another thread
            DispatchQueue.global(qos: .userInteractive).async {
                self.waitForInput()
            }
        }
        
        updateUI()
    }
    
    // TextField delegate method
    func controlTextDidChange(_ obj: Notification) {
        print("controlTextDidChangeVC")
    }
    
    // MARK: - UI Configuration
    func updateUI(){
        if isConnectedToPort == true {
            inputView.textField.isEnabled = true
            debugView.connectButton.title = "Disconnect"
            debugView.textField.stringValue = "Connected to port\n\n" + self.debugView.textField.stringValue
            setConnectionSettingsButtonState(to: false)
        } else {
            inputView.textField.isEnabled = false
            debugView.connectButton.title = "Connect"
            debugView.textField.stringValue = "Disconnected\n\n" + self.debugView.textField.stringValue
            setConnectionSettingsButtonState(to: true)
        }
    }
    
    func setConnectionSettingsButtonState(to state:Bool) {
        debugView.portPropertyView.popUpButton.isEnabled = state
        debugView.speedPropertyView.popUpButton.isEnabled = state
        debugView.parityPropertyView.popUpButton.isEnabled = state
        debugView.stopBitsPropertyView.popUpButton.isEnabled = state
        debugView.byteSizePropertyView.popUpButton.isEnabled = state
    }
    
    // MARK: - Buisness logic
    func disconnectFromPort() {
        serialPort.closePort()
        isConnectedToPort = false
    }
    
    func connectToPort() -> Bool {
        
        guard isValidConnetionSettiongs == true else {
            self.debugView.textField.stringValue = "Cannot connect invalid connections settings\n\n" + self.debugView.textField.stringValue
            return false
        }
        
        do {
            let portNumber = debugView.portPropertyView.popUpButton.indexOfSelectedItem + 0
            
            let serialPortName = "/dev/ttys00" + String(portNumber)
            
            serialPort = SerialPort(path: serialPortName)
            
            // Open and congugurate serial port
            try serialPort.openPort()
            serialPort.setSettings(receiveRate: .baud9600, transmitRate: .baud9600, minimumBytesToRead: 1)
            
            isConnectedToPort = true
        } catch PortError.failedToOpen {
            self.debugView.textField.stringValue = "Can't connect to serial port\n\n" + self.debugView.textField.stringValue
        } catch {
            print("Error: \(error)")
        }
        
        return true
    }
    
    func waitForInput() {
        var inputTextString = ""
        var newInputTextString = ""
        
        DispatchQueue.main.sync {
            inputTextString = self.inputView.textField.stringValue
        }

        // Check for input in infinite loop
        while isConnectedToPort == true {
            DispatchQueue.main.sync {
                newInputTextString = self.inputView.textField.stringValue
            }

            // If user input char in middle of string
            let middleDifference = zip(inputTextString, newInputTextString).filter{ $0 != $1 }
            
            guard middleDifference.isEmpty else {
                DispatchQueue.main.sync {
                    self.inputView.textField.stringValue = inputTextString
                }
                continue
            }
        
            guard newInputTextString.count > inputTextString.count else {
                continue
            }
        
            // if there are new characters
            let differenceRange = newInputTextString.index(newInputTextString.startIndex, offsetBy: inputTextString.count)..<newInputTextString.endIndex
            let difference = newInputTextString[differenceRange]
            print(difference)
            
            for symbol in difference {
                guard !(symbol >= "а") && (symbol <= "я") && !(symbol >= "А") && (symbol <= "Я") else {
                    DispatchQueue.main.sync {
                        self.inputView.textField.stringValue = inputTextString
                    }
                    print("Russian sumbols did not support")
                    continue
                }
            
                do {
                    print("will write \(symbol)")
                    
                    // TODO: Use writeString
                    var _ = try self.serialPort.writeChar(String(symbol))
                } catch PortError.failedToOpen {
                    print("Serial port failed to open. You might need root permissions.")
                } catch {
                    print("Error: \(error)")
                }
            }

            inputTextString = newInputTextString
        }
    }
    
    func backgroundRead() {
        while isConnectedToPort == true {
            do{
                let readCharacter = try serialPort.readChar()
                DispatchQueue.main.async {
                    self.outputView.textField.stringValue += String(readCharacter)
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
    
    // MARK: - AutoLayout
    private func autoLayoutInputContainerView() {
        inputView.widthAnchor.constraint(equalTo: rootStackView.widthAnchor).isActive = true
    }
    
    private func autoLayoutOutputContainerView() {
        outputView.widthAnchor.constraint(equalTo: rootStackView.widthAnchor).isActive = true
    }
    
    private func autoLayoutDebugContainerView() {
        debugView.heightAnchor.constraint(equalToConstant: 280).isActive = true
        debugView.widthAnchor.constraint(equalTo: rootStackView.widthAnchor).isActive = true
    }
    
    fileprivate func extractedFunc() {
        rootStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20).isActive = true
        rootStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
    }
    
    private func autoLayoutRootStackView() {
        rootStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        rootStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20).isActive = true
        extractedFunc()
    }
}
