//
//  TableHelperViewController.swift
//  JSONViewControllers
//
//  Created by Graham Perks on 6/28/16.
//  Copyright © 2016 Snap Kitchen. All rights reserved.
//

import UIKit
import JSONViewControllers


class TableHelperViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var dataSource: TableViewDataSourceHelper!
    var section = DefaultTableSection()
    var tableViewDelegate: TableViewDelegateHelper!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewDelegate = TableViewDelegateHelper(actionTarget: self)
        tableView.delegate = tableViewDelegate
        dataSource = TableViewDataSourceHelper()
        tableView.dataSource = dataSource
        tableView.rowHeight = UIScreen.mainScreen().bounds.height <= 568 ? 46 : 66

        dataSource.sections = [section]

        addCategories()
        dataSource.registerConfigurers(tableView)
        tableView.reloadData()

    }


    private func addCategories() {
//        for c in categories {
//            let row = CategoryRow(category: c)
//            section.rows.append(row)
//        }
    }
}