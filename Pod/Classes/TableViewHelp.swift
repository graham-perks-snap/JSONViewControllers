//
//  TableViewHelp.swift
//  SnapKitchen
//
//  Created by Graham Perks on 4/21/16.
//  Copyright © 2016 Snap Kitchen. All rights reserved.
//

import UIKit


extension String {
    // Swift class names are AppName.ClassName.
    // Prepend the app name with the given class name.
    func classFromClassName() -> AnyClass! {
        var appName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String
        appName = appName.stringByReplacingOccurrencesOfString(" ", withString: "_", options: .LiteralSearch, range: nil)
        return NSClassFromString("\(appName).\(self)")
    }
}


public protocol TableCellConfigurer {
    func configureIn(definition: TableRow, indexPath: NSIndexPath)
}

extension TableCellConfigurer {
    func configureIn(definition: TableRow, indexPath: NSIndexPath) {
        definition.configureIn(self, indexPath: indexPath)
    }
}

public enum TableRowSource {
    case Nib(String)
    case Class(String)
}

//MARK: Table Row

// Implement TableRow, add rows to sections to build the table
public protocol TableRow: class {
    // Need either a nib or a class to register with

    var source: TableRowSource {get}

    var reuseIdentifier: String { get }
    var height: CGFloat { get }
    var action: String? { get }

    func configureIn(cell: TableCellConfigurer, indexPath: NSIndexPath)
}

public protocol TableSection {
    var rows: [TableRow] { get set }
}

// A section with header or footer
public protocol TableSectionWithSupplementaryViews: TableSection {
    var headerHeight: CGFloat { get }
    func headerViewForTableView(tableView: UITableView) -> UIView?
}

// A regular section with no headers or footers
public class DefaultTableSection: TableSection {
    public var rows = [TableRow]()
}

// MARK: - Table view data source

public class TableViewDataSourceHelper: NSObject, UITableViewDataSource {
    public var sections = [TableSection]()

    // Iterate through all the rows ensuring each cell's NIB and class is registered with the table
    public func registerConfigurers(tableView: UITableView) {

        for section in sections {
            for row in section.rows {
                switch row.source {
                case .Nib(let nibName):
                    let nib = UINib(nibName: nibName, bundle: nil)
                    tableView.registerNib(nib, forCellReuseIdentifier: row.reuseIdentifier)
                case .Class(let className):
                    let clazz:AnyClass = className.classFromClassName()
                    tableView.registerClass(clazz, forCellReuseIdentifier: row.reuseIdentifier)
                }
            }
        }
    }

    /// Register nib with name identical to its reuse ID
    static public func registerNib(tableView: UITableView, name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: name)
    }


    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }


    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }


    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let row = section.rows[indexPath.row]

        let cell = tableView.dequeueReusableCellWithIdentifier(row.reuseIdentifier, forIndexPath: indexPath)

        if let configurer = cell as? TableCellConfigurer {
            configurer.configureIn(row, indexPath: indexPath)
        }

        return cell
    }

}

// MARK: - Table view delegate

public class TableViewDelegateHelper: NSObject, UITableViewDelegate {

    override init() { super.init() }

    init(actionTarget: NSObjectProtocol) {
        self.target = actionTarget
        super.init()
    }

    weak var target: NSObjectProtocol?

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dataSource = tableView.dataSource as! TableViewDataSourceHelper

        let section = dataSource.sections[indexPath.section]
        let row = section.rows[indexPath.row]

        if let action = row.action, t = target {
            t.performSelector(Selector(action), withObject: row)
        }
    }
}


public class TableViewDelegateVariableRowHeightHelper: TableViewDelegateHelper {
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let dataSource = tableView.dataSource as! TableViewDataSourceHelper

        let section = dataSource.sections[indexPath.section]
        let row = section.rows[indexPath.row]
        return row.height
    }
}

// Table with section header or footers
public class TableViewDelegateWithSupplementaryViewsHelper: TableViewDelegateVariableRowHeightHelper {

    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dataSource = tableView.dataSource as! TableViewDataSourceHelper
        let section = dataSource.sections[section] as! TableSectionWithSupplementaryViews
        return section.headerViewForTableView(tableView)
    }

    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let dataSource = tableView.dataSource as! TableViewDataSourceHelper
        let section = dataSource.sections[section] as! TableSectionWithSupplementaryViews
        return section.headerHeight
    }
}
