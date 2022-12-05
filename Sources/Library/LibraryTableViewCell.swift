//
//  LibraryTableViewCell.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//

import SnapKit
import UIKit

final class LibraryTableViewCell: UITableViewCell {
    private enum Constants {
        static let imageWidth: CGFloat = 87
        static let labelHeight: CGFloat = 30
        static let labelFontSizeBase: CGFloat = 17
        static let labelFontSizeInterlineation: CGFloat = 12
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
        label.font = UIFont(name: AppConstants.textFontName, size: Constants.labelFontSizeBase)
        label.textColor = AppColor.mainText
        return label
    }()
    
    lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont(name: AppConstants.textFontName, size: Constants.labelFontSizeInterlineation)
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
        layer.cornerRadius = AppConstants.contentCornerRadius
        layer.borderColor = AppColor.contentBorder.cgColor
        layer.borderWidth = AppConstants.contentBorderWidth
        layer.masksToBounds = true
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
            $0.top.equalTo(self.snp.top).offset(Constants.contentOffset)
            $0.leading.equalTo(coverImageView.snp.trailing).offset(Constants.contentOffset)
            $0.height.equalTo(Constants.labelHeight)
            $0.trailing.equalTo(self.snp.trailing).offset(-Constants.contentOffset)
        }
        
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalTo(coverImageView.snp.trailing).offset(Constants.contentOffset)
            $0.height.equalTo(Constants.labelHeight)
            $0.trailing.equalTo(self.snp.trailing).offset(-Constants.contentOffset)
        }
    }

    func setup(_ model: BookModel) {
        titleLabel.text = model.title
        authorLabel.text = model.author
        
        guard let cover = model.cover else {return}
        let coverImage = UIImage(data: cover)
        coverImageView.image = coverImage?.toPixelImage(12) ?? coverImage
    }
}

