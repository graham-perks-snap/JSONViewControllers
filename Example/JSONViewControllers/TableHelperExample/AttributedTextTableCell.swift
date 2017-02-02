//
//  AttributedTextTableCell.swift
//  SnapKitchen
//
//  Created by Graham Perks on 1/20/17.
//  Copyright © 2017 Snap Kitchen. All rights reserved.
//
// Cell displaying attributed text covering an unknown number of lines & height.

import UIKit
import JSONViewControllers


class AttributedTextTableCell: UITableViewCell, TableCellConfigurer {

    @IBOutlet weak var captionLabel: UILabel!

//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        contentView.applySnapFont()
//    }
}


class AttributedTextTableRow: NSObject, TableRow {
    let source: TableRowSource = .nib("AttributedTextTableCell")
    let reuseIdentifier = "AttributedTextTableCell"
    var height: CGFloat = 22
    var action: String?

    var caption: NSAttributedString?

    init(caption: NSAttributedString, width: CGFloat) {
        self.caption = caption

        // -30 for a 15pt margin both sides.
        // arbitrarily high; we are computing height required for text.
        let size = CGSize(width: width - 30, height: 8000)
        let rect = caption.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)

        self.height = ceil(rect.height)
    }

    func configureIn(_ cell: TableCellConfigurer, indexPath: IndexPath) {
        let cell = cell as! AttributedTextTableCell

        if let caption = caption {
            cell.captionLabel.attributedText = caption
        }
    }
}

