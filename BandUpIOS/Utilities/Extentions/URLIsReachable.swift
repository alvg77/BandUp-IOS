//
//  URL+.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.12.23.
//

import Foundation

extension URL {
    func isReachable(completion: @escaping (Bool) -> ()) {
        var request = URLRequest(url: self)
        request.httpMethod = "HEAD"
        
        let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode == 200)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
}
