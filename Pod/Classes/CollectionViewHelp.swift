//
//  CollectionViewHelp.swift
//  SnapKitchen
//
//  Created by Graham Perks on May/25/16.
//  Copyright © 2016 Snap Kitchen. All rights reserved.
//

import UIKit


public protocol CollectionCellConfigurer {
    func configureIn(_ definition: CollectionItem, indexPath: IndexPath)
}

public extension CollectionCellConfigurer {
    public func configureIn(_ definition: CollectionItem, indexPath: IndexPath) {
        definition.configureIn(self, indexPath: indexPath)
    }
}

public enum CollectionRowSource {
    case nib(String)
    case `class`(String)
}


// Swift class names are AppName.ClassName.
// Prepend the app name with the given class name.
func classFromClassName(_ className: String) -> AnyClass! {
    var appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    appName = appName.replacingOccurrences(of: " ", with: "_", options: .literal, range: nil)
    return NSClassFromString("\(appName).\(className)")
}

//MARK: Collection Item

// Implement CollectionRow, add rows to sections to build the Collection
public protocol CollectionItem: class {
    // Need either a nib or a class to register with

    var source: CollectionRowSource {get}

    var reuseIdentifier: String { get }
    var action: String? { get }

    func configureIn(_ cell: CollectionCellConfigurer, indexPath: IndexPath)
}

public protocol CollectionSection {
    var items: [CollectionItem] { get set }
}

// A regular section with no headers or footers
open class DefaultCollectionSection: CollectionSection {
    public init() {}
    open var items = [CollectionItem]()
}

// MARK: - Collection view data source

open class CollectionViewDataSourceHelper: NSObject, UICollectionViewDataSource {
    open var sections = [CollectionSection]()

    // Iterate through all the rows ensuring each cell's NIB and class is registered with the Collection
    open func registerConfigurers(_ collectionView: UICollectionView) {

        for section in sections {
            for item in section.items {
                switch item.source {
                case .nib(let nibName):
                    let nib = UINib(nibName: nibName, bundle: nil)

                    collectionView.register(nib, forCellWithReuseIdentifier: item.reuseIdentifier)
                case .class(let className):
                    let clazz:AnyClass = classFromClassName(className)
                    collectionView.register(clazz, forCellWithReuseIdentifier: item.reuseIdentifier)
                }
            }
        }
    }

    /// Register nib with name identical to its reuse ID
    static open func registerNib(_ collectionView: UICollectionView, name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: name)
    }


    open func numberOfSections(in CollectionView: UICollectionView) -> Int {
        return sections.count
    }


    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }


    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[(indexPath as NSIndexPath).section]
        let item = section.items[(indexPath as NSIndexPath).row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseIdentifier, for: indexPath)

        if let configurer = cell as? CollectionCellConfigurer {
            configurer.configureIn(item, indexPath: indexPath)
        }

        return cell
    }

}

// MARK: - Collection view delegate

open class CollectionViewDelegateHelper: NSObject, UICollectionViewDelegate {

    public override init() { super.init() }

    public init(actionTarget: NSObjectProtocol) {
        self.target = actionTarget
        super.init()
    }

    weak var target: NSObjectProtocol?

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dataSource = collectionView.dataSource as! CollectionViewDataSourceHelper

        let section = dataSource.sections[(indexPath as NSIndexPath).section]
        let row = section.items[(indexPath as NSIndexPath).row]

        if let action = row.action, let target = target {
            target.perform(Selector(action), with: row)
        }
    }
}

// I wish this worked, but protocol extension methods are invisible to UIKit.
//public protocol CollectionViewDelegateHelper2: class {
//
//}
//
//extension CollectionViewDelegateHelper2 where Self: NSObjectProtocol {
//    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        let dataSource = collectionView.dataSource as! CollectionViewDataSourceHelper
//
//        let section = dataSource.sections[indexPath.section]
//        let row = section.items[indexPath.row]
//
//        if let action = row.action {
//            performSelector(Selector(action), withObject: row)
//        }
//    }
//}
