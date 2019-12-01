//
//  namedTextField.swift
//  SerialChatUIThroughtCode
//
//  Created by Timofei Sikorski on 11/16/19.
//  Copyright © 2019 Sikorski. All rights reserved.
//

import Cocoa

class NamedTextFieldView: NSView {
    var shouldSetupConstraints = true

    var label = NSTextField(labelWithString: "Label name")
    var textField = NSTextField(wrappingLabelWithString: "")
    
    init(named labelText: String, placeholder: String) {
        super.init(frame: CGRect.zero)
        
        label.stringValue = labelText
        textField.placeholderString = placeholder
        
        textField.isEditable = true
        textField.wantsLayer = true
        textField.layer?.backgroundColor = .init(gray: 0.18, alpha: 1)

        self.addSubview(label)
        self.addSubview(textField)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func updateConstraints() {
        if shouldSetupConstraints == true {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 3).isActive = true
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 3).isActive = true
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 3).isActive = true

            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.setContentHuggingPriority(.init(rawValue: 249), for: .vertical)
            textField.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            textField.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            textField.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

            shouldSetupConstraints = false
        }

        super.updateConstraints()
    }

    override func draw(_ dirtyRect: NSRect) { super.draw(dirtyRect) }
}
