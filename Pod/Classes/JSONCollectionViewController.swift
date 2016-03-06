//
//  JSONCollectionViewController.swift
//  SnapKitchen
//
//  Created by Graham Perks on 3/1/16.
//  Copyright © 2016 Snap Kitchen. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol JSONCollectionCellConfigurer {
    func configureInCollectionViewController(collectionViewController: UICollectionViewController, cellDefinition: JSON)
}

class JSONCollectionViewController: UICollectionViewController {

    var sections: JSON!
    var cellConfigurers = [String: JSONCollectionCellConfigurer]()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }


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
                    collectionView!.registerClass(clazz, forCellWithReuseIdentifier: rowClass)
                }
                else if let rowNib = row["nib"].string {
                    let nib = UINib(nibName: rowNib, bundle: nil)
                    collectionView!.registerNib(nib, forCellWithReuseIdentifier: rowNib)
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

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections.count
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = sections.arrayValue[section]
        let rows = section["rows"]
        return rows.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

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


    override func collectionView(collectionView: UICollectionView,
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
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }
*/
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }


}
