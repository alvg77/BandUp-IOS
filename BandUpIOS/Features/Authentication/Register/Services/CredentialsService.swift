//
//  RegisterService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 15.12.23.
//

import Foundation

struct RegisterService {
    func checkUsernameAvailabilty(username: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let components = URLComponents(string: "http://localhost:9090/api/v1/auth/available/username")
        
        guard var url = components?.url else {
            print("Invalid URL")
            return
        }
        url.append(queryItems: [URLQueryItem(name: "username", value: username)])
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if error != nil {
                completion(.failure(error!))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("ploho")
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                completion(.success(true))
            default:
                completion(.success(false))
            }
        }
        task.resume()
    }
}
