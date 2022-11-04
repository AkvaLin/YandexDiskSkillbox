//
//  ProfileViewModel.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 15.09.2022.
//

import Foundation

struct ProfileViewModel {
    var profileModel: Observable<ProfileModel> = Observable(ProfileModel(freeSpace: 0,
                                                                         usedSpace: 0,
                                                                         totalSpace: 0))
    
    func fetchUserData(completionHandler: @escaping (Int) -> Void) {
        self.profileModel.value = ProfileModel(freeSpace: UserDefaults.standard.freeSpace ?? 0,
                                               usedSpace: UserDefaults.standard.usedSpace ?? 0,
                                               totalSpace: UserDefaults.standard.totalSpace ?? 0)
        
        guard let url = URL(string: "https://cloud-api.yandex.net/v1/disk/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "Authorization": "OAuth \(UserDefaults.standard.token ?? "")"
        ]
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            guard error == nil else {
                let str: String? = "The Internet connection appears to be offline."
                if error?.localizedDescription == str {
                    completionHandler(0)
                }
                return
            }
            let resp = response as! HTTPURLResponse
            if resp.statusCode == 401 {
                completionHandler(resp.statusCode)
                return
            }
            guard let data = data else {
                completionHandler(resp.statusCode)
                return
            }
            
            do {
                let userData = try JSONDecoder().decode(UserData.self, from: data)
                
                self.profileModel.value = ProfileModel(freeSpace: Units(bytes: Int64(userData.totalSpace - userData.usedSpace)).getDouble(),
                                                       usedSpace: Units(bytes: Int64(userData.usedSpace)).getDouble(),
                                                       totalSpace: Int(Units(bytes: Int64(userData.totalSpace)).getDouble()))
                
                UserDefaults.standard.freeSpace = self.profileModel.value?.freeSpace
                UserDefaults.standard.usedSpace = self.profileModel.value?.usedSpace
                UserDefaults.standard.totalSpace = self.profileModel.value?.totalSpace
                completionHandler(resp.statusCode)
            } catch let error {
                print(error)
                completionHandler(527)
            }
        })
        
        task.resume()
    }
}
