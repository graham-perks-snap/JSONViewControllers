//
//  CollectionViewHelp.swift
//  SnapKitchen
//
//  Created by Graham Perks on May/25/16.
//  Copyright © 2016 Snap Kitchen. All rights reserved.
//

import UIKit


public protocol CollectionCellConfigurer {
    func configureIn(definition: CollectionItem, indexPath: NSIndexPath)
}

public extension CollectionCellConfigurer {
    public func configureIn(definition: CollectionItem, indexPath: NSIndexPath) {
        definition.configureIn(self, indexPath: indexPath)
    }
}

public enum CollectionRowSource {
    case Nib(String)
    case Class(String)
}


// Swift class names are AppName.ClassName.
// Prepend the app name with the given class name.
func classFromClassName(className: String) -> AnyClass! {
    var appName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String
    appName = appName.stringByReplacingOccurrencesOfString(" ", withString: "_", options: .LiteralSearch, range: nil)
    return NSClassFromString("\(appName).\(className)")
}

//MARK: Collection Item

// Implement CollectionRow, add rows to sections to build the Collection
public protocol CollectionItem: class {
    // Need either a nib or a class to register with

    var source: CollectionRowSource {get}

    var reuseIdentifier: String { get }
    var action: String? { get }

    func configureIn(cell: CollectionCellConfigurer, indexPath: NSIndexPath)
}

public protocol CollectionSection {
    var items: [CollectionItem] { get set }
}

// A regular section with no headers or footers
public class DefaultCollectionSection: CollectionSection {
    public init() {}
    public var items = [CollectionItem]()
}

// MARK: - Collection view data source

public class CollectionViewDataSourceHelper: NSObject, UICollectionViewDataSource {
    public var sections = [CollectionSection]()

    // Iterate through all the rows ensuring each cell's NIB and class is registered with the Collection
    public func registerConfigurers(collectionView: UICollectionView) {

        for section in sections {
            for item in section.items {
                switch item.source {
                case .Nib(let nibName):
                    let nib = UINib(nibName: nibName, bundle: nil)

                    collectionView.registerNib(nib, forCellWithReuseIdentifier: item.reuseIdentifier)
                case .Class(let className):
                    let clazz:AnyClass = classFromClassName(className)
                    collectionView.registerClass(clazz, forCellWithReuseIdentifier: item.reuseIdentifier)
                }
            }
        }
    }

    /// Register nib with name identical to its reuse ID
    static public func registerNib(collectionView: UICollectionView, name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: name)
    }


    public func numberOfSectionsInCollectionView(CollectionView: UICollectionView) -> Int {
        return sections.count
    }


    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }


    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.row]

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(item.reuseIdentifier, forIndexPath: indexPath)

        if let configurer = cell as? CollectionCellConfigurer {
            configurer.configureIn(item, indexPath: indexPath)
        }

        return cell
    }

}

// MARK: - Collection view delegate

public class CollectionViewDelegateHelper: NSObject, UICollectionViewDelegate {

    public override init() { super.init() }

    public init(collectionViewController: UICollectionViewController) {
        self.collectionViewController = collectionViewController
        super.init()
    }

    weak var collectionViewController: UICollectionViewController?

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let dataSource = collectionView.dataSource as! CollectionViewDataSourceHelper

        let section = dataSource.sections[indexPath.section]
        let row = section.items[indexPath.row]

        if let action = row.action, target = collectionViewController {
            target.performSelector(Selector(action), withObject: row)
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