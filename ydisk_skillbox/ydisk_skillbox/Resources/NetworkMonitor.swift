//
//  NetworkMonitor.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 25.09.2022.
//

import Foundation
import Network

struct NetworkMonitor {
    
    var isConnected: Observable<Bool> = Observable(nil)
    
    func monitorNetwork() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.isConnected.value = true
            } else {
                self.isConnected.value = false
            }
        }
        
        let queue = DispatchQueue(label: "Monitor", qos: .background)
        monitor.start(queue: queue)
    }
}
