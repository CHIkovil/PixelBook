//
//  BookTableViewCell.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//

import SnapKit
import UIKit

final class BookTableViewCell: UITableViewCell {
    private enum Constants {
        static let imageWidth: CGFloat = 90
        static let labelHeight: CGFloat = 40
        static let labelWidth: CGFloat = 300
        static let labelFontSizeBase: CGFloat = 17
        static let labelFontSizeInterlineation: CGFloat = 12
        static let cellCornerRadius: CGFloat = 10
        static let contentOffset = 20
    }
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.borderColor = AppColor.contentBorder.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = label.font.withSize(Constants.labelFontSizeBase)
        label.textColor = AppColor.mainText
        return label
    }()
    
    lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = label.font.withSize(Constants.labelFontSizeInterlineation)
        label.textColor = AppColor.supportText
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }


    private func commonInit() {
        backgroundColor = AppColor.contentBackground
        selectionStyle = .none
        layer.masksToBounds = false
        layer.borderColor = AppColor.contentBorder.cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = Constants.cellCornerRadius
        addSubview(coverImageView)
        addSubview(titleLabel)
        addSubview(authorLabel)
        
        coverImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(Constants.contentOffset)
            $0.height.equalToSuperview().multipliedBy(0.8)
            $0.width.equalTo(Constants.imageWidth)
        }
        
        titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(self.snp.centerY)
            $0.leading.equalTo(coverImageView.snp.trailing).offset(Constants.contentOffset)
            $0.height.equalTo(Constants.labelHeight)
            $0.width.equalTo(Constants.labelWidth)
        }
        
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.centerY)
            $0.leading.equalTo(coverImageView.snp.trailing).offset(Constants.contentOffset)
            $0.height.equalTo(Constants.labelHeight)
            $0.width.equalTo(Constants.labelWidth)
        }
    }

    func setup(model: BookModel) {
        titleLabel.text = model.title
        authorLabel.text = model.author
        
        guard let cover = model.cover else {return}
        coverImageView.image = UIImage(data: cover)
    }
}

