//
//  FileViewController.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 30.09.2022.
//

import UIKit
import JGProgressHUD
import PDFKit
import WebKit
import ImageScrollView

class FileViewController: UIViewController {
    
    private let name: String
    private let date: String
    private let time: String
    private let path: String
    private let mediaType: String?
    private let mimeType: String?

    private let hud = JGProgressHUD(automaticStyle: ())
    
    private let viewModel = FileViewModel(container: (UIApplication.shared.delegate as!
                                                      AppDelegate).persistentContainer)
    
    var onDelete: ((String) -> Void)?
    var onRename: ((String, String) -> Void)?
    
    init(name: String, date: String, time: String, path: String, mediaType: String?, mimeType: String?) {
        self.name = name
        self.date = date
        self.time = time
        self.path = path
        self.mediaType = mediaType
        self.mimeType = mimeType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        if Constants.Types.office.contains(self.mimeType!) ||
            self.mimeType == Constants.Types.pdf ||
            self.mediaType == Constants.Types.image
        {
            DispatchQueue.global(qos: .userInteractive).async {
                self.viewModel.fetchData(path: self.path)
                DispatchQueue.main.async {
                    self.hud.show(in: self.view, animated: true)
                }
            }
        } else {
            DispatchQueue.main.async {
                let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
                lbl.text = "Файл не поддерживается".localized
                lbl.textAlignment = .center
                self.view.addSubview(lbl)
                lbl.center = self.view.center
            }
        }
        
        viewModel.data.bind { [weak self] _ in
            if self?.viewModel.data.value != nil {
                self?.setupData()
                DispatchQueue.main.async {
                    self?.hud.dismiss(animated: true)
                }
            }
        }
        
        setupNavBar()
    }
    
