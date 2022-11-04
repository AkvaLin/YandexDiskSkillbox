//
//  OnboardingCollectionViewCell.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 18.07.2022.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: OnboardingCollectionViewCell.self)
    
    private let slideImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let slideTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.secondHeader
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor(named: "Bttn")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(slideImageView)
        addSubview(slideTitleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addViews()
    }
    
    func addViews() {
        slideImageView.translatesAutoresizingMaskIntoConstraints = false
        slideTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        slideTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        slideTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 395).isActive = true
        slideTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -143.12).isActive = true
        
        slideImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 113).isActive = true
        slideImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -113).isActive = true
        slideImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 184).isActive = true
        slideImageView.bottomAnchor.constraint(equalTo: slideTitleLabel.topAnchor, constant: -64).isActive = true
    }
    
    func setup(_ slide: OnboardingSlideModel) {
        slideImageView.image = slide.image
        slideTitleLabel.text = slide.title
    }
}
