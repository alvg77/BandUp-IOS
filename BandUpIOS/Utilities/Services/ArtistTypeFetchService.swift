//
//  ArtistTypeFetchService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 13.12.23.
//

import Foundation

struct ArtistTypeFetchService {
    func getArtistTypes(completion: @escaping (Result<[ArtistType], APIError>) -> Void) {
        let components = URLComponents(string: "http://localhost:9090/api/v1/artist-types")

        guard let url = components?.url else {
            completion(.failure(.invalidRequestError("Cannot build url for resource.")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(.failure(.transportError("Can't connect to the server. Please check your internet connection.")))
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
                        let artistTypes = try decoder.decode([ArtistType].self, from: data)
                        completion(.success(artistTypes))
                    } catch let error {
                        completion(.failure(.decodingError(error)))
                    }
                } else {
                    do {
                        let apiError = try decoder.decode(APIErrorMessage.self, from: data)
                        completion(.failure(.serverError(statusCode: httpResponse.statusCode, reason: apiError.reason)))
                    } catch let error {
                        completion(.failure(.decodingError(error)))
                    }
                }
            }
        }
        task.resume()
    }
}
