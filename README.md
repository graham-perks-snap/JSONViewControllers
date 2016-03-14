# JSONViewControllers

[![CI Status](http://img.shields.io/travis/Graham Perks/JSONViewControllers.svg?style=flat)](https://travis-ci.org/Graham Perks/JSONViewControllers)
[![Version](https://img.shields.io/cocoapods/v/JSONViewControllers.svg?style=flat)](http://cocoapods.org/pods/JSONViewControllers)
[![License](https://img.shields.io/cocoapods/l/JSONViewControllers.svg?style=flat)](http://cocoapods.org/pods/JSONViewControllers)
[![Platform](https://img.shields.io/cocoapods/p/JSONViewControllers.svg?style=flat)](http://cocoapods.org/pods/JSONViewControllers)

## Usage

UITableViewController & UICollectionViewController subclasses useful when:

* You have shared cells across several table/collections
* the table's structure is variable, or unknown at build time

They:

* move cell logic to cell controller classes
* make the data source data-driven
* can load the table structure from JSON


To run the example project, clone the repo, and run `pod install` from the Example directory first.

JSON describes your table. The JSON can be downloaded, embedded, or generated at run-time. It describes the sections and rows of your table.

Each row has a set of attributes defined by the row's cell definition. For example, a cell displaying a name might define a "name" attribute. e.g.

```json
[
    {
        "rows": [
            {
                "nib": "NameCell",
                "name": "Graham Perks"
            }
        ]
    }
]
```

This is a single-celled table. The outer array is for sections; the single section contains an array of rows. Interestingly cells can define key-value paths for their data, e.g.

```json
            {
                "nib": "NameCell",
                "nameKeyPath": "user.name"
            }
```
The cell will display the value for the keypath "user.name" off the table view controller.

XIBs aren't required. Cells can be defined as classes, too:
```json
            {
                "class": "NameCell",
                "nameKeyPath": "user.name"
            }
```


#### Pre-defined keys

**action**

An "action" key will trigger when the row is tapped. The value should be the name of a Selector; optionally taking a parameter which will be the cell definition dictionary.
```swift
    func menuItemTapped(cell: [String : AnyObject]) {
        let json = JSON(cell)

        // Log an event given the "analytics" entry in the row definition, e.g.
        Analytics.LogEvent(json["analytics"].stringValue)
        
        // And trigger the segue given the "segue" value.
        if let segueName = json["segue"].string {
            parentViewController?.performSegueWithIdentifier(segueName, sender: self)
        }
    }
```

An appropriate cell driving this logic might be:

```json
            {
                "action": "menuItemTapped:",
                "nib": "NavigationCell",
                "analytics": "Navigator|food",
                "caption": "Food Menu",
                "icon": "icn_foodmenu"
            }
```

JSON is optional. You can assign directly to the 'sections' array after building the view structure at run time.

#### Hints

- When designing a nib, first delete the UIView that Interface Builder gives you, and drag out a table or collection view cell.
- Make the XIB, class, and cell's reusable identifier all the same.
- Use auto-layout within the cells to define cell height.

## Requirements

Uses SwiftyJSON to ease JSON manipulation.

## Installation

JSONViewControllers is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JSONViewControllers"
```

For an Objective-C take on this approach, see https://github.com/gperks/ASPTableViewController.

## Author

Graham Perks, graham_perks@snapkitchen.com

## License

JSONViewControllers is available under the MIT license. See the LICENSE file for more info.
