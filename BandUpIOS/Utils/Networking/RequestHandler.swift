//
//  RequestHandler.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import Foundation

struct RequestHandler {
    static func makeRequest(request: URLRequest, completion: @escaping (Result<Data?, APIError>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error as? URLError {
                completion(.failure(error.toAPIError()))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponseError))
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            switch statusCode {
            case 200..<300:
                completion(.success(data))
            case 401:
                completion(.failure(.unauthorized))
                if let data = data {
                    completion(.failure(APIErrorMessage.getServerError(data: data)))
                } else {
                    completion(.failure(.invalidResponseError))
                }
            default:
                completion(.failure(.unknownError))
            }
        }.resume()
    }
}
