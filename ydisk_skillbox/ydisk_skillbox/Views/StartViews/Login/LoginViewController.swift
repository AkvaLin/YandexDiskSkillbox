//
//  LoginViewController.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 31.08.2022.
//

import UIKit
import WebKit

class LoginViewController: UIViewController {
    
    let webView = WKWebView()

    override func viewDidLoad() {
        
        DispatchQueue.main.async {
            URLCache.shared.removeAllCachedResponses()
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                }
            }
        }
        
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        webView.backgroundColor = .systemBackground
        view.backgroundColor = .systemBackground
        view.addSubview(webView)
        
        guard let url = URL(string: "https://oauth.yandex.ru/authorize?response_type=token&client_id=f2fb790964524341b46b69609b0d9928") else { return }
        
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: url))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webView.frame = view.bounds
    }
}

extension LoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void)) {

       if let url = navigationAction.request.url {
               if url.absoluteString.hasPrefix("https://oauth.yandex.ru/verification_code#access_token=") {
                   webView.removeFromSuperview()
                   guard let token = url.absoluteString.components(separatedBy: "token=").last?.components(separatedBy: "&").first else { return }
                   UserDefaults.standard.token = token
                   DispatchQueue.main.async {
                       let controller = TabBarController()
                       controller.modalTransitionStyle = .flipHorizontal
                       controller.modalPresentationStyle = .fullScreen
                       self.present(controller, animated: true)
                   }
               }
       }

       decisionHandler(.allow)
   }
}
