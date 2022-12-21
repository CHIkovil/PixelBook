//
//  LibraryExampleView.swift
//  BlackBook
//
//  Created by Nikolas on 17.12.2022.
//

import Foundation
import UIKit
import SnapKit


final class LibraryExampleView: UIView {
    private enum Constants {
        static let imageSide: CGFloat = 48 
        static let labelHeight: CGFloat = 40
        static let labelFontSize: CGFloat = 13
        static let elements: [(String, String)] =  [
            ("book", "Находим"),
            ("downloading", "Загружаем"),
            ("share", "Открываем"),
            ("reading-book", "Наслаждаемся")
        ]
        static let arrowImageSide: CGFloat = 25
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private let stackview: UIStackView = {
        let view = UIStackView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fillEqually
        view.alignment = .fill
        return view
    }()
    
    private func commonInit() {
        backgroundColor = .clear
        alpha = 0

        self.addSubview(stackview)
        
        stackview.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        self.setupElements()
    }
    
    private func setupElements() {
        
        Constants.elements.enumerated().forEach {[weak self] (index,element) in
            guard let self else{return}
            
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = backgroundColor
            
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.backgroundColor = .clear
            imageView.contentMode = .scaleToFill
            imageView.tintColor = backgroundColor
            imageView.image = UIImage(named: element.0)?.toPixelImage(AppConstants.imagePixelScale )?.inverseImage(cgResult: false)?.mask(with: AppColor.active)
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont(name: AppConstants.textFontName, size: Constants.labelFontSize)
            label.textAlignment = .center
            label.backgroundColor = backgroundColor
            label.textColor = AppColor.supportText
            label.text = element.1
            
            view.addSubview(imageView)
            view.addSubview(label)
            
            imageView.snp.makeConstraints {
                $0.centerX.equalTo(view.snp.centerX)
                $0.bottom.equalTo(view.snp.centerY)
                $0.height.equalTo(Constants.imageSide)
                $0.width.equalTo(Constants.imageSide)
            }
            
            label.snp.makeConstraints {
                $0.centerX.equalTo(view.snp.centerX)
                $0.top.equalTo(view.snp.centerY)
                $0.height.equalTo(Constants.labelHeight)
                $0.width.equalToSuperview()
            }
            
            self.stackview.addArrangedSubview(view)
            
            if index == Constants.elements.count-1 {
                return
            }
            
            let arrowImageView = UIImageView()
            arrowImageView.translatesAutoresizingMaskIntoConstraints = false
            arrowImageView.backgroundColor = .clear
            arrowImageView.contentMode = .scaleToFill
            arrowImageView.tintColor = backgroundColor
            arrowImageView.image = UIImage(named: "down-arrow")?.toPixelImage(AppConstants.imagePixelScale )?.inverseImage(cgResult: false)?.mask(with: AppColor.arrow)
            
            view.addSubview(arrowImageView)
            
            arrowImageView.snp.makeConstraints {
                $0.centerX.equalTo(view.snp.centerX)
                $0.bottom.equalTo(view.snp.bottom)
                $0.height.equalTo(Constants.arrowImageSide - 5)
                $0.width.equalTo(Constants.arrowImageSide)
            }
        }
    }
    
    func animateShow() {
        if self.alpha == 0 {
            self.alpha = 1
            self.stackview.arrangedSubviews.enumerated().forEach {
                let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
                animation.fromValue =  0
                animation.toValue =  1
                animation.duration = CFTimeInterval($0)
                animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                $1.layer.add(animation, forKey: "fadeAnimation")
            }
        }
    }
    
    func animateHide() {
        if self.alpha == 1 {
            self.alpha = 0
        }
    }
}
