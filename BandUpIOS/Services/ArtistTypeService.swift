//
//  ArtistTypeFetchService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 13.12.23.
//

import Foundation
import Combine
import Alamofire

protocol ArtistTypeServiceProtocol {
    func getArtistTypes(completion: @escaping (Result<[ArtistType], APIError>) -> Void)
}

class ArtistTypeService {
    static let shared: ArtistTypeServiceProtocol = ArtistTypeService()
    private init() { }
}

extension ArtistTypeService: ArtistTypeServiceProtocol {
    func getArtistTypes(completion: @escaping (Result<[ArtistType], APIError>) -> Void) {
        let url = URL(string: "http://localhost:9090/api/v1/artist-types")
        
        guard let url = url else {
            completion(.failure(.invalidURLError))
            return
        }
        
        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: [ArtistType].self) { response in
                switch response.result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    if let errorMessage = response.data.flatMap({ try? JSONDecoder().decode(APIErrorMessage.self, from: $0) }) {
                        completion(.failure(.serverError(statusCode: errorMessage.status, reason: errorMessage.detail)))
                        return
                    }
                    if let code = error.responseCode {
                        completion(.failure(.serverError(statusCode: code)))
                        return
                    }
                    if error.isSessionTaskError {
                        completion(.failure(.noInternetError))
                        return
                    }
                    if error.isResponseSerializationError {
                        completion(.failure(.decodingError))
                        return
                    }
                    completion(.failure(.unknownError))
                }
            }
    }
}
