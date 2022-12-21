//
//  LibraryCurrentItemView.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import Foundation
import UIKit

final class LibraryCurrentItemView: UIView {
    private enum Constants {
        static let recentText = "ВЫ НЕДАВНО ЧИТАЛИ:"
        static let continueText = "ПРОДОЛЖИТЬ"
        static let imageWidth = 140
        static let imageHeight = 200
        static let titleLabelHeight: CGFloat = 100
        static let interlineationLabelHeight: CGFloat = 40
        static let labelFontSizeBase: CGFloat = 20
        static let labelFontSizeInterlineation: CGFloat = 12
        static let contentOffset:CGFloat = 20
    }
    
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.layer.borderColor = AppColor.contentBorder.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = UIFont(name: AppConstants.textFontName, size: Constants.labelFontSizeBase)
        label.textColor = AppColor.mainText
        label.numberOfLines = 0
        return label
    }()
    
    lazy var recentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = UIFont(name: AppConstants.textFontName, size: Constants.labelFontSizeInterlineation)
        label.textColor = AppColor.supportText
        label.text = Constants.recentText
        return label
    }()
    
    lazy var continueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = UIFont(name: AppConstants.textFontName, size: Constants.labelFontSizeInterlineation)
        label.textColor = AppColor.active
        label.text = Constants.continueText
        label.textAlignment = .right
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = AppColor.contentBackground
        layer.masksToBounds = false
        layer.borderColor = AppColor.contentBorder.cgColor
        layer.borderWidth = AppConstants.contentBorderWidth
        layer.cornerRadius = AppConstants.contentCornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 4, height: 4)
        layer.shadowRadius = AppConstants.contentShadowRadius
        addSubview(coverImageView)
        addSubview(titleLabel)
        addSubview(recentLabel)
        addSubview(continueLabel)
        
        coverImageView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-Constants.contentOffset)
            $0.leading.equalToSuperview().offset(Constants.contentOffset)
            $0.height.equalTo(Constants.imageHeight)
            $0.width.equalTo(Constants.imageWidth)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(coverImageView.snp.centerY)
            $0.leading.equalTo(coverImageView.snp.trailing).offset(Constants.contentOffset)
            $0.height.equalTo(Constants.titleLabelHeight)
            $0.trailing.equalTo(self.snp.trailing).offset(-Constants.contentOffset)
        }
        
        recentLabel.snp.makeConstraints {
            $0.bottom.equalTo(coverImageView.snp.centerY).offset(-Constants.contentOffset)
            $0.leading.equalTo(coverImageView.snp.trailing).offset(Constants.contentOffset)
            $0.height.equalTo(Constants.interlineationLabelHeight)
            $0.trailing.equalTo(self.snp.trailing).offset(-Constants.contentOffset)
        }
        
        continueLabel.snp.makeConstraints {
            $0.centerY.equalTo(coverImageView.snp.bottom).offset(-Constants.interlineationLabelHeight / 2.0)
            $0.trailing.equalTo(self.snp.trailing).offset(-Constants.contentOffset)
            $0.height.equalTo(Constants.interlineationLabelHeight)
            $0.leading.equalTo(coverImageView.snp.trailing).offset(Constants.contentOffset)
        }
    }
    
    var model: BookModel?
    
    func setup(model: BookModel) {
        self.model = model
        titleLabel.text = model.title
        
        guard let cover = model.cover else {return}
        let coverImage = UIImage(data: cover)
        coverImageView.image = coverImage?.toPixelImage(AppConstants.imagePixelScale) ?? coverImage
    }
    
    func reset() {
        self.model = nil
        titleLabel.text = nil
        coverImageView.image = nil
        
    }
}
