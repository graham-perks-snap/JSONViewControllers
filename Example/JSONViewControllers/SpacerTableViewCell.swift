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

    func configureInTableViewController(_ tableViewController: UITableViewController, cellDefinition json: JSON) {
        backgroundColor = UIColor.clear
        selectionStyle = .none

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
            var hConstraint: NSLayoutConstraint
            if #available(iOS 9.0, *) {
                hConstraint = contentView.heightAnchor.constraint(equalToConstant: height)
            } else {
                // Fallback on earlier versions
                hConstraint = NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
            }
            NSLayoutConstraint.activate([hConstraint])
            heightConstraint = hConstraint
        }
    }
}

