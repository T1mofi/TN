//
//  ViewController.swift
//  SerialChatUIThroughtCode
//
//  Created by Timofei Sikorski on 11/8/19.
//  Copyright © 2019 Sikorski. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
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
        
        namedTextField.textField.isEnabled = false
        
        namedTextField.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    var package: [UInt8] = []
    var packageSize = 7
    
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
        debugView.connectButton.action = #selector(ViewController.connectButtonClicked)
        
        inputView.textField.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

// MARK: - Private methods
fileprivate extension ViewController {
    func disconnectFromPort() {
        serialPort.closePort()
        isConnectedToPort = false
    }
    
    func connectToPort() -> Bool {
        
        guard isValidConnetionSettiongs == true else {
            self.debugView.print(message: "Cannot connect invalid connections settings")
            return false
        }
        
        do {
            let portNumber = debugView.portPropertyView.popUpButton.indexOfSelectedItem + 4
            
            let serialPortName = "/dev/ttys00" + String(portNumber)
            
            serialPort = SerialPort(path: serialPortName)
            
            // Open and congugurate serial port
            try serialPort.openPort()
            serialPort.setSettings(receiveRate: .baud9600, transmitRate: .baud9600, minimumBytesToRead: 1)
            
            isConnectedToPort = true
        } catch PortError.failedToOpen {
            debugView.print(message: "Can't connect to serial port")
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
                inputTextString = newInputTextString
                continue
            }
        
            // if there are new characters
            let differenceRange = newInputTextString.index(newInputTextString.startIndex, offsetBy: inputTextString.count)..<newInputTextString.endIndex
            let difference = newInputTextString[differenceRange]
            print("diff \(difference)")
            
            for symbol in difference {
                guard !(symbol >= "а") && (symbol <= "я") && !(symbol >= "А") && (symbol <= "Я") else {
                    DispatchQueue.main.sync {
                        self.inputView.textField.stringValue = inputTextString
                    }
                    continue
                }
            
                do {
                    // TODO: Use writeString
                    guard let ascii = symbol.asciiValue else {
                        continue
                    }
                    
                    print(ascii)
                        
                    package.append(ascii)

                    if package.count == packageSize {
                        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: packageSize)
                        buffer.initialize(from: &package, count: packageSize)
                            
                        var _ = try self.serialPort.writeBytes(from: buffer, size: packageSize)
                            
                        package = []
                            
                        print("package sended")
                    }
                    
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
            // TODO: - Read char
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: packageSize)
            do {
                guard try serialPort.readBytes(into: buffer, size: packageSize) >= 0 else {
                    continue
                }
            } catch {
                print("Error: \(error) after read")
            }
        
            var package: [UInt8] = []
            for index in 0..<packageSize {
                package.append(buffer[index])
            }
            
            DispatchQueue.main.async {
                for byte in package {
                    self.outputView.textField.stringValue += String(UnicodeScalar(byte))
                }
            }
        }
    }
}

// MARK: - NSTextFieldDelegate
extension ViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
//        print("controlTextDidChangeVC")
    }
}

// MARK: - Actions
extension ViewController {
    @objc func connectButtonClicked() {
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
}

// MARK: - UI Configuration
fileprivate extension ViewController {
    func updateUI(){
        if isConnectedToPort == true {
            inputView.textField.isEnabled = true
            debugView.connectButton.title = "Disconnect"
            debugView.print(message: "Connected to port")
            setConnectionSettingsButtonState(to: false)
        } else {
            inputView.textField.isEnabled = false
            debugView.connectButton.title = "Connect"
            debugView.print(message: "Disconnected")
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
}

// MARK: - AutoLayout
fileprivate extension ViewController {
    func autoLayoutInputContainerView() {
        inputView.widthAnchor.constraint(equalTo: rootStackView.widthAnchor).isActive = true
    }
    
    func autoLayoutOutputContainerView() {
        outputView.widthAnchor.constraint(equalTo: rootStackView.widthAnchor).isActive = true
    }
    
    func autoLayoutDebugContainerView() {
        debugView.heightAnchor.constraint(equalToConstant: 280).isActive = true
        debugView.widthAnchor.constraint(equalTo: rootStackView.widthAnchor).isActive = true
    }

    func autoLayoutRootStackView() {
        rootStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        rootStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20).isActive = true
        rootStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20).isActive = true
        rootStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
    }
}
