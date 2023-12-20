//
//  GenreFetchService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 13.12.23.
//

import Foundation

struct GenreFetchService {
    func getGenres(completion: @escaping (Result<[Genre], APIError>) -> Void) {
        let components = URLComponents(string: "http://localhost:9090/api/v1/genres")

        guard let url = components?.url else {
            completion(.failure(.invalidRequestError("Cannot construct url for the requested resource.")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(.failure(.transportError("Cant connect to the server. Please check your internet connection")))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            let decoder = JSONDecoder()
            if let data = data {
                if (200..<300) ~= httpResponse.statusCode {
                    do {
                        let genres = try decoder.decode([Genre].self, from: data)
                        completion(.success(genres))
                    } catch let error {
                        completion(.failure(.decodingError(error)))
                    }
                } else {
                    completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
                }
            }
        }
        task.resume()
    }
}
