//
//  JSONTableViewController.swift
//  SnapKitchen
//
//  Created by Graham Perks on 1/25/16.
//  Copyright © 2016 Snap Kitchen. All rights reserved.
//

import UIKit
import SwiftyJSON

public protocol JSONTableCellConfigurer {
    func configureInTableViewController(_ tableViewController: UITableViewController, cellDefinition: JSON)
}

extension String {
    // Swift class names are AppName.ClassName.
    // Prepend the app name with the given class name.
    func classFromClassName() -> AnyClass! {
        var appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
        appName = appName.replacingOccurrences(of: " ", with: "_", options: .literal, range: nil)
        return NSClassFromString("\(appName).\(self)")
    }
}

open class JSONTableViewController: UITableViewController {

    open var sections: JSON!
    var cellConfigurers = [String: JSONTableCellConfigurer]()

    //MARK:

    override open func viewDidLoad() {
        super.viewDidLoad()
    }

//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//    }
//
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//    }
//
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//    }
//
//    override func viewDidDisappear(animated: Bool) {
//        super.viewDidDisappear(animated)
//    }

    //MARK:

    open func setJSON(_ url:URL) {
        if let data = try? Data(contentsOf: url) {
            sections = try? JSON(data: data, options:.allowFragments)

            registerConfigurers()
        }
    }

    // Iterate through all the rows ensuring each cell's NIB and class is registered with the table
    open func registerConfigurers() {

        for section in sections.arrayValue {
            for row in section["rows"].arrayValue {
                if let rowClass = row["class"].string {
                    let clazz:AnyClass = rowClass.classFromClassName()
                    let reuseId = row["reuseId"].string ?? rowClass // use reuseId if one is provided
                    tableView.register(clazz, forCellReuseIdentifier: reuseId)
                }
                else if let rowNib = row["nib"].string {
                    let nib = UINib(nibName: rowNib, bundle: nil)
                    tableView.register(nib, forCellReuseIdentifier: rowNib)
                }
            }
        }
    }

    open func cellForIndexPath(_ indexPath : IndexPath) -> JSON {
        let section = sections.arrayValue[indexPath.section]
        let rows = section["rows"]
        let row = rows[indexPath.row]

        return row
    }

    @objc override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = cellForIndexPath(indexPath)

        if let action = row["action"].string {
            if action.hasSuffix("::") {
                perform(Selector(action), with: row.dictionaryObject!, with: indexPath)
            }
            else if action.hasSuffix(":") {
                perform(Selector(action), with: row.dictionaryObject!)
            }
            else {
                perform(Selector(action))
            }
        }
    }

    // MARK: - Table view data source

    @objc override open func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    @objc override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections.arrayValue[section]
        let rows = section["rows"]
        return rows.count
    }


    @objc override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = cellForIndexPath(indexPath)
        let reuseId = row["reuseId"].string ?? (row["class"].string ?? row["nib"].stringValue)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)

        // Configure the cell...

        if let configurer = cell as? JSONTableCellConfigurer {
            configurer.configureInTableViewController(self, cellDefinition: row)
        }

        return cell
    }


}
