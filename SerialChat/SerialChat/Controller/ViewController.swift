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
        
        
        // TODO: - Validate value of adresses
        guard debugView.adressView.sourceAddressInputView.stringValue.isEmpty == false else {
            return false
        }
        
        guard debugView.adressView.destinationAddressInputView.stringValue.isEmpty == false else {
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
            let portNumber = debugView.portPropertyView.popUpButton.indexOfSelectedItem + 3
            
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
    
    func getValidDifference(oldStr: String, newStr: String) -> String {
        let middleDifference = zip(oldStr, newStr).filter{ $0 != $1 }
        
        guard middleDifference.isEmpty else {
            return ""
        }
    
        guard newStr.count > oldStr.count else {
            return ""
        }
    
        // if there are new characters
        var difference = newStr
        difference.removeFirst(oldStr.count)
        
        var validDifference = ""
        
        for symbol in difference {
            guard let _ = symbol.asciiValue else {
                continue
            }
            
            validDifference.append(symbol)
        }
        
        return validDifference
    }
    
    func backgroundRead() {
        while isConnectedToPort == true {
            // TODO: - Read char
            do {
                var binaryString = try serialPort.readLine()
                binaryString.removeFirst(8)
                
                var unstuffedBinaryString = binaryString.unstuffed
                
                var bytes = unstuffedBinaryString.getBytesRepresentation()
                
                let sourceAdress = bytes.removeFirst()
                
                DispatchQueue.main.sync {
                    debugView.textField.stringValue += "\nsourceAdress - \(sourceAdress)"
                }
                
                let destinationAdress = bytes.removeFirst()
                
                DispatchQueue.main.sync {
                    debugView.textField.stringValue += "\ndestinationAdress - \(destinationAdress)"
                }
                
                let checkSum = bytes.removeLast()
                
                DispatchQueue.main.sync {
                    debugView.textField.stringValue += "\ncheckSum - \(checkSum)"
                }
    
                for byte in bytes {
                    DispatchQueue.main.sync {
                        outputView.textField.stringValue += String(UnicodeScalar(byte))
                    }
                }
            } catch {
                print("Error: \(error) after read")
            }
            
            sleep(1)
        }
    }
}

var inputTextString = ""
var newInputTextString = ""

var dataBits: [UInt8] = []
let dataBitsSize = 7

// MARK: - NSTextFieldDelegate
extension ViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        newInputTextString = self.inputView.textField.stringValue
        
        let difference = getValidDifference(oldStr: inputTextString, newStr: newInputTextString)
        
        inputTextString += difference
        inputView.textField.stringValue = inputTextString

        for symbol in difference {
            do {
                // TODO: Use writeString
                let ascii = symbol.asciiValue!
                
                dataBits.append(ascii)

                if dataBits.count == dataBitsSize {
                    defer {
                        dataBits = []
                    }
                    
                    var package = ""
                    
                    let sourceAdress = UInt8(debugView.adressView.sourceAddressInputView.stringValue)!
                    let destinationAdress = UInt8(debugView.adressView.destinationAddressInputView.stringValue)!
                    
                    package += sourceAdress.binaryRepresentation
                    package += destinationAdress.binaryRepresentation
                    
                    for byte in dataBits {
                        package += byte.binaryRepresentation
                    }
                    
                    let error: Bool = true
                    var checkSum: UInt8 = 0
                    if error == true {
                        checkSum = 1
                    }
                    
                    package += checkSum.binaryRepresentation
                    
                    package = package.stuffed
                    
                    let startByte: UInt8 = 14
                    package = startByte.binaryRepresentation + package

                    var packageWithZeros = package
                    if (package.count % 8) != 0 {
                        packageWithZeros = package + String(repeating: "0", count: 8 - (package.count % 8))
                    }
                    
                    let bytes = packageWithZeros.getBytesRepresentation()
                    
                    var hexValuesString = ""
                    
                    for byte in bytes {
                        hexValuesString += byte.hexRepresentation + " "
                        if hexValuesString.count == 18 {
                            hexValuesString += "\n"
                        }
                    }
                    
                    debugView.print(message: "Stuffed package\n" + hexValuesString)
                    
                    let _ = try self.serialPort.writeString(package + "\n")
                }
            } catch PortError.failedToOpen {
                print("Serial port failed to open. You might need root permissions.")
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

// MARK: - Actions
extension ViewController {
    @objc func connectButtonClicked() {
        if isConnectedToPort == true{
            disconnectFromPort()
        } else {
            guard connectToPort() == true else { return }

            //Run the serial port reading function in another thread
            DispatchQueue.global(qos: .userInteractive).async {
                self.backgroundRead()
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
        debugView.adressView.sourceAddressInputView.isEnabled = state
        debugView.adressView.destinationAddressInputView.isEnabled = state
        debugView.portPropertyView.popUpButton.isEnabled = state
        debugView.speedPropertyView.popUpButton.isEnabled = state
        debugView.parityPropertyView.popUpButton.isEnabled = state
        debugView.stopBitsPropertyView.popUpButton.isEnabled = state
        debugView.byteSizePropertyView.popUpButton.isEnabled = state
        debugView.errorCheckBox.isEnabled = state
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
        debugView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        debugView.widthAnchor.constraint(equalTo: rootStackView.widthAnchor).isActive = true
    }

    func autoLayoutRootStackView() {
        rootStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        rootStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20).isActive = true
        rootStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20).isActive = true
        rootStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
    }
}
