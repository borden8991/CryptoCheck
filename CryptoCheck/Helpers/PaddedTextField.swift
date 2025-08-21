//
//  PaddedTextField.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 21.08.2025.
//

import UIKit

final class PaddedTextField: UITextField {
    
    var textInsets: UIEdgeInsets = .zero {
        didSet { setNeedsDisplay() }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
}

