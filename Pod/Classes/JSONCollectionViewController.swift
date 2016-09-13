//
//  JSONCollectionViewController.swift
//  SnapKitchen
//
//  Created by Graham Perks on 3/1/16.
//  Copyright © 2016 Snap Kitchen. All rights reserved.
//

import UIKit
import SwiftyJSON

public protocol JSONCollectionCellConfigurer {
    func configureInCollectionViewController(_ collectionViewController: UICollectionViewController, cellDefinition: JSON)
}

open class JSONCollectionViewController: UICollectionViewController {

    open var sections: JSON!
    var cellConfigurers = [String: JSONCollectionCellConfigurer]()


    override open func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }


    open func setJSON(_ url:URL) {

        if let data = try? Data(contentsOf: url) {
            sections = JSON(data: data, options:.allowFragments)

            registerConfigurers()
        }
    }

    // Iterate through all the rows ensuring each cell's NIB and class is registered with the table
    open func registerConfigurers() {

        for section in sections.arrayValue {
            for row in section["rows"].arrayValue {
                if let rowClass = row["class"].string {
                    let clazz:AnyClass = rowClass.classFromClassName()
                    collectionView!.register(clazz, forCellWithReuseIdentifier: rowClass)
                }
                else if let rowNib = row["nib"].string {
                    let nib = UINib(nibName: rowNib, bundle: nil)
                    collectionView!.register(nib, forCellWithReuseIdentifier: rowNib)
                }
            }
        }
    }


    open func cellForIndexPath(_ indexPath : IndexPath) -> JSON {
        let section = sections.arrayValue[(indexPath as NSIndexPath).section]
        let rows = section["rows"]
        let row = rows[(indexPath as NSIndexPath).row]

        return row
    }

    // MARK: UICollectionViewDataSource

    override open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }


    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = sections.arrayValue[section]
        let rows = section["rows"]
        return rows.count
    }

    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let row = cellForIndexPath(indexPath)
        let reuseId = row["class"].string ?? row["nib"].stringValue
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath)

        // Configure the cell...

        if let configurer = cell as? JSONCollectionCellConfigurer {
            configurer.configureInCollectionViewController(self, cellDefinition: row)
        }

        return cell

    }

    // MARK: UICollectionViewDelegate


    override open func collectionView(_ collectionView: UICollectionView,
                          didSelectItemAt indexPath: IndexPath) {
        
        let row = cellForIndexPath(indexPath)

        if let action = row["action"].string {
            if action.hasSuffix(":") {
                self.perform(Selector(action), with: row.dictionaryObject!)
            }
            else {
                self .perform(Selector(action))
            }
        }

    }

    override open  func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }


}
