//
//  BookTableViewCell.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//

import SnapKit
import UIKit

final class BookTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        
    }

    func setup(model: BookModel) {
        
    }
}

