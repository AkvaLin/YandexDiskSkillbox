//
//  ViewController.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 30.06.2022.
//

import UIKit

class TabBarController: UITabBarController {
    
    private let roundLayer = CAShapeLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setTabBarApperance()
        setupVCs()
        
        networkMonitor.monitorNetwork()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.roundLayer.fillColor = view.backgroundColor?.cgColor
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let positionOnX: CGFloat = 0
        let positionOnY: CGFloat = 14
        let width = tabBar.bounds.width
        let height = tabBar.bounds.height + positionOnY * 4
        
        roundLayer.fillColor = view.backgroundColor?.cgColor
        roundLayer.shadowRadius = 10
        roundLayer.shadowOffset = .zero
        roundLayer.shadowOpacity = 0.08
        roundLayer.shadowOffset = CGSize(width: 0, height: 2)
        
        let bezierPath = UIBezierPath(roundedRect: CGRect(x: positionOnX,
                                                          y: tabBar.bounds.minY - positionOnY,
                                                          width: width,
                                                          height: height
                                                         ),
                                      cornerRadius: 0)
        
        roundLayer.path = bezierPath.cgPath
        
        tabBar.itemWidth = width/5
    }

    private func setTabBarApperance() {
        let positionOnX: CGFloat = 0
        let positionOnY: CGFloat = 14
        let width = tabBar.bounds.width
        let height = tabBar.bounds.height + positionOnY * 4
        
        roundLayer.fillColor = view.backgroundColor?.cgColor
        roundLayer.shadowRadius = 10
        roundLayer.shadowOffset = .zero
        roundLayer.shadowOpacity = 0.08
        roundLayer.shadowOffset = CGSize(width: 0, height: 2)
        
        let bezierPath = UIBezierPath(roundedRect: CGRect(x: positionOnX,
                                                          y: tabBar.bounds.minY - positionOnY,
                                                          width: width,
                                                          height: height
                                                         ),
                                      cornerRadius: 0)
        
        roundLayer.path = bezierPath.cgPath
        
        tabBar.layer.insertSublayer(roundLayer, at: 0)
        
        tabBar.itemWidth = width/5
        tabBar.itemPositioning = .centered
        tabBar.tintColor = Constants.Colors.firstAccent
    }
    
    private func setupVCs() {
        viewControllers = [
            createNavController(for: ProfileViewController(),
                                image: UIImage(named: "Person") ?? UIImage()),
            createNavController(for: RecentlyFilesViewController(),
                                image: UIImage(named: "File") ?? UIImage()),
            createNavController(for: FilesViewController(),
                                image: UIImage(named: "Archive") ?? UIImage())
        ]
    }
    
    private func createNavController(for rootViewController: UIViewController, image: UIImage) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = image
        return navController
    }
}

