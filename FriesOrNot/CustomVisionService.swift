//
//  CustomVisionService.swift
//  FriesOrNot
//
//  Created by 中山湧水 on 2017/08/02.
//  Copyright © 2017年 中山湧水. All rights reserved.
//

import Foundation

class CustomVisionService {
    var preductionUrl = "https://southcentralus.api.cognitive.microsoft.com/customvision/v1.0/Prediction/7a14ec4a-f1b0-4cb8-a747-6888fff72fd9/image?iterationId=9cafb7fd-d2cb-4f96-8bb4-9a06ce7d5fd9"
    var predictionKey = "1a4f1fb2320f4fd9b78ba6d9b0ee7631"
    var contentType = "application/octet-stream"
    
    var defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    func predict(image: Data, completion: @escaping (CustomVisionResult?, Error?) -> Void) {
        
        // Create URL Request
        var urlRequest = URLRequest(url: URL(string: preductionUrl)!)
        urlRequest.addValue(predictionKey, forHTTPHeaderField: "Prediction-Key")
        urlRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        
        // Cancel existing dataTask if active
        dataTask?.cancel()
        
        // Create new dataTask to upload image
        dataTask = defaultSession.uploadTask(with: urlRequest, from: image) { data, response, error in
            defer { self.dataTask = nil }
            
            if let error = error {
                completion(nil, error)
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let result = try? CustomVisionResult(json: json!) {
                    completion(result, nil)
                }
            }
        }
        
        // Start the new dataTask
        dataTask?.resume()
    }
}
