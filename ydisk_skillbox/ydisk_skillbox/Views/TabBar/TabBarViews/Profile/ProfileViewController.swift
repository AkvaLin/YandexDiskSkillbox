//
//  ProfileViewController.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 25.07.2022.
//

import UIKit
import Charts
import SwiftyButton

class ProfileViewController: UIViewController {
    
    private let pieChart: PieChartView = {
        let pieChart = PieChartView()
        pieChart.legend.enabled = false
        pieChart.gestureRecognizers?.removeAll()
        pieChart.rotationEnabled = false
        pieChart.drawEntryLabelsEnabled = false
        pieChart.holeColor = .systemBackground
        return pieChart
    }()
    
    private let firstCircleView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let secondCircleView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let freeSpaceLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = Constants.Fonts.main
        lbl.numberOfLines = 1
        return lbl
    }()
    
    private let busySpaceLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = Constants.Fonts.main
        lbl.numberOfLines = 1
        return lbl
    }()
    
    private let networkView: UILabel = {
        let view = UILabel()
        view.backgroundColor = .systemRed
        view.text = "Отсутствуте подключение к интернету".localized
        view.numberOfLines = 0
        view.textColor = .white
        view.textAlignment = .center
        view.alpha = 0
        return view
    }()
    
    private lazy var publishedFilesBttn: FlatButton = {
        let bttn = FlatButton()
        bttn.cornerRadius = 10
        bttn.setTitle("Опубликованные файлы".localized, for: .normal)
        bttn.titleLabel?.font = Constants.Fonts.button
        bttn.setTitleColor(UIColor(named: "Bttn"), for: .normal)
        bttn.setImage(UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        bttn.titleLabel?.textAlignment = .left
        bttn.imageView?.tintColor = UIColor(named: "Bttn")
        bttn.highlightedColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08)
        bttn.color = UIColor(named: "PublishedFilesButton")!
        bttn.semanticContentAttribute = .forceRightToLeft
        bttn.addTarget(self, action: #selector(publishedFilesBttnClicked), for: .touchUpInside)
        bttn.layer.shadowRadius = 10
        bttn.layer.shadowOffset = .zero
        bttn.layer.shadowOpacity = 0.08
        bttn.layer.shadowOffset = CGSize(width: 0, height: 2)
        return bttn
    }()
    
    private var viewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNav()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.viewModel.fetchUserData(completionHandler: { [weak self] statusCode in
                if statusCode == 401 {
                    ClearData.deleteAll()
                    DispatchQueue.main.async {
                        let controller = LoginViewController()
                        controller.modalTransitionStyle = .flipHorizontal
                        controller.modalPresentationStyle = .fullScreen
                        self?.present(controller, animated: true)
                    }
                } else if statusCode == 200 {
                    
                } else {
                    print(statusCode)
                }
            })
        }
        
        viewModel.profileModel.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateChartData()
                self?.busySpaceLbl.text = "\(self?.viewModel.profileModel.value?.usedSpace ?? 0) " + "гб - занято".localized
                self?.freeSpaceLbl.text = "\(self?.viewModel.profileModel.value?.freeSpace ?? 0) " + "гб - свободно".localized
            }
        }
        
        tabBarController?.networkMonitor.isConnected.bind { [weak self] _ in
            DispatchQueue.main.async {
                guard let isConnected = self?.tabBarController?.networkMonitor.isConnected.value else { return }
                if isConnected {
                    UIView.animate(withDuration: 1, animations: {
                        self?.networkView.alpha = 0
                    })
                } else {
                    UIView.animate(withDuration: 1, animations: {
                        self?.networkView.alpha = 1
                    })
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.layer.addSublayer(createCircle(arcCenter:
                                                CGPoint(x: firstCircleView.frame.midX,
                                                        y: firstCircleView.frame.midY),
                                            startAngle: 0,
                                            endAngle: 360,
                                            color: Constants.Colors.secondAccent?.cgColor ?? UIColor.gray.cgColor))
        view.layer.addSublayer(createCircle(arcCenter:
                                                CGPoint(x: secondCircleView.frame.midX,
                                                        y: secondCircleView.frame.midY),
                                            startAngle: 0,
                                            endAngle: 360,
                                            color: Constants.Colors.details?.cgColor ?? UIColor.gray.cgColor))
    }
    
    private func updateChartData() {
        
        let chartDataSet = PieChartDataSet(entries: [
            PieChartDataEntry(value: viewModel.profileModel.value?.freeSpace ?? 0),
            PieChartDataEntry(value: viewModel.profileModel.value?.usedSpace ?? 0)
        ])
        let chartData = PieChartData(dataSet: chartDataSet)

        let colors = [Constants.Colors.secondAccent, Constants.Colors.details]
        chartDataSet.colors = colors as! [NSUIColor]

        pieChart.data = chartData

        let str = "\(viewModel.profileModel.value?.totalSpace ?? 0)" + "гб".localized
        let attr = [NSAttributedString.Key.font: Constants.Fonts.secondHeader, NSAttributedString.Key.foregroundColor: UIColor(named: "Bttn")]
        pieChart.centerAttributedText = NSAttributedString(string: str, attributes: attr as [NSAttributedString.Key : Any])
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(pieChart)
        view.addSubview(firstCircleView)
        view.addSubview(secondCircleView)
        view.addSubview(busySpaceLbl)
        view.addSubview(freeSpaceLbl)
        view.addSubview(publishedFilesBttn)
        view.addSubview(networkView)
        
        pieChart.translatesAutoresizingMaskIntoConstraints = false
        pieChart.widthAnchor.constraint(equalToConstant: 211).isActive = true
        pieChart.heightAnchor.constraint(equalToConstant: 211).isActive = true
        pieChart.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pieChart.topAnchor.constraint(equalTo: view.topAnchor, constant: 111).isActive = true
        
        firstCircleView.translatesAutoresizingMaskIntoConstraints = false
        firstCircleView.widthAnchor.constraint(equalToConstant: 21).isActive = true
        firstCircleView.heightAnchor.constraint(equalToConstant: 21).isActive = true
        firstCircleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        firstCircleView.topAnchor.constraint(equalTo: pieChart.bottomAnchor, constant: 10).isActive = true
        
        secondCircleView.translatesAutoresizingMaskIntoConstraints = false
        secondCircleView.widthAnchor.constraint(equalToConstant: 21).isActive = true
        secondCircleView.heightAnchor.constraint(equalToConstant: 21).isActive = true
        secondCircleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        secondCircleView.topAnchor.constraint(equalTo: firstCircleView.bottomAnchor, constant: 10).isActive = true
        
        busySpaceLbl.translatesAutoresizingMaskIntoConstraints = false
        busySpaceLbl.leadingAnchor.constraint(equalTo: firstCircleView.trailingAnchor, constant: 8).isActive = true
        busySpaceLbl.topAnchor.constraint(equalTo: firstCircleView.topAnchor).isActive = true
        busySpaceLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        freeSpaceLbl.translatesAutoresizingMaskIntoConstraints = false
        freeSpaceLbl.leadingAnchor.constraint(equalTo: secondCircleView.trailingAnchor, constant: 8).isActive = true
        freeSpaceLbl.topAnchor.constraint(equalTo: secondCircleView.topAnchor).isActive = true
        freeSpaceLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        publishedFilesBttn.translatesAutoresizingMaskIntoConstraints = false
        publishedFilesBttn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        publishedFilesBttn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        publishedFilesBttn.topAnchor.constraint(equalTo: secondCircleView.bottomAnchor, constant: 30).isActive = true
        publishedFilesBttn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        networkView.translatesAutoresizingMaskIntoConstraints = false
        networkView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        networkView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        networkView.topAnchor.constraint(equalTo: view.topAnchor, constant: 700).isActive = true
        networkView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -97).isActive = true
    }
    
    private func setupNav() {
        navigationController?.navigationBar.topItem?.title = "Профиль".localized
        let bttn = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(navBarBttnClicked))
        bttn.tintColor = Constants.Colors.details
        navigationController?.navigationBar.topItem?.rightBarButtonItem = bttn
    }
    
    private func createSegment(arcCenter: CGPoint, startAngle: CGFloat, endAngle: CGFloat) -> UIBezierPath {
        return UIBezierPath(arcCenter: arcCenter, radius: 11, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    }
    
    private func createCircle(arcCenter: CGPoint, startAngle: CGFloat, endAngle: CGFloat, color: CGColor) -> CAShapeLayer {
        let segmentPath = createSegment(arcCenter: arcCenter, startAngle: startAngle, endAngle: endAngle)
        let segmentLayer = CAShapeLayer()
        segmentLayer.path = segmentPath.cgPath
        segmentLayer.lineWidth = 1
        segmentLayer.fillColor = color
        return segmentLayer
    }
    
    @objc private func publishedFilesBttnClicked() {
        navigationController?.pushViewController(PublishedFilesViewController(), animated: true)
    }
    
    @objc private func navBarBttnClicked() {
        let actionSheet = UIAlertController(title: "Профиль".localized, message: nil, preferredStyle: .actionSheet)
        let actions: [UIAlertAction] = [
            UIAlertAction(title: "Выйти".localized,
                          style: .destructive,
                          handler: { [weak self] _ in
                              let alertController = UIAlertController(title: "Выход".localized,
                                                                      message: "Вы уверены, что хотите выйти?".localized,
                                                                      preferredStyle: .alert)
                              alertController.addAction(UIAlertAction(title: "Да".localized,
                                                                      style: .destructive,
                                                                      handler: { [weak self] _ in
                                  ClearData.deleteAll()
                                  let controller = LoginViewController()
                                  controller.modalTransitionStyle = .flipHorizontal
                                  controller.modalPresentationStyle = .fullScreen
                                  self?.present(controller, animated: true)
                              }))
                              alertController.addAction(UIAlertAction(title: "Нет".localized,
                                                                      style: .cancel))
                              self?.present(alertController, animated: true)
                          }),
            UIAlertAction(title: "Отмена".localized,
                          style: .cancel)
        ]
        actionSheet.addAction(actions[0])
        actionSheet.addAction(actions[1])
        present(actionSheet, animated: true)
    }
}
