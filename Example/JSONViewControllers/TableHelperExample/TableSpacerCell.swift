//
//  TableSpacerCell.swift
//  SnapKitchen
//
//  Created by Graham Perks on 7/12/16.
//  Copyright © 2016 Snap Kitchen. All rights reserved.
//

import UIKit
import JSONViewControllers

// This same cell is used for:
// - TableSpacerRow
// - TableSeparatorRow
// - TableTextRow
// When registering cells, the cell needs to be registered just once.
// If this cell includes a text or separator (via TableSeparatorRow), it goes at the bottom of the cell.
class TableSpacerCell: UITableViewCell, TableCellConfigurer {

    var separator: UIView?
    var caption: UILabel?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }


    override func prepareForReuse() {
        super.prepareForReuse()
        separator?.removeFromSuperview()
        caption?.removeFromSuperview()
    }

    fileprivate func addSeparator(height: CGFloat, separatorColor: UIColor ) {
        let s = UIView()
        separator = s
        s.backgroundColor = separatorColor
        contentView.addSubview(s)
        s.snp.makeConstraints() {
            make in
            make.leading.equalTo(contentView).offset(15)
            make.trailing.equalTo(contentView).offset(-15)
            make.bottom.equalTo(contentView)
            make.height.equalTo(height)
        }
    }

    fileprivate func addLabel(text: NSAttributedString) {
        let c = UILabel()
        c.numberOfLines = 0
        caption = c
        c.attributedText = text
        contentView.addSubview(c)
        c.snp.makeConstraints() {
            make in
            make.leading.equalTo(contentView).offset(15)
            make.trailing.equalTo(contentView).offset(-15)
            make.bottom.equalTo(contentView)
        }
    }

}

// Row full of blank space.
class TableSpacerRow: NSObject, TableRow {
    let source: TableRowSource = .class("TableSpacerCell")
    let reuseIdentifier = "TableSpacerCell"
    var height: CGFloat = 15
    var action: String?

    var backgroundColor: UIColor?

    init(height: CGFloat) {
        self.height = height
        self.backgroundColor = UIColor.white
        super.init()
    }


    init(height: CGFloat, backgroundColor: UIColor) {
        self.height = height
        self.backgroundColor = backgroundColor
        super.init()
    }

    func configureIn(_ cell: TableCellConfigurer, indexPath: IndexPath) {
        let cell = cell as! TableSpacerCell

        if let backgroundColor = backgroundColor {
            cell.backgroundColor = backgroundColor
        }
    }
}

// Adds a gray separator line to the bottom of a regular spacer.
class TableSeparatorRow: TableSpacerRow {
    var separatorHeight: CGFloat = 0
    var separatorColor: UIColor

    init(spacingHeight: CGFloat, separatorHeight: CGFloat = 2, separatorColor: UIColor = UIColor.lightGray.withAlphaComponent(0.15)) {
        self.separatorHeight = separatorHeight
        self.separatorColor = separatorColor
        super.init(height: spacingHeight)
    }

    override func configureIn(_ cell: TableCellConfigurer, indexPath: IndexPath) {

        super.configureIn(cell, indexPath: indexPath)

        let cell = cell as! TableSpacerCell

        if separatorHeight > 0 {
            cell.addSeparator(height: separatorHeight, separatorColor: separatorColor)
        }
    }
}

// Adds a line of text to the bottom of a regular spacer.
class TableTextRow: TableSpacerRow {
    var separatorHeight: CGFloat = 0
    var caption: NSAttributedString

    init(spacingHeight: CGFloat, caption: NSAttributedString) {
        self.caption = caption
        super.init(height: spacingHeight)
    }

    override func configureIn(_ cell: TableCellConfigurer, indexPath: IndexPath) {

        super.configureIn(cell, indexPath: indexPath)

        let cell = cell as! TableSpacerCell

        cell.addLabel(text: caption)
    }
}
