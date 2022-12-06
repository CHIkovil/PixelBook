//
//  LibraryNotificationView.swift
//  BlackBook
//
//  Created by Nikolas on 29.11.2022.
//

import Foundation
import UIKit

enum LibraryNotificationState:String {
    case deleted = "Удалена"
    case repeated = "Уже добавлена"
    case added = "Добавлена"
    
    var imageName: String {
        switch self {
        case .deleted:
            return "removal"
        case .repeated:
            return "attention"
        case .added:
            return "success"
        }
    }
}
    
final class LibraryNotificationView: UIView {
    private enum Constants {
        static let rotationAngle: CGFloat = CGFloat.pi / 6
        static let labelFontSize: CGFloat = 18
        static let contentOffset: CGFloat = 10
        static let imageSide: CGFloat = 35
        static let labelHeight: CGFloat = 40
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = AppColor.active
        imageView.contentMode = .scaleToFill
        imageView.layer.borderColor = AppColor.background.cgColor
        imageView.layer.borderWidth = AppConstants.contentBorderWidth
        imageView.layer.cornerRadius = Constants.imageSide / 2
        imageView.layer.masksToBounds = true
        imageView.tintColor = backgroundColor
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppConstants.textFontName, size: Constants.labelFontSize)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = AppColor.mainText
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
        backgroundColor = AppColor.background
        layer.cornerRadius = AppConstants.contentCornerRadius + 10
        layer.masksToBounds = false
        layer.borderColor = AppColor.background.cgColor
        layer.borderWidth = AppConstants.contentBorderWidth
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 4, height: 4)
        layer.shadowRadius = AppConstants.contentShadowRadius
        alpha = 0
        addSubview(imageView)
        addSubview(label)
        
        imageView.snp.makeConstraints {
            $0.bottom.equalTo(self.snp.centerY).offset(5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(Constants.imageSide)
            $0.width.equalTo(Constants.imageSide)
        }
        
        label.snp.makeConstraints {
            $0.top.equalTo(self.snp.centerY).offset(5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(Constants.labelHeight)
            $0.width.equalToSuperview()
        }
    }
    
    func setup(_ state: LibraryNotificationState) {
        imageView.image = UIImage(named: state.imageName)?.withRenderingMode(.alwaysTemplate)
        label.text = state.rawValue
        self.animateShowView()
    }
    
    private func animateShowView() {
        let originalTransform = self.transform
        let scaledAndTranslatedTransform = originalTransform.translatedBy(x: 0, y: self.frame.height)
        
        UIView.animate(withDuration: 0.9, animations: {[weak self] in
            guard let self = self else{return}
            self.transform = scaledAndTranslatedTransform
            self.alpha = 0.95
            
        }, completion:  {[weak self] _ in
            guard let self = self else{return}
            UIView.animate(withDuration: 0.2, animations: {
                self.imageView.transform = CGAffineTransform(rotationAngle: Constants.rotationAngle)
            }, completion: {[weak self] _ in
                guard let self = self else{return}
                UIView.animate(withDuration: 0.2, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: -Constants.rotationAngle)
                }, completion: {[weak self] _ in
                    guard let self = self else{return}
                    UIView.animate(withDuration: 0.1 ,animations: {
                        self.imageView.transform = .identity
                        
                    },completion: {[weak self] _ in
                        guard let self = self else{return}
                        UIView.animate(withDuration: 0.75) {
                            self.alpha = 0
                            self.transform = .identity
                        }
                    })
                })
            })
        })
    }
}
