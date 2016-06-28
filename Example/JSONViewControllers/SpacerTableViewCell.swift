//
//  SpacerTableViewCell.swift
//  SnapKitchen
//
//  Created by Graham Perks on 3/11/16.
//  Copyright © 2016 Snap Kitchen. All rights reserved.
//

import UIKit
import SwiftyJSON
import JSONViewControllers


class SpacerTableViewCell: UITableViewCell, JSONTableCellConfigurer {

    var heightConstraint: NSLayoutConstraint?

    func configureInTableViewController(tableViewController: UITableViewController, cellDefinition json: JSON) {
        backgroundColor = UIColor.clearColor()
        selectionStyle = .None

        contentView.translatesAutoresizingMaskIntoConstraints = false

        // This is a simple row with no content; just a height.
        let height = CGFloat(json["height"].intValue)
        // Already got a constraint added to this row? (We must be re-using it)
        if let c = heightConstraint {
            // Update existing constraint
            c.constant = height
        }
        else {
            // Create new constraint.
            let hConstraint = contentView.heightAnchor.constraintEqualToConstant(height)
            NSLayoutConstraint.activateConstraints([hConstraint])
            heightConstraint = hConstraint
        }
    }
}

