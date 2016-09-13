//
//  ButtonTableViewCell.swift
//  SnapKitchen
//
//  Created by Graham Perks on 3/10/16.
//  Copyright © 2016 Snap Kitchen. All rights reserved.
//

import UIKit
import SwiftyJSON
import JSONViewControllers


class ButtonTableViewCell: UITableViewCell, JSONTableCellConfigurer {

    @IBOutlet weak var button: UIButton!
    weak var tableViewController: UITableViewController?
    var action: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func didTapButton(_ sender: AnyObject) {
        let sel = Selector(action!)
        tableViewController?.perform(sel, with: self)
    }

    func configureInTableViewController(_ tableViewController: UITableViewController, cellDefinition json: JSON) {

        self.tableViewController = tableViewController
        action = json["action"].stringValue

        button.setTitle(json["title"].stringValue, forState: .Normal)

        if let color = json["textColor"].string {
            button.setTitleColor(UIColor(hexString:color), forState: .Normal)
        }
    }
}
