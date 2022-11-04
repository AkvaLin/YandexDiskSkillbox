//
//  TableViewCell.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 02.08.2022.
//

import UIKit

class TableViewCell: UITableViewCell {

    static let identifier = String(describing: TableViewCell.self)
    
    private let fileImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.tintColor = Constants.Colors.secondAccent
        return image
    }()
    
    private let nameLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.main
        label.textColor = UIColor(named: "Bttn")
        return label
    }()
    
    private let sizeLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.small
        label.textColor = Constants.Colors.details
        return label
    }()
    
    private let dateLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.small
        label.textColor = Constants.Colors.details
        label.textAlignment = .center
        return label
    }()
    
    private let timeLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.small
        label.textColor = Constants.Colors.details
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(fileImage)
        addSubview(nameLbl)
        addSubview(sizeLbl)
        addSubview(dateLbl)
        addSubview(timeLbl)
        
        fileImage.translatesAutoresizingMaskIntoConstraints = false
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        sizeLbl.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        timeLbl.translatesAutoresizingMaskIntoConstraints = false
        
        fileImage.anchor(top: topAnchor,
                         left: leftAnchor,
                         bottom: nil,
                         right: nil,
                         paddingTop: 10,
                         paddingLeft: 18,
                         paddingBottom: 0,
                         paddingRight: 0,
                         width: 40,
                         height: 40,
                         enableInsets: false
        )
        nameLbl.anchor(top: topAnchor,
                       left: fileImage.rightAnchor,
                       bottom: nil,
                       right: nil,
                       paddingTop: 15,
                       paddingLeft: 15,
                       paddingBottom: 0,
                       paddingRight: 0,
                       width: frame.size.width / 2,
                       height: 0,
                       enableInsets: false
        )
        sizeLbl.anchor(top: nameLbl.bottomAnchor,
                       left: fileImage.rightAnchor,
                       bottom: nil,
                       right: nil,
                       paddingTop: 5,
                       paddingLeft: 15,
                       paddingBottom: 0,
                       paddingRight: 0,
                       width: frame.size.width / 3,
                       height: 0,
                       enableInsets: false
        )
        timeLbl.anchor(top: nameLbl.bottomAnchor,
                       left: nil,
                       bottom: nil,
                       right: rightAnchor,
                       paddingTop: 5,
                       paddingLeft: 0,
                       paddingBottom: 0,
                       paddingRight: 18,
                       width: frame.size.width / 8,
                       height: 0,
                       enableInsets: false
        )
        dateLbl.anchor(top: nameLbl.bottomAnchor,
                       left: nil,
                       bottom: nil,
                       right: timeLbl.leftAnchor,
                       paddingTop: 5,
                       paddingLeft: 0,
                       paddingBottom: 0,
                       paddingRight: 2,
                       width: frame.size.width / 4,
                       height: 0,
                       enableInsets: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(image: UIImage, name: String, size: String, date: String, time: String) {
        fileImage.image = image
        nameLbl.text = name
        sizeLbl.text = size
        dateLbl.text = date
        timeLbl.text = time
    }
}
