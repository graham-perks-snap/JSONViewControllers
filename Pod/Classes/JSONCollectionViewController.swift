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
    func configureInCollectionViewController(collectionViewController: UICollectionViewController, cellDefinition: JSON)
}

public class JSONCollectionViewController: UICollectionViewController {

    public var sections: JSON!
    var cellConfigurers = [String: JSONCollectionCellConfigurer]()


    override public func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }


    public func setJSON(url:NSURL) {

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

    // Iterate through all the rows ensuring each cell's NIB and class is registered with the table
    public func registerConfigurers() {

        for section in sections.arrayValue {
            for row in section["rows"].arrayValue {
                if let rowClass = row["class"].string {
                    let clazz:AnyClass = rowClass.classFromClassName()
                    collectionView!.registerClass(clazz, forCellWithReuseIdentifier: rowClass)
                }
                else if let rowNib = row["nib"].string {
                    let nib = UINib(nibName: rowNib, bundle: nil)
                    collectionView!.registerNib(nib, forCellWithReuseIdentifier: rowNib)
                }
            }
        }
    }


    public func cellForIndexPath(indexPath : NSIndexPath) -> JSON {
        let section = sections.arrayValue[indexPath.section]
        let rows = section["rows"]
        let row = rows[indexPath.row]

        return row
    }

    // MARK: UICollectionViewDataSource

    override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections.count
    }


    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = sections.arrayValue[section]
        let rows = section["rows"]
        return rows.count
    }

    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let row = cellForIndexPath(indexPath)
        let reuseId = row["class"].string ?? row["nib"].stringValue
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseId, forIndexPath: indexPath)

        // Configure the cell...

        if let configurer = cell as? JSONCollectionCellConfigurer {
            configurer.configureInCollectionViewController(self, cellDefinition: row)
        }

        return cell

    }

    // MARK: UICollectionViewDelegate


    override public func collectionView(collectionView: UICollectionView,
                          didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
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

    override public  func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }


}
