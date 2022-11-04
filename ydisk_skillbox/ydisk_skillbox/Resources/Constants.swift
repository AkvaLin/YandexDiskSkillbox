//
//  Constants.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 14.07.2022.
//

import UIKit

enum Constants {
    enum Fonts {
        static var firstHeader: UIFont? {
            UIFont(name: "Graphik-Semibold", size: 26)
        }
        static var secondHeader: UIFont? {
            UIFont(name: "Graphik-Medium", size: 17)
        }
        static var main: UIFont? {
            UIFont(name: "Graphik-Regular", size: 15)
        }
        static var small: UIFont? {
            UIFont(name: "Graphik-Regular", size: 13)
        }
        static var button: UIFont? {
            UIFont(name: "Graphik-Regular", size: 16)
        }
    }
    
    enum Colors {
        static var white: UIColor? {
            UIColor(named: "White")
        }
        static var black: UIColor? {
            UIColor(named: "Black")
        }
        static var firstAccent: UIColor? {
            UIColor(named: "FirstAccent")
        }
        static var secondAccent: UIColor? {
            UIColor(named: "SecondAccent")
        }
        static var details: UIColor? {
            UIColor(named: "Details")
        }
    }
    
    enum Types {
        static var office: [String] {
            [
                "application/vnd.ms-powerpoint",
                "application/vnd.openxmlformats-officedocument.presentationml.presentation",
                "application/msword",
                "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                "application/vnd.ms-excel",
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            ]
        }
        
        static var image: String {
            "image"
        }
        
        static var pdf: String {
            "application/pdf"
        }
    }
}
