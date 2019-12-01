//
//  ConnectionPropertyView.swift
//  SerialChatUIThroughtCode
//
//  Created by Timofei Sikorski on 11/18/19.
//  Copyright © 2019 Sikorski. All rights reserved.
//

import Cocoa

class ConnectionPropertyView: NSView {
    var shouldSetupConstraints = true
    
    var containerStackView: NSStackView = {
        let stackView = NSStackView()
        
        stackView.orientation = .horizontal
        stackView.distribution = .fillEqually
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()

    var propertyNameLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Property name")
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    var popUpButton: NSPopUpButton = {
        let popUpButton = NSPopUpButton()
        
        popUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        return popUpButton
    }()
    
    init(named propertyName: String, propertys: [String]) {
        super.init(frame: CGRect.zero)
        
        propertyNameLabel.stringValue = propertyName
        popUpButton.addItems(withTitles: propertys)
        
        self.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(propertyNameLabel)
        containerStackView.addArrangedSubview(popUpButton)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func updateConstraints() {
        if shouldSetupConstraints == true {
            
            containerStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            containerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            
            propertyNameLabel.centerYAnchor.constraint(equalTo: popUpButton.centerYAnchor).isActive = true
            popUpButton.widthAnchor.constraint(equalToConstant: 100).isActive = true

            shouldSetupConstraints = false
        }

        super.updateConstraints()
    }
    
    override func draw(_ dirtyRect: NSRect) { super.draw(dirtyRect) }
}
