//
//  NetworkManager.swift
//  GameOfLife
//
//  Created by Benjamin Hendricks on 5/1/17.
//  Copyright © 2017 coolbnjmn. All rights reserved.
//

import Foundation

class NetworkManager {
    static let shared: NetworkManager = NetworkManager()
    
    private init() {}
    
    func fetchDataFromURL(_ urlString: String, _ completion: @escaping ((_ success: Bool, _ json: Any?)->Void)) {
        
        guard let dataURL = URL(string: urlString) else {
            return
        }
        let fetcher = NetworkFetcher()
        fetcher.fetchJSON(url: dataURL) {
            (json: Any?, message: String?) in
            
            guard let json = json,
                message == nil else {
                let defaultMessage = "no json or message"
                print("no json, message: \(message ?? defaultMessage)")
                    DispatchQueue.main.async {
                        completion(false, nil)
                    }
                return
            }

            DispatchQueue.main.async {
                completion(true, json)
            }
        }
    }
}
