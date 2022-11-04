//
//  FileViewModel.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 30.09.2022.
//

import Foundation
import CoreData

struct FileViewModel {
    var data: Observable<Data> = Observable(nil)
    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.context = persistentContainer.viewContext
    }
    
    func fetchData(path: String) {
        guard let replaced = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        
        guard let url = URL(
            string: "https://cloud-api.yandex.net/v1/disk/resources/download?path=\(replaced)"
        ) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "Authorization": "OAuth \(UserDefaults.standard.token ?? "")"
        ]
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            guard error == nil else {
                let firstError: String? = "The Internet connection appears to be offline."
                let secondError: String? = "A data connection is not currently allowed."
                if error?.localizedDescription == firstError || error?.localizedDescription == secondError {
                    getData(path: path)
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let json = try JSONDecoder().decode(FileModel.self, from: data)
                let fileData = try Data(contentsOf: URL(string: json.href)!)
                self.data.value = fileData
                saveData(path: path, data: fileData)
            } catch {
                
            }
        })
        
        task.resume()
    }
    
    func returnData(path: String, completion: @escaping (Data) -> Void) {
        guard let replaced = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        
        guard let url = URL(
            string: "https://cloud-api.yandex.net/v1/disk/resources/download?path=\(replaced)"
        ) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "Authorization": "OAuth \(UserDefaults.standard.token ?? "")"
        ]
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data,
                error == nil
            else { return }
            
            do {
                let json = try JSONDecoder().decode(FileModel.self, from: data)
                let returnData = try Data(contentsOf: URL(string: json.href)!)
                completion(returnData)
            } catch {
                
            }
        })
        
        task.resume()
    }
    
    func getLink(path: String, completion: @escaping (URL) -> Void) {
        guard let replaced = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        
        guard let url = URL(
            string: "https://cloud-api.yandex.net/v1/disk/resources/publish?path=\(replaced)"
        ) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = [
            "Authorization": "OAuth \(UserDefaults.standard.token ?? "")"
        ]
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            guard let _ = data,
                error == nil
            else { return }

            guard let secondUrl = URL(string: "https://cloud-api.yandex.net/v1/disk/resources?path=\(replaced)") else { return }
            
            var secondRequest = URLRequest(url: secondUrl)
            secondRequest.httpMethod = "GET"
            secondRequest.allHTTPHeaderFields = [
                "Authorization": "OAuth \(UserDefaults.standard.token ?? "")"
            ]
            
            let secondTask = URLSession.shared.dataTask(with: secondRequest, completionHandler: { secondData, response, error in

                guard let secondData = secondData,
                    error == nil
                else { return }
                
                do {
                    let json = try JSONDecoder().decode(PublishedFileModel.self, from: secondData)
                    guard let returnUrl = URL(string: json.publicUrl) else { return }
                    completion(returnUrl)
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
            })
            
            secondTask.resume()
        })
        
        task.resume()
    }
    
    func deleteFile(path: String, completion: @escaping (Int) -> Void) {
        
        guard let replaced = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        
        guard let url = URL(
            string: "https://cloud-api.yandex.net/v1/disk/resources?path=\(replaced)"
        ) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = [
            "Authorization": "OAuth \(UserDefaults.standard.token ?? "")"
        ]
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard let _ = data,
                error == nil
            else {
                completion(0)
                return
            }
            
            let resp = response as! HTTPURLResponse
            
            completion(resp.statusCode)
        })
        
        deleteData(path: path)
        
        task.resume()
    }
    
    func rename(path: String, newName: String, completion: @escaping (Int) -> Void) {
        var nsPath = path as NSString
        let ext = nsPath.pathExtension
        nsPath = nsPath.deletingPathExtension as NSString
        nsPath = nsPath.deletingLastPathComponent as NSString
        nsPath = nsPath.appendingPathComponent(newName) as NSString
        let finalPath = nsPath.appendingPathExtension(ext)
        
        guard let replacedFrom = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        guard let replacedPath = finalPath?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        
        guard let url = URL(
            string: "https://cloud-api.yandex.net/v1/disk/resources/move?from=\(replacedFrom)&path=\(replacedPath)"
        ) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Authorization": "OAuth \(UserDefaults.standard.token ?? "")"
        ]
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard let _ = data,
                error == nil
            else {
                completion(0)
                return
            }
            
            let resp = response as! HTTPURLResponse
            
            completion(resp.statusCode)
        })
        
        task.resume()
    }
}

// MARK: -CoreData

extension FileViewModel {
    
    private func getData(path: String) {
        let itemFetchRequest = FileItem.fetchRequest() as NSFetchRequest<FileItem>
        itemFetchRequest.predicate = NSPredicate(format: "path == %@", path)
        let item = try! context.fetch(itemFetchRequest)
        if !item.isEmpty {
            data.value = item[0].data
        }
    }
    
    private func saveData(path: String, data: Data) {
        
        let file = FileItem(context: context)
        file.data = data
        file.path = path
        
        if context.hasChanges {
            do {
                try context.save()
            }
            catch {
                
            }
        }
    }
    
    private func deleteData(path: String) {
        
        let itemFetchRequest = FileItem.fetchRequest() as NSFetchRequest<FileItem>
        itemFetchRequest.predicate = NSPredicate(format: "path == %@", path)
        let item = try! context.fetch(itemFetchRequest)
        
        context.delete(item[0])
        
        if context.hasChanges {
            do {
                try context.save()
            }
            catch {
                
            }
        }
    }
}
