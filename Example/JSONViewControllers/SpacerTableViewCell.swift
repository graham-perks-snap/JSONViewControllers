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

    func configureInTableViewController(tableViewController: UITableViewController, cellDefinition json: JSON) {
        backgroundColor = UIColor.clearColor()
        selectionStyle = .None

        let height = CGFloat(json["height"].intValue)
        var hConstraint: NSLayoutConstraint
        if #available(iOS 9.0, *) {
            hConstraint = contentView.heightAnchor.constraintEqualToConstant(height)
        } else {
            // Fallback on earlier versions
            hConstraint = NSLayoutConstraint(item: contentView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: height)
        }
        NSLayoutConstraint.activateConstraints([hConstraint])
    }
}

