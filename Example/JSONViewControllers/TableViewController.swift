//
//  TableViewController.swift
//  JSONViewControllers
//
//  Created by Graham Perks on 03/06/2016.
//  Copyright (c) 2016 Graham Perks. All rights reserved.
//

import UIKit
import SwiftyJSON
import JSONViewControllers


class TableViewController: JSONTableViewController {

    @objc var user = User()  // Our table cells can use KVC to access fields marked as @objc.

    override func viewDidLoad() {
        super.viewDidLoad()

        user.name = "Graham Perks"

        let url = Bundle.main.url(forResource: "AccountTable", withExtension: "json")!
        setJSON(url)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }


}

