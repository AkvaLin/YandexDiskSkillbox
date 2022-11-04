//
//  PublishedFilesViewController.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 30.08.2022.
//

import UIKit
import JGProgressHUD
import SwiftyButton

class PublishedFilesViewController: UIViewController {
    
    private let hud = JGProgressHUD(automaticStyle: ())
    
    private let tableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        view.backgroundColor = .systemBackground
        return view
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
    
    private let noFilesImageView: UIImageView = {
        let view = UIImageView()
        let image = UIImage(named: "NoFiles")!
        view.image = image
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()
    
    private let noFilesLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "У вас пока нет\nопубликованных файлов".localized
        lbl.font = Constants.Fonts.secondHeader
        lbl.textAlignment = .center
        lbl.lineBreakMode = .byWordWrapping
        lbl.numberOfLines = 0
        lbl.isHidden = true
        return lbl
    }()
    
    private lazy var updateButton: FlatButton = {
        let bttn = FlatButton()
        bttn.highlightedColor = .clear
        bttn.color = Constants.Colors.secondAccent!
        bttn.addTarget(self, action: #selector(refreshDataWithButton), for: .touchUpInside)
        bttn.cornerRadius = 10
        bttn.setTitle("Обновить".localized, for: .normal)
        bttn.titleLabel?.font = Constants.Fonts.button
        bttn.setTitleColor(UIColor(named: "Bttn"), for: .normal)
        bttn.isHidden = true
        return bttn
    }()
    
    private let refreshControl = UIRefreshControl()
    
    private let viewModel = PublishedFilesViewModel(container: (UIApplication.shared.delegate as!
                                                                AppDelegate).persistentContainer)

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = Constants.Colors.details
        navigationItem.title = "Опубликованные файлы".localized
        
        tableView.register(TableViewCellWithButton.self, forCellReuseIdentifier: TableViewCellWithButton.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        let loadingNib = UINib(nibName: "TableViewLoadingCell", bundle: nil)
        tableView.register(loadingNib, forCellReuseIdentifier: "loadingCell")
        
        setupViews()
        setupRefreshControl()
        
        firstFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
        
        viewModel.publishedFilesModel.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
                self?.hud.dismiss(animated: true)
                if let value = self?.viewModel.publishedFilesModel.value {
                    if value.isEmpty {
                        self?.noFilesImageView.isHidden = false
                        self?.noFilesLbl.isHidden = false
                        self?.updateButton.isHidden = false
                        self?.tableView.isHidden = true
                    } else {
                        self?.noFilesImageView.isHidden = true
                        self?.noFilesLbl.isHidden = true
                        self?.updateButton.isHidden = true
                        self?.tableView.isHidden = false
                    }
                }
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupViews()
    }
    
    // MARK: - View Setup
    
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(networkView)
        view.addSubview(noFilesImageView)
        view.addSubview(noFilesLbl)
        view.addSubview(updateButton)
        
        tableView.frame = view.bounds
        
        networkView.translatesAutoresizingMaskIntoConstraints = false
        networkView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        networkView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        networkView.topAnchor.constraint(equalTo: view.topAnchor, constant: 700).isActive = true
        networkView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -97).isActive = true
        
        noFilesImageView.translatesAutoresizingMaskIntoConstraints = false
        noFilesImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -441).isActive = true
        noFilesImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -108).isActive = true
        noFilesImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 108).isActive = true
        noFilesImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 209).isActive = true
        
        noFilesLbl.translatesAutoresizingMaskIntoConstraints = false
        noFilesLbl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -368).isActive = true
        noFilesLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -57).isActive = true
        noFilesLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 57).isActive = true
        noFilesLbl.topAnchor.constraint(equalTo: noFilesImageView.bottomAnchor, constant: 35).isActive = true
        
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        updateButton.bottomAnchor.constraint(equalTo: networkView.topAnchor, constant: -10).isActive = true
        updateButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        updateButton.widthAnchor.constraint(equalToConstant: 320).isActive = true
        
        hud.textLabel.text = "Загрузка...".localized
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
// MARK: - Network
    
    private func fetchData() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.viewModel.fetchData(completionHandler: { [weak self] statusCode in
                if statusCode == 401 {
                    ClearData.deleteAll()
                    DispatchQueue.main.async {
                        let controller = LoginViewController()
                        controller.modalTransitionStyle = .flipHorizontal
                        controller.modalPresentationStyle = .fullScreen
                        self?.present(controller, animated: true)
                    }
                } else if statusCode == 200 {

                } else if statusCode == 0 {
                    DispatchQueue.main.async {
                        self?.refreshControl.endRefreshing()
                    }
                } else {
                    print(statusCode)
                }
            })
        }
    }
    
    private func refresh() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.viewModel.updateData(completionHandler: { [weak self] statusCode in
                if statusCode == 401 {
                    ClearData.deleteAll()
                    DispatchQueue.main.async {
                        let controller = LoginViewController()
                        controller.modalTransitionStyle = .flipHorizontal
                        controller.modalPresentationStyle = .fullScreen
                        self?.present(controller, animated: true)
                    }
                } else if statusCode == 200 {

                } else if statusCode == 0 {
                    DispatchQueue.main.async {
                        self?.refreshControl.endRefreshing()
                    }
                } else {
                    print(statusCode)
                }
            })
        }
    }
    
    private func firstFetch() {
        hud.show(in: view, animated: true)
        fetchData()
    }
    
    @objc private func refreshData() {
        refresh()
    }
    
    @objc private func refreshDataWithButton() {
        hud.show(in: view, animated: true)
        refresh()
    }
}

