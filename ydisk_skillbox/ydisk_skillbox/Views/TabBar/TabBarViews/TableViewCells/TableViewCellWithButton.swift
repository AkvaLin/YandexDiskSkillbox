//
//  TableViewCellWithButton.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 27.09.2022.
//

import UIKit

class TableViewCellWithButton: UITableViewCell {

    static let identifier = String(describing: TableViewCellWithButton.self)
    
    weak var delegate: TableViewCellWithButtonDelegate?
    
    private let button: UIButton = {
       let bttn = UIButton()
        bttn.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        bttn.tintColor = Constants.Colors.details
        return bttn
    }()
    
    internal let fileImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.tintColor = Constants.Colors.secondAccent
        return image
    }()
    
    internal let nameLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.main
        label.textColor = UIColor(named: "Bttn")
        return label
    }()
    
    internal let sizeLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.small
        label.textColor = Constants.Colors.details
        return label
    }()
    
    internal let dateLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.small
        label.textColor = Constants.Colors.details
        label.textAlignment = .center
        return label
    }()
    
    internal let timeLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.small
        label.textColor = Constants.Colors.details
        label.textAlignment = .center
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addSubview(fileImage)
        addSubview(nameLbl)
        addSubview(sizeLbl)
        addSubview(dateLbl)
        addSubview(timeLbl)
        contentView.addSubview(button)
        
        fileImage.translatesAutoresizingMaskIntoConstraints = false
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        sizeLbl.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        timeLbl.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
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
                       width: frame.size.width / 5,
                       height: 0,
                       enableInsets: false
        )
        timeLbl.anchor(top: nameLbl.bottomAnchor,
                       left: dateLbl.rightAnchor,
                       bottom: nil,
                       right: nil,
                       paddingTop: 5,
                       paddingLeft: 2,
                       paddingBottom: 0,
                       paddingRight: 0,
                       width: frame.size.width / 5,
                       height: 0,
                       enableInsets: false
        )
        dateLbl.anchor(top: nameLbl.bottomAnchor,
                       left: sizeLbl.rightAnchor,
                       bottom: nil,
                       right: nil,
                       paddingTop: 5,
                       paddingLeft: 2,
                       paddingBottom: 0,
                       paddingRight: 0,
                       width: frame.size.width / 4,
                       height: 0,
                       enableInsets: false)
        button.anchor(top: topAnchor,
                      left: nil,
                      bottom: nil,
                      right: rightAnchor,
                      paddingTop: 10,
                      paddingLeft: 0,
                      paddingBottom: 0,
                      paddingRight: 18,
                      width: 40,
                      height: 40,
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
    
    @objc public func buttonTapped() {
        delegate?.didTapButton(self)
    }
}

protocol TableViewCellWithButtonDelegate: AnyObject {
    func didTapButton(_ tableViewCellWithButton: TableViewCellWithButton)
}
