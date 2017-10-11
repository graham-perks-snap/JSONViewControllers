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

public protocol CollectionHeaderConfigurer {
    func configureIn(_ definition: CollectionHeader, indexPath: IndexPath)
}

public extension CollectionHeaderConfigurer {
    public func configureIn(_ definition: CollectionHeader, indexPath: IndexPath) {
        definition.configureIn(self, indexPath: indexPath)
    }
}

public enum CollectionItemSource {
    case nib(String)
    case `class`(String)
    case prototype
}


// Swift class names are AppName.ClassName.
// Prepend the app name with the given class name.
func classFromClassName(_ className: String) -> AnyClass! {
    var appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    appName = appName.replacingOccurrences(of: " ", with: "_", options: .literal, range: nil)
    return NSClassFromString("\(appName).\(className)")
}

//MARK: Collection Item

// Implement CollectionItem, add items to sections to build the Collection
public protocol CollectionItem: class {
    // Need either a nib or a class to register with
    var source: CollectionItemSource {get}

    var reuseIdentifier: String { get }
    var action: String? { get }

    func configureIn(_ cell: CollectionCellConfigurer, indexPath: IndexPath)
}

public protocol CollectionItemWithHeight: CollectionItem {
    var height: CGFloat { get }
}

public protocol CollectionItemWithSize: CollectionItem {
    var preferredSize: CGSize { get }
}

public protocol CollectionHeader: class {
    // Need either a nib or a class to register with
    var source: CollectionItemSource {get}

    var reuseIdentifier: String { get }

    func configureIn(_ cell: CollectionHeaderConfigurer, indexPath: IndexPath)
}

public protocol CollectionSection {
    var items: [CollectionItem] { get set }
}

// A regular section with no headers or footers
open class DefaultCollectionSection: CollectionSection {
    public init() {}
    open var items = [CollectionItem]()
}

open class HeaderedCollectionSection: CollectionSection {
    public init() {}
    open var items = [CollectionItem]()
    open var header: CollectionHeader?
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
                case .prototype:
                    // Prototype cells are registered by storyboard loader.
                    break
                }
            }
        }
    }

    /// Register nib with name identical to its reuse ID
    static open func registerNib(_ collectionView: UICollectionView, name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: name)
    }


    @objc open func numberOfSections(in CollectionView: UICollectionView) -> Int {
        return sections.count
    }


    @objc open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }


    @objc open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseIdentifier, for: indexPath)

        if let configurer = cell as? CollectionCellConfigurer {
            configurer.configureIn(item, indexPath: indexPath)
        }

        return cell
    }

    @objc open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard let section = sections[indexPath.section] as? HeaderedCollectionSection else { fatalError("Section has no header specified") }

        guard let header = section.header else { fatalError("Section has no header") }

        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: header.reuseIdentifier, for: indexPath)

        if let configurer = view as? CollectionHeaderConfigurer {
            configurer.configureIn(header, indexPath: indexPath)
        }

        return view
    }
}

// MARK: - Collection view delegate

open class CollectionViewDelegateHelper: NSObject, UICollectionViewDelegate {

    public override init() { super.init() }

    public init(actionTarget: NSObjectProtocol) {
        self.target = actionTarget
        super.init()
    }

    public weak var target: NSObjectProtocol?

    @objc open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dataSource = collectionView.dataSource as! CollectionViewDataSourceHelper

        let section = dataSource.sections[(indexPath as NSIndexPath).section]
        let row = section.items[(indexPath as NSIndexPath).row]

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

// Coordinate flow layout with any CollectionItemWithSize, CollectionItemWithHeight
extension CollectionViewDelegateHelper: UICollectionViewDelegateFlowLayout {
    @objc public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let dataSource = collectionView.dataSource as! CollectionViewDataSourceHelper

        let section = dataSource.sections[indexPath.section]
        let item = section.items[indexPath.item]

        if let item = item as? CollectionItemWithSize {
            return item.preferredSize
        }
        if let item = item as? CollectionItemWithHeight {
            return CGSize(width: collectionView.bounds.width, height: item.height)
        }
        else if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.itemSize
        }
        else {
            fatalError("Override me")
        }
    }

}

// I wish this worked, but protocol extension methods are invisible to UIKit.
//public protocol CollectionViewDelegateHelper2: class {
//
//}
//
//extension CollectionViewDelegateHelper2 where Self: NSObjectProtocol {
//    @objc public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
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
