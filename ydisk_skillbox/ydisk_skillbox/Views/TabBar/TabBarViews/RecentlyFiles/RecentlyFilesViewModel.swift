//
//  RecentlyFilesViewModel.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 16.09.2022.
//

import Foundation
import CoreData

struct RecentlyFilesViewModel {
    var recenltyFilesModel: Observable<[TableViewCellModel]> = Observable([])
    private let persistentContainer: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        createFolder()
    }
    
    func fetch(completionHandler: @escaping (Int) -> Void) {
        createFolder()
        
        guard let url = URL(string: "https://cloud-api.yandex.net/v1/disk/resources/last-uploaded") else { return }
        
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
                    getAllFiles()
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
                let files = try JSONDecoder().decode(FilesData.self, from: data)
                var recentlyFiles = [TableViewCellModel]()
                
                deleteAllFiles()
                
                for item in files.items {
                    
                    var preview: Data? = nil
                    var date: String? = nil
                    var time: String? = nil
                    
                    if let urlString = item.preview {
                        if let url = URL(string: urlString) {
                            do {
                                let previewData = try Data(contentsOf: url)
                                preview = previewData
                            } catch {
                                preview = nil
                            }
                        }
                    }
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-mm-dd'T'HH:mm:ssZ"
                    
                    if let fullDate = formatter.date(from: item.created) {
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale.current
                        dateFormatter.setLocalizedDateFormatFromTemplate("dd:MM:yyyy")
                        date = dateFormatter.string(from: fullDate)
                        
                        let timeFormatter = DateFormatter()
                        timeFormatter.locale = Locale.current
                        timeFormatter.dateStyle = .none
                        timeFormatter.timeStyle = .short
                        time = timeFormatter.string(from: fullDate)
                    }
                    
                    let file = TableViewCellModel(preview: preview,
                                                      name: item.name,
                                                      date: date,
                                                      time: time ,
                                                      size: item.size,
                                                      type: item.type,
                                                      mediaType: item.mediaType,
                                                      mimeType: item.mimeType,
                                                      path: item.path)
                    
                    addFile(preview: preview,
                            name: item.name,
                            date: date ?? "",
                            time: time ?? "",
                            size: item.size ?? 0,
                            type: item.type,
                            mediaType: item.mediaType ?? "",
                            mimeType: item.mimeType ?? "",
                            path: item.path)
                    
                    recentlyFiles.append(file)
                }
                
                recenltyFilesModel.value = recentlyFiles
                
                completionHandler(resp.statusCode)
            } catch let error {
                print(error)
                completionHandler(527)
            }
        })
        
        task.resume()
    }
}

// MARK: - CoreData

extension RecentlyFilesViewModel {
    
    private func getAllFiles() {
        persistentContainer.performBackgroundTask() { (context) in
            var returnFiles: [TableViewCellModel] = []
            let folderFetchRequest = FolderItem.fetchRequest() as NSFetchRequest<FolderItem>
            folderFetchRequest.predicate = NSPredicate(format: "path == 'Recently'")
            let folder = try! context.fetch(folderFetchRequest)
            if let items = folder[0].items,
               items.count > 0 {
                for item in items {
                    let file = item as! TableViewCellItem
                    returnFiles.append(TableViewCellModel(preview: file.preview,
                                                              name: file.name ?? "",
                                                              date: file.date,
                                                              time: file.time,
                                                              size: file.size != 0 ? Int(file.size) : nil,
                                                              type: file.type ?? "",
                                                              mediaType: file.mediaType,
                                                              mimeType: file.mimeType,
                                                              path: file.path ?? "")
                    )
                }
            }
            recenltyFilesModel.value = returnFiles
        }
    }
    