    private func setupNavBar() {
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(menuBarButtonTapped)
        )
        menuButton.tintColor = Constants.Colors.details
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(shareBarButtonTapped))
        shareButton.tintColor = Constants.Colors.details
        navigationItem.rightBarButtonItems = [
            menuButton,
            shareButton
        ]
        navigationItem.title = name
        navigationItem.prompt = "\(date) \(time)"
        navigationController?.navigationBar.tintColor = Constants.Colors.details
    }
    
    private func setupData() {
        if self.mediaType == Constants.Types.image {
            DispatchQueue.main.async {
                let imageView = ImageScrollView()
                imageView.setup()
                imageView.frame = self.view.bounds
                imageView.display(image: UIImage(data: self.viewModel.data.value!) ?? UIImage())
                self.view.addSubview(imageView)
            }
        } else if self.mimeType == Constants.Types.pdf {
            DispatchQueue.main.async {
                let pdfView = PDFView()
                pdfView.document = PDFDocument(data: self.viewModel.data.value!)
                self.view.addSubview(pdfView)
                pdfView.frame = self.view.bounds
                pdfView.autoScales = true
            }
        } else if Constants.Types.office.contains(self.mimeType!) {
            DispatchQueue.main.async {
                let webView = UIWebView()
                webView.load(self.viewModel.data.value!, mimeType: self.mimeType!, textEncodingName: "UTF-8", baseURL: Bundle.main.bundleURL)
                self.view.addSubview(webView)
                webView.frame = self.view.bounds
                webView.scalesPageToFit = true
                
            }
        }
    }
    
    @objc private func menuBarButtonTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItems?.first
        actionSheet.popoverPresentationController?.permittedArrowDirections = .any
        let actions: [UIAlertAction] = [
            UIAlertAction(title: "Удалить".localized,
                          style: .destructive,
                          handler: { [weak self] _ in
                              let alertController = UIAlertController(title: "Удалить".localized,
                                                                      message: "Вы уверены, что хотите удалить файл?".localized,
                                                                      preferredStyle: .alert)
                              alertController.addAction(UIAlertAction(title: "Да".localized,
                                                                      style: .destructive,
                                                                      handler: { [weak self] _ in
                                  self?.hud.show(in: self?.view ?? UIView(), animated: true)
                                  DispatchQueue.global(qos: .userInteractive).async {
                                      self?.viewModel.deleteFile(path: self?.path ?? "", completion: { [weak self] statusCode in
                                          DispatchQueue.main.async {
                                              self?.hud.dismiss(animated: true)
                                              if statusCode == 0 {
                                                  let alert = UIAlertController(title: "Ошибка".localized, message: "Не удалось удалить файл".localized, preferredStyle: .alert)
                                                  alert.addAction(UIAlertAction(title: "Ок".localized, style: .default))
                                                  self?.present(alert, animated: true)
                                                  return
                                              }
                                              self?.onDelete?(self?.path ?? "")
                                              self?.navigationController?.popViewController(animated: true)
                                          }
                                      })
                                  }
                              }))
                              alertController.addAction(UIAlertAction(title: "Нет".localized,
                                                                      style: .cancel))
                              self?.present(alertController, animated: true)
                          }),
            UIAlertAction(title: "Переименовать".localized,
                          style: .default,
                          handler: { [weak self] _ in
                              let alertController = UIAlertController(title: "Переименовать".localized, message: nil, preferredStyle: .alert)
                              alertController.addTextField()
                              let actions = [
                                UIAlertAction(title: "Переименовать".localized, style: .default, handler: { [weak self] _ in
                                    guard let name = alertController.textFields?[0].text else { return }
                                    self?.hud.show(in: self?.view ?? UIView(), animated: true)
                                    DispatchQueue.global(qos: .userInteractive).async {
                                        self?.viewModel.rename(path: self?.path ?? "",
                                                               newName: name,
                                                               completion: { [weak self] statusCode in
                                            DispatchQueue.main.async {
                                                self?.hud.dismiss(animated: true)
                                                if statusCode == 0 {
                                                    let alert = UIAlertController(title: "Ошибка".localized, message: "Не удалось переименовать файл".localized, preferredStyle: .alert)
                                                    alert.addAction(UIAlertAction(title: "Ок".localized, style: .default))
                                                    self?.present(alert, animated: true)
                                                    return
                                                }
                                                let nsPath = self?.path as NSString?
                                                let nsName = name as NSString
                                                guard let newName = nsName.appendingPathExtension(nsPath?.pathExtension ?? "") else { return }
                                                self?.navigationItem.title = newName
                                                self?.onRename?(self?.path ?? "", newName)
                                            }
                                        })
                                    }
                                }),
                                UIAlertAction(title: "Отмена".localized, style: .cancel)
                              ]
                              alertController.addAction(actions[0])
                              alertController.addAction(actions[1])
                              
                              self?.present(alertController, animated: true)
                          }),
            UIAlertAction(title: "Отмена".localized,
                          style: .cancel)
        ]
        actionSheet.addAction(actions[0])
        actionSheet.addAction(actions[1])
        actionSheet.addAction(actions[2])
        present(actionSheet, animated: true)
    }
    
    @objc private func shareBarButtonTapped() {
        let actionSheet = UIAlertController(title: "Поделиться".localized, message: nil, preferredStyle: .actionSheet)
        actionSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItems?.last
        actionSheet.popoverPresentationController?.permittedArrowDirections = .any
        let actions: [UIAlertAction] = [
            UIAlertAction(title: "Поедлиться файлом".localized,
                          style: .default,
                          handler: { [weak self] _ in
                              guard let strongSelf = self else { return }
                              self?.hud.show(in: strongSelf.view, animated: true)
                              DispatchQueue.global(qos: .userInteractive).async {
                                  self?.viewModel.returnData(path: self?.path ?? "", completion: { [weak self] item in
                                      DispatchQueue.main.async {
                                          self?.hud.dismiss(animated: true)
                                          let activityVC = UIActivityViewController(activityItems: [item], applicationActivities: nil)
                                          activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
                                          activityVC.popoverPresentationController?.barButtonItem = self?.navigationItem.rightBarButtonItems?.last
                                          activityVC.popoverPresentationController?.permittedArrowDirections = .any
                                          self?.present(activityVC, animated: true, completion: nil)
                                      }
                                  })
                              }
                          }),
            UIAlertAction(title: "Поделиться ссылкой".localized,
                          style: .default,
                          handler: { [weak self] _ in
                              let alert = UIAlertController(title: "Поделиться ссылкой".localized,
                                                            message: "Файл станет публичным, хотите продолжить?".localized,
                                                            preferredStyle: .alert)
                              let actions: [UIAlertAction] = [
                                UIAlertAction(title: "Нет".localized,
                                              style: .destructive),
                                UIAlertAction(title: "Да".localized,
                                              style: .default,
                                              handler: { [weak self] _ in
                                                  self?.hud.show(in: self?.view ?? UIView(), animated: true)
                                                  DispatchQueue.global(qos: .userInteractive).async {
                                                      self?.viewModel.getLink(path: self?.path ?? "", completion: { [weak self] url in
                                                          DispatchQueue.main.async {
                                                              self?.hud.dismiss(animated: true)
                                                              let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                                                              activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
                                                              activityVC.popoverPresentationController?.barButtonItem = self?.navigationItem.rightBarButtonItems?.last
                                                              activityVC.popoverPresentationController?.permittedArrowDirections = .any
                                                              self?.present(activityVC, animated: true, completion: nil)
                                                          }
                                                      })
                                                  }
                                              })
                              ]
                              alert.addAction(actions[0])
                              alert.addAction(actions[1])
                              self?.present(alert, animated: true)
                          }),
            UIAlertAction(title: "Отмена".localized,
                          style: .cancel)
        ]
        actionSheet.addAction(actions[0])
        actionSheet.addAction(actions[1])
        actionSheet.addAction(actions[2])
        present(actionSheet, animated: true)
    }
}
