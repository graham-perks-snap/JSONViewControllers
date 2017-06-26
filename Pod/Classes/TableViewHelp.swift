//
//  TableViewHelp.swift
//  SnapKitchen
//
//  Created by Graham Perks on 4/21/16.
//  Copyright © 2016 Snap Kitchen. All rights reserved.
//

import UIKit


public protocol TableCellConfigurer {
    func configureIn(_ definition: TableRow, indexPath: IndexPath)
}

public extension TableCellConfigurer {
    public func configureIn(_ definition: TableRow, indexPath: IndexPath) {
        definition.configureIn(self, indexPath: indexPath)
    }
}

public enum TableRowSource {
    case nib(String)
    case `class`(String)
    case prototype
}

//MARK: Table Row

// Implement TableRow, add rows to sections to build the table
public protocol TableRow: class {
    // Need either a nib or a class to register with

    var source: TableRowSource {get}

    var reuseIdentifier: String { get }
    var height: CGFloat { get }
    var action: String? { get }

    func configureIn(_ cell: TableCellConfigurer, indexPath: IndexPath)
}

public protocol TableSection {
    var rows: [TableRow] { get set }
}

// A section with header or footer
public protocol TableSectionWithSupplementaryViews: TableSection {
    var headerHeight: CGFloat { get }
    func headerViewForTableView(_ tableView: UITableView) -> UIView?
}

// A regular section with no headers or footers
open class DefaultTableSection: TableSection {
    open var rows = [TableRow]()
    public init() {}
}

// MARK: - Table view data source

open class TableViewDataSourceHelper: NSObject, UITableViewDataSource {
    open var sections = [TableSection]()

    // Iterate through all the rows ensuring each cell's NIB and class is registered with the table
    open func registerConfigurers(_ tableView: UITableView) {

        for section in sections {
            for row in section.rows {
                switch row.source {
                case .nib(let nibName):
                    let nib = UINib(nibName: nibName, bundle: nil)
                    tableView.register(nib, forCellReuseIdentifier: row.reuseIdentifier)
                case .class(let className):
                    let clazz:AnyClass = className.classFromClassName()
                    tableView.register(clazz, forCellReuseIdentifier: row.reuseIdentifier)
                case .prototype:
                    // Prototype cells are registered by storyboard loader. 
                    break
                }

            }
        }
    }

    /// Register nib with name identical to its reuse ID
    static open func registerNib(_ tableView: UITableView, name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }


    open func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }


    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }


    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[(indexPath as NSIndexPath).section]
        let row = section.rows[(indexPath as NSIndexPath).row]

        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)

        if let configurer = cell as? TableCellConfigurer {
            configurer.configureIn(row, indexPath: indexPath)
        }

        return cell
    }

}

// MARK: - Table view delegate

open class TableViewDelegateHelper: NSObject, UITableViewDelegate {

    public init(actionTarget: NSObjectProtocol) {
        self.target = actionTarget
        super.init()
    }

    public weak var target: NSObjectProtocol?

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataSource = tableView.dataSource as! TableViewDataSourceHelper

        let section = dataSource.sections[(indexPath as NSIndexPath).section]
        let row = section.rows[(indexPath as NSIndexPath).row]

        if let action = row.action, let target = target {
            if action.hasSuffix("::") {
                target.perform(Selector(action), with: row, with: indexPath)
            }
            else {
                target.perform(Selector(action), with: row)
            }
        }
    }
}


open class TableViewDelegateVariableRowHeightHelper: TableViewDelegateHelper {
    public override init(actionTarget: NSObjectProtocol) {
        super.init(actionTarget: actionTarget)
    }

    open func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        let dataSource = tableView.dataSource as! TableViewDataSourceHelper

        let section = dataSource.sections[(indexPath as NSIndexPath).section]
        let row = section.rows[(indexPath as NSIndexPath).row]
        return row.height
    }
}

// Table with section header or footers
open class TableViewDelegateWithSupplementaryViewsHelper: TableViewDelegateVariableRowHeightHelper {

    public override init(actionTarget: NSObjectProtocol) {
        super.init(actionTarget: actionTarget)
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dataSource = tableView.dataSource as! TableViewDataSourceHelper
        let section = dataSource.sections[section] as! TableSectionWithSupplementaryViews
        return section.headerViewForTableView(tableView)
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let dataSource = tableView.dataSource as! TableViewDataSourceHelper
        let section = dataSource.sections[section] as! TableSectionWithSupplementaryViews
        return section.headerHeight
    }
}
