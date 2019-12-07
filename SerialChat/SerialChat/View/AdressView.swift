//
//  AdressView.swift
//  SerialChat
//
//  Created by Timofei Sikorski on 12/7/19.
//  Copyright © 2019 SikorskiIT. All rights reserved.
//

import Cocoa

class AdressView: NSView {
    var shouldSetupConstraints = true
    
    var containerStackView: NSStackView = {
        let stackView = NSStackView()
        
        stackView.orientation = .horizontal
        stackView.spacing = 10
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()

    var propertyNameLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Adresses")
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let sourceAddressInputView: NSTextField = {
        var textField = NSTextField(string: "")
        
        textField.placeholderString = "S"
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    let destinationAddressInputView: NSTextField = {
        var textField = NSTextField(string: "")
        
        textField.placeholderString = "D"

        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        
        self.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(propertyNameLabel)
        containerStackView.addArrangedSubview(sourceAddressInputView)
        containerStackView.addArrangedSubview(destinationAddressInputView)
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
            
            sourceAddressInputView.widthAnchor.constraint(equalToConstant: 45).isActive = true
            destinationAddressInputView.widthAnchor.constraint(equalToConstant: 45).isActive = true
            
            propertyNameLabel.setContentHuggingPriority(.init(rawValue: 249), for: .horizontal)
            
            shouldSetupConstraints = false
        }

        super.updateConstraints()
    }
    
    override func draw(_ dirtyRect: NSRect) { super.draw(dirtyRect) }
}
