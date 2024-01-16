//
//  ArtistTypeFetchService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 13.12.23.
//

import Foundation

protocol ArtistTypeServiceProtocol {
    func getArtistTypes(completion: @escaping (Result<[ArtistType], APIError>) -> Void)
}

class ArtistTypeService {
    static let shared: ArtistTypeServiceProtocol = ArtistTypeService()
    private init() { }
}

extension ArtistTypeService: ArtistTypeServiceProtocol {
    func getArtistTypes(completion: @escaping (Result<[ArtistType], APIError>) -> Void) {
        let endpoint = URL(string: "http://localhost:9090/api/v1/artist-types")
        
        guard let endpoint = endpoint else {
            completion(.failure(.invalidURLError))
            return
        }
        
        URLSession.shared.dataTask(with: endpoint) { data, response, error in
            if let error = error as? URLError {
                completion(.failure(error.toAPIError()))
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponseError))
                return
            }

            let statusCode = httpResponse.statusCode
            if let data = data {
                switch statusCode {
                case 200..<300:
                    do {
                        let response = try JSONDecoder().decode([ArtistType].self, from: data)
                        completion(.success(response))
                    } catch {
                        completion(.failure(.decodingError))
                    }
                case 400..<600:
                    print("Server Error Code: \(statusCode)")
                    completion(.failure(APIErrorMessage.getServerError(data: data)))
                default:
                    completion(.failure(.unknownError))
                }
            } else {
                completion(.failure(.invalidResponseError))
            }
        }.resume()
    }
}
