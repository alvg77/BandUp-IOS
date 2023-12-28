//
//  ArtistTypeFetchService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 13.12.23.
//

import Foundation
import Combine

protocol ArtistTypeFetchServiceProtocol {
    func getArtistTypes() -> AnyPublisher<[ArtistType], APIError>
}

class ArtistTypeFetchService {
    static let shared: ArtistTypeFetchServiceProtocol = ArtistTypeFetchService()
    private init() { }
}

extension ArtistTypeFetchService: ArtistTypeFetchServiceProtocol {
    func getArtistTypes() -> AnyPublisher<[ArtistType], APIError> {
        let url = URL(string: "http://localhost:9090/api/v1/artist-types")

        guard let url = url else {
            return Fail(error: .invalidRequestError("Cannot build URL for resource.")).eraseToAnyPublisher()
        }
                      
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }

                if (200..<300) ~= httpResponse.statusCode {
                    let decoder = JSONDecoder()
                    do {
                        let artistTypes = try decoder.decode([ArtistType].self, from: data)
                        return artistTypes
                    } catch {
                        throw APIError.decodingError(error)
                    }
                } else {
                    throw APIError.serverError(statusCode: httpResponse.statusCode)
                }
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else {
                    return APIError.transportError
                }
            }
            .eraseToAnyPublisher()
    }
}
