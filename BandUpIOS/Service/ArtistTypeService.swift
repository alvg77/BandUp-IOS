//
//  ArtistTypeFetchService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 13.12.23.
//

import Foundation
import Combine

protocol ArtistTypeServiceProtocol {
    func getArtistTypes() -> AnyPublisher<[ArtistType], APIError>
}

class ArtistTypeService {
    static let shared: ArtistTypeServiceProtocol = ArtistTypeService()
    private init() { }
}

extension ArtistTypeService: ArtistTypeServiceProtocol {
    func getArtistTypes() -> AnyPublisher<[ArtistType], APIError> {
        let endpoint = URL(string: "\(Secrets.baseApiURL)/artist-types")
        
        guard let endpoint = endpoint else {
            return Fail(error: APIError.invalidURLError).eraseToAnyPublisher()
        }
        
        return RequestHandler.makeRequest(request: URLRequest(url: endpoint))
            .decode(type: [ArtistType].self, decoder: JSONDecoder())
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
