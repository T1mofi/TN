//
//  DebugView.swift
//  SerialChatUIThroughtCode
//
//  Created by Timofei Sikorski on 11/17/19.
//  Copyright © 2019 Sikorski. All rights reserved.
//

import Cocoa

class DebugView: NSView, NSTextFieldDelegate {
    var shouldSetupConstraints = true
    
    var label: NSTextField = {
        let label = NSTextField(labelWithString: "Label name")
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    var textField: NSTextField = {
        let textField = NSTextField(string: "")
        
        textField.cell?.wraps = true
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    // Nuber of printed mesages to debug view
    var messageNumber = 0
    
    var optionsStackView: NSStackView = {
        let stackView = NSStackView()
        
        stackView.orientation = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    var connectButton: NSButton = {
        let button = NSButton()
        
        button.title = "Connect"
        button.bezelStyle = .rounded
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    var portPropertyView: ConnectionPropertyView = {
        let connectionPropertyView = ConnectionPropertyView(named: "Port", propertys: ["COM1", "COM2"])
        
        connectionPropertyView.translatesAutoresizingMaskIntoConstraints = false
        
        return connectionPropertyView
    }()
    
    var speedPropertyView: ConnectionPropertyView = {
        let connectionPropertyView = ConnectionPropertyView(named: "Speed", propertys: ["1200", "2400", "4800", "9600", "19200", "38400", "57600", "115200"])
        
        connectionPropertyView.popUpButton.selectItem(at: 3)
        
        connectionPropertyView.translatesAutoresizingMaskIntoConstraints = false
        
        return connectionPropertyView
    }()
    
    var parityPropertyView: ConnectionPropertyView = {
        let connectionPropertyView = ConnectionPropertyView(named: "Parity", propertys: ["no", "even", "odd", "mark", "space"])
        
        connectionPropertyView.translatesAutoresizingMaskIntoConstraints = false
        
        return connectionPropertyView
    }()
    
    var stopBitsPropertyView: ConnectionPropertyView = {
       let connectionPropertyView = ConnectionPropertyView(named: "Stop bits", propertys: ["1", "1.5", "2"])
       
       connectionPropertyView.translatesAutoresizingMaskIntoConstraints = false
       
       return connectionPropertyView
    }()
    
    var byteSizePropertyView: ConnectionPropertyView = {
       let connectionPropertyView = ConnectionPropertyView(named: "Byte size", propertys: ["5", "6", "7", "8"])
       
       connectionPropertyView.translatesAutoresizingMaskIntoConstraints = false
       
       return connectionPropertyView
    }()
    
    init(named labelText: String, placeholder: String) {
        super.init(frame: CGRect.zero)
        
        label.stringValue = labelText
        
        self.addSubview(label)
        self.addSubview(textField)
        self.addSubview(optionsStackView)
        
        optionsStackView.addArrangedSubview(connectButton)
        optionsStackView.addArrangedSubview(portPropertyView)
        optionsStackView.addArrangedSubview(speedPropertyView)
        optionsStackView.addArrangedSubview(parityPropertyView)
        optionsStackView.addArrangedSubview(stopBitsPropertyView)
        optionsStackView.addArrangedSubview(byteSizePropertyView)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func updateConstraints() {
        if shouldSetupConstraints == true {

            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 3).isActive = true
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 3).isActive = true
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 3).isActive = true

            textField.setContentHuggingPriority(.init(rawValue: 249), for: .vertical)
            textField.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            textField.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            
            optionsStackView.widthAnchor.constraint(equalToConstant: 180).isActive = true
            optionsStackView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5).isActive = true
            optionsStackView.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 20).isActive = true
            optionsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
            optionsStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
           
            connectButton.widthAnchor.constraint(equalTo: optionsStackView.widthAnchor, constant: -10).isActive = true
            
            shouldSetupConstraints = false
        }

        super.updateConstraints()
    }
    
    func print(message: String) {
        messageNumber += 1
        textField.stringValue = "\(messageNumber): " + message + "\n\n" + textField.stringValue
    }

    override func draw(_ dirtyRect: NSRect) { super.draw(dirtyRect) }
}
