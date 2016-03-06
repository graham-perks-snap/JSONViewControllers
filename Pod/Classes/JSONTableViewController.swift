//
//  JSONTableViewController.swift
//  SnapKitchen
//
//  Created by Graham Perks on 1/25/16.
//  Copyright © 2016 Snap Kitchen. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol JSONTableCellConfigurer {
    func configureInTableViewController(tableViewController: UITableViewController, cellDefinition: JSON)
}

extension String {
    // Swift class names are AppName.ClassName.
    // Prepend the app name with the given class name.
    func classFromClassName() -> AnyClass! {
        var appName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String
        appName = appName.stringByReplacingOccurrencesOfString(" ", withString: "_", options: .LiteralSearch, range: nil)
        return NSClassFromString("\(appName).\(self)")
    }
}

class JSONTableViewController: UITableViewController {

    var sections: JSON!
    var cellConfigurers = [String: JSONTableCellConfigurer]()

    //MARK:

    override func viewDidLoad() {
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

    func setJSON(url:NSURL) {
        if let data = NSData(contentsOfURL: url) {
            var error : NSError?
            sections = JSON(data: data, error: &error)
            if error != nil {
                print("Failed to read table definition \(error)")
                return
            }

            registerConfigurers()
        }
    }


    func registerConfigurers() {

        for section in sections.arrayValue {
            for row in section["rows"].arrayValue {
                if let rowClass = row["class"].string {
                    let clazz:AnyClass = rowClass.classFromClassName()
                    tableView.registerClass(clazz, forCellReuseIdentifier: rowClass)
                }
                else if let rowNib = row["nib"].string {
                    let nib = UINib(nibName: rowNib, bundle: nil)
                    tableView.registerNib(nib, forCellReuseIdentifier: rowNib)
                }
            }
        }
    }

    func cellForIndexPath(indexPath : NSIndexPath) -> JSON {
        let section = sections.arrayValue[indexPath.section]
        let rows = section["rows"]
        let row = rows[indexPath.row]

        return row
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = cellForIndexPath(indexPath)

        if let action = row["action"].string {
            if action.hasSuffix(":") {
                self.performSelector(Selector(action), withObject: row.dictionaryObject!)
            }
            else {
                self .performSelector(Selector(action))
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections.arrayValue[section]
        let rows = section["rows"]
        return rows.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let row = cellForIndexPath(indexPath)
        let reuseId = row["class"].string ?? row["nib"].stringValue
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseId, forIndexPath: indexPath)

        // Configure the cell...

        if let configurer = cell as? JSONTableCellConfigurer {
            configurer.configureInTableViewController(self, cellDefinition: row)
        }

        return cell
    }


}