    private func createFolder() {
        persistentContainer.performBackgroundTask() { (context) in
            do {
                let request = FolderItem.fetchRequest() as NSFetchRequest<FolderItem>
                let pred = NSPredicate(format: "path == 'Recently'")
                request.predicate = pred
                let item = try context.fetch(request)
                if item.isEmpty {
                    let newFolder = FolderItem(context: context)
                    newFolder.path = "Recently"
                    if context.hasChanges {
                        do {
                            try context.save()
                        }
                        catch {
                            // error
                        }
                    }
                }
            }
            catch {
                // error
            }
        }
    }
    
    private func addFile(preview: Data?,
                         name: String,
                         date: String,
                         time: String ,
                         size: Int,
                         type: String,
                         mediaType: String,
                         mimeType: String,
                         path: String) {
        isEntityAttributeExist(path: path, completion: { (exist) in
            persistentContainer.performBackgroundTask() { (context) in
                if !exist {
                    let newItem = TableViewCellItem(context: context)
                    newItem.preview = preview
                    newItem.name = name
                    newItem.date = date
                    newItem.time = time
                    newItem.size = Int64(size)
                    newItem.type = type
                    newItem.mediaType = mediaType
                    newItem.mimeType = mimeType
                    newItem.path = path
                    let folderFetchRequest = FolderItem.fetchRequest() as NSFetchRequest<FolderItem>
                    folderFetchRequest.predicate = NSPredicate(format: "path == 'Recently'")
                    let folder = try! context.fetch(folderFetchRequest)
                    newItem.addToFolder(folder[0])
                } else {
                    let itemFetchRequest = TableViewCellItem.fetchRequest() as NSFetchRequest<TableViewCellItem>
                    itemFetchRequest.predicate = NSPredicate(format: "path == %@", path)
                    let item = try! context.fetch(itemFetchRequest)
                    let folderFetchRequest = FolderItem.fetchRequest() as NSFetchRequest<FolderItem>
                    folderFetchRequest.predicate = NSPredicate(format: "path == 'Recently'")
                    let folder = try! context.fetch(folderFetchRequest)
                    if !(folder[0].items!.contains(item[0])) {
                        item[0].addToFolder([folder[0]])
                    }
                }
                
                if context.hasChanges {
                    do {
                        try context.save()
                    }
                    catch {
                        
                    }
                }
            }
        })
    }
    
    func deleteFile(path: String) {
        persistentContainer.performBackgroundTask() { (context) in
            let itemFetchRequest = TableViewCellItem.fetchRequest() as NSFetchRequest<TableViewCellItem>
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
    
    func renameFile(path: String, newName: String) {
        persistentContainer.performBackgroundTask() { (context) in
            let itemFetchRequest = TableViewCellItem.fetchRequest() as NSFetchRequest<TableViewCellItem>
            itemFetchRequest.predicate = NSPredicate(format: "path == %@", path)
            let item = try! context.fetch(itemFetchRequest)
            item[0].name = newName
            
            if context.hasChanges {
                do {
                    try context.save()
                }
                catch {
                    
                }
            }
        }
    }
    
    private func deleteAllFiles() {
        persistentContainer.performBackgroundTask() { (context) in
            let folderFetchRequest = FolderItem.fetchRequest() as NSFetchRequest<FolderItem>
            folderFetchRequest.predicate = NSPredicate(format: "path == 'Recently'")
            let folder = try! context.fetch(folderFetchRequest)
            if let items = folder[0].items,
               items.count > 0 {
                for item in items {
                    (item as! TableViewCellItem).removeFromFolder(folder[0])
                }
            }
            
            folder[0].items = NSSet()
            
            if context.hasChanges {
                do {
                    try context.save()
                }
                catch {
                    
                }
            }
        }
    }
    
    func isEntityAttributeExist(path: String, completion: @escaping (Bool) -> Void) {
        persistentContainer.performBackgroundTask() { (context) in
            let fetchRequest = TableViewCellItem.fetchRequest() as NSFetchRequest<TableViewCellItem>
            fetchRequest.predicate = NSPredicate(format: "path == %@", path)
            let res = try! context.fetch(fetchRequest)
            completion(res.count > 0 ? true : false)
        }
    }
}
