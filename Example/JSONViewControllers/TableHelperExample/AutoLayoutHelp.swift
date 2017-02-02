//
//  AutoLayoutHelp.swift
//  SnapKitchen
//
//  Created by Graham Perks on 10/17/16.
//  Copyright © 2016 Snap Kitchen. All rights reserved.
//

import UIKit



extension NSObject {

    /// Generates a dictionary of UIView property names -> properties
    /// Intended for use with NSLayoutConstraint.constraints(withVisualFormat:...)
    /// e.g. "captionLabel" -> captionLabel.
    func propertyViewBindings() -> [String: Any] {
        let views = dictionaryOfProperties()
        var children = [String: Any]()
        views.forEach {
            // Remove non-UIViews, and UIViews with no parent.
            if
                let v = $1 as? UIView,
                let _ = v.superview
            {
                // We're good. Property is a UIView & has a superview.
                children[$0] = v
            }
        }

        return children
    }

    /// Generates a dictionary of property names -> properties
    /// e.g. "captionLabel" -> captionLabel.
    private func dictionaryOfProperties() -> [String: Any] {
        var result = [String: Any]()
        let mirror = Mirror(reflecting: self)
        for case let(label?, value) in mirror.children {
            result[label] = value
        }
        return result
    }
}

