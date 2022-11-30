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
            return "delete"
        case .repeated:
            return "attention"
        case .added:
            return "success"
        }
    }
}
    
final class LibraryNotificationView: UIView {
    private enum Constants {
        static let rotationAngle: CGFloat = CGFloat.pi / 5
        static let labelFontSize: CGFloat = 17
        static let contentOffset: CGFloat = 10
        static let imageSide: CGFloat = 40
        static let labelHeight: CGFloat = 37
        static let cornerRadius: CGFloat = 15
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = AppColor.active
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = Constants.imageSide / 2
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(Constants.labelFontSize)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = AppColor.active
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
        self.backgroundColor = AppColor.contentBackground
        self.layer.cornerRadius = Constants.cornerRadius
        self.layer.masksToBounds = true
        self.alpha = 0
        
        addSubview(imageView)
        addSubview(label)
        
        imageView.snp.makeConstraints {
            $0.bottom.equalTo(self.snp.centerY)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(Constants.imageSide)
            $0.width.equalTo(Constants.imageSide)
        }
        
        label.snp.makeConstraints {
            $0.top.equalTo(self.snp.centerY)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(Constants.labelHeight)
            $0.width.equalToSuperview()
        }
    }
    
    func setup(_ state: LibraryNotificationState) {
        imageView.image = UIImage(named: state.imageName)
        label.text = state.rawValue
        self.animateShowView()
    }
    
    func animateShowView() {
        let originalTransform = self.transform
        let scaledAndTranslatedTransform = originalTransform.translatedBy(x: 0, y: self.frame.height)
        
        UIView.animate(withDuration: 0.5,animations: {[weak self] in
            guard let self = self else{return}
            self.transform = scaledAndTranslatedTransform
            self.alpha = 1
            
        }, completion:  {[weak self] _ in
            guard let self = self else{return}
            UIView.animate(withDuration: 0.25, animations: {
                self.imageView.transform = CGAffineTransform(rotationAngle: Constants.rotationAngle)
            }, completion: {[weak self] _ in
                guard let self = self else{return}
                UIView.animate(withDuration: 0.25, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: -Constants.rotationAngle)
                }, completion: {[weak self] _ in
                    guard let self = self else{return}
                    UIView.animate(withDuration: 0.15 ,animations: {
                        self.imageView.transform = .identity
                        
                    },completion: {[weak self] _ in
                        guard let self = self else{return}
                        UIView.animate(withDuration: 0.5) {
                            self.alpha = 0
                            self.transform = .identity
                        }
                    })
                })
            })
        })
    }
}