// MARK: - TableViewDataSource

extension PublishedFilesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.publishedFilesModel.value?.count ?? 0
        } else if section == 1 && viewModel.isFetchInProgress.value! {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellWithButton.identifier,
                                                     for: indexPath) as! TableViewCellWithButton
            
            var image = UIImage()
            let name = viewModel.publishedFilesModel.value?[indexPath.row].name ?? ""
            let size = viewModel.publishedFilesModel.value?[indexPath.row].size != nil ? Units(bytes: Int64((viewModel.publishedFilesModel.value?[indexPath.row].size)!)).getReadableUnit() : ""
            let date = viewModel.publishedFilesModel.value?[indexPath.row].date ?? ""
            let time = viewModel.publishedFilesModel.value?[indexPath.row].time ?? ""
            
            if let data = viewModel.publishedFilesModel.value?[indexPath.row].preview {
                image = UIImage(data: data) ?? UIImage(systemName: "questionmark.app")!
            } else {
                if viewModel.publishedFilesModel.value?[indexPath.row].type == "dir" {
                    image = UIImage(systemName: "folder.fill")!
                } else if viewModel.publishedFilesModel.value?[indexPath.row].type == "file" {
                    image = UIImage(systemName: "doc.fill")!
                } else {
                    
                }
            }
            
            cell.configure(image: image,
                           name: name,
                           size: size,
                           date: date,
                           time: time)
            
            cell.delegate = self
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell") as! TableViewLoadingCell
            cell.spinner.startAnimating()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(60)
    }
}

// MARK: - TableViewDelegates

extension PublishedFilesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if viewModel.publishedFilesModel.value?[indexPath.row].type == "dir" {
            let vc = DirViewController(name: viewModel.publishedFilesModel.value?[indexPath.row].name ?? "",
                                       path: viewModel.publishedFilesModel.value?[indexPath.row].path ?? ""
            )
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = FileViewController(name: viewModel.publishedFilesModel.value?[indexPath.row].name ?? "",
                                        date: viewModel.publishedFilesModel.value?[indexPath.row].date ?? "",
                                        time: viewModel.publishedFilesModel.value?[indexPath.row].time ?? "",
                                        path: viewModel.publishedFilesModel.value?[indexPath.row].path ?? "",
                                        mediaType: viewModel.publishedFilesModel.value?[indexPath.row].mediaType ?? "",
                                        mimeType: viewModel.publishedFilesModel.value?[indexPath.row].mimeType ?? ""
            )
            vc.onDelete = { [weak self] path in
                self?.viewModel.publishedFilesModel.value?.remove(at: indexPath.item)
                self?.viewModel.deleteFile(path: path)
                tableView.deleteRows(at: [indexPath], with: .none)
            }
            vc.onRename = { [weak self] (path, name) in
                self?.viewModel.publishedFilesModel.value?[indexPath.item].name = name
                self?.viewModel.renameFile(path: path, newName: name)
                tableView.reloadData()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension PublishedFilesViewController: TableViewCellWithButtonDelegate {
    func didTapButton(_ tableViewCellWithButton: TableViewCellWithButton) {
        
        let alertController = UIAlertController(title: nil,
                                                message: "Вы уверены, что хотите убрать публикацию?".localized,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Да".localized,
                                                style: .destructive,
                                                handler: { [weak self] _ in
            
            guard let indexPathRow = self?.tableView.indexPath(for: tableViewCellWithButton)?.row else { return }
            guard let path = self?.viewModel.publishedFilesModel.value?[indexPathRow].path else { return }
            
            DispatchQueue.global(qos: .userInteractive).async {
                self?.viewModel.removePublication(path: path, completionHandler: { [weak self] statusCode in
                    if statusCode == 401 {
                        ClearData.deleteAll()
                        DispatchQueue.main.async {
                            let controller = LoginViewController()
                            controller.modalTransitionStyle = .flipHorizontal
                            controller.modalPresentationStyle = .fullScreen
                            self?.present(controller, animated: true)
                        }
                    } else if statusCode == 200 {
                        self?.fetchData()
                    } else if statusCode == 0 {
                        
                    } else {
                        print(statusCode)
                    }
                })
            }
        }))
        alertController.addAction(UIAlertAction(title: "Нет".localized,
                                                style: .cancel))
        self.present(alertController, animated: true)
    }
}

// MARK: - TableViewPrefetching

extension PublishedFilesViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.row >= viewModel.publishedFilesModel.value!.count - 15 {
                if !viewModel.isFetchInProgress.value! && viewModel.needToFetch.value! && tabBarController!.networkMonitor.isConnected.value! {
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
                    fetchData()
                }
            }
        }
    }
}
