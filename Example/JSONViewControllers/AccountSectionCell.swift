//
//  AccountSectionCell.swift
//  SnapKitchen
//
//  Created by Graham Perks on 3/10/16.
//  Copyright © 2016 Snap Kitchen. All rights reserved.
//

import UIKit
import SwiftyJSON
import JSONViewControllers


class AccountSectionCell: UITableViewCell, JSONTableCellConfigurer {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var backdropView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.backgroundColor = UIColor.clearColor()
        backgroundColor = UIColor.clearColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {

    }

    func configureInTableViewController(tableViewController: UITableViewController, cellDefinition json: JSON) {
        backdropView.layer.cornerRadius = 10
        backdropView.layer.shadowOffset = CGSize(width: 0, height: 2)
        backdropView.layer.shadowOpacity = 0.1

        let image = UIImage(named: json["image"].stringValue)
        iconImage.image = image

        captionLabel.text = json["caption"].stringValue
        actionLabel.text = json["actionText"].stringValue

        let nameKeyPath = json["nameTextKeyPath"].stringValue
        let name = tableViewController.valueForKeyPath(nameKeyPath) as! String
        nameLabel.text = name
    }

}
