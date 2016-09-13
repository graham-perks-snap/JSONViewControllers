//
//  TitleTableViewCell.swift
//  SnapKitchen
//
//  Created by Graham Perks on 2/8/16.
//  Copyright © 2016 Snap Kitchen. All rights reserved.
//

import UIKit
import SwiftyJSON
import JSONViewControllers


class TitleTableViewCell: UITableViewCell, JSONTableCellConfigurer {

    @IBOutlet weak var captionLabel: UILabel!

    func configureInTableViewController(_ tableViewController: UITableViewController, cellDefinition: JSON) {

        backgroundColor = UIColor.clear

        // Pull the caption from the JSON
        let caption = cellDefinition["heading"].stringValue
        self.captionLabel.text = caption
    }


}
