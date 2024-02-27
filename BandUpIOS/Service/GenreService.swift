//
//  GenreFetchService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 13.12.23.
//

import Foundation
import Combine

protocol GenreServiceProtocol {
    func getGenres() -> AnyPublisher<[Genre], APIError>
}

class GenreService {
    static let shared: GenreServiceProtocol = GenreService()
    private init() { }
}

extension GenreService: GenreServiceProtocol {
    func getGenres() -> AnyPublisher<[Genre], APIError> {
        let endpoint = URL(string: "\(Secrets.baseApiURL)/genres")
        
        guard let endpoint = endpoint else {
            return Fail(error: APIError.invalidURLError).eraseToAnyPublisher()
        }
        
        return RequestHandler.makeRequest(request: URLRequest(url: endpoint))
            .decode(type: [Genre].self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                switch error {
                case is DecodingError:
                    return .decodingError
                case is APIError:
                    return error as! APIError
                default:
                    return .unknownError
                }
            }
            .eraseToAnyPublisher()
    }
}
