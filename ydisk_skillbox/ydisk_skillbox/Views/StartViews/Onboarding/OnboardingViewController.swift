//
//  OnboardingViewController.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 18.07.2022.
//

import UIKit

class OnboardingViewController: UIViewController {

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.isPagingEnabled = true
        view.backgroundColor = .systemBackground
        return view
    }()
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = Constants.Colors.firstAccent
        pageControl.currentPage = 0
        pageControl.numberOfPages = 3
        pageControl.pageIndicatorTintColor = Constants.Colors.details
        pageControl.backgroundColor = .systemBackground
        pageControl.addTarget(self, action: #selector(pageControlSelectionAction), for: .valueChanged)
        return pageControl
    }()
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Далее".localized, for: .normal)
        button.titleLabel?.font = Constants.Fonts.button
        button.titleLabel?.textColor = Constants.Colors.white
        button.backgroundColor = Constants.Colors.firstAccent
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        return button
    }()
    
    var currentPage = 0
    
    var slides: [OnboardingSlideModel] = [
        OnboardingSlideModel(title: "Теперь все ваши\nдокументы в одном месте".localized,
                        image: UIImage(named: "Folders") ?? UIImage()),
        OnboardingSlideModel(title: "Доступ к файлам без\nинтернета".localized,
                        image: UIImage(named: "Folder") ?? UIImage()),
        OnboardingSlideModel(title: "Делитесь вашими файлами\nс другими".localized,
                        image: UIImage(named: "Pencil") ?? UIImage())
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(OnboardingCollectionViewCell.self, forCellWithReuseIdentifier: OnboardingCollectionViewCell.identifier)
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(button)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupConstraints()
    }
    
    @objc private func buttonClicked(_ sender: Any) {
        if currentPage == slides.count - 1 {
            UserDefaults.standard.hasOnboarded = true
            let controller = LoginViewController()
            controller.modalTransitionStyle = .flipHorizontal
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true)
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        let width = collectionView.frame.width
        pageControl.currentPage = Int(collectionView.contentOffset.x / width) + 1
    }
    
    @objc private func pageControlSelectionAction(_ sender: UIPageControl) {
        let indexPath = IndexPath(item: sender.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    private func setupConstraints() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 620.12).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -183.47).isActive = true
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: 0).isActive = true
        
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 27.5).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -27.5).isActive = true
        button.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 41.47).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -92).isActive = true
    }
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        cell.setup(slides[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
        pageControl.currentPage = currentPage
    }
}
