//
//  GenreFetchService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 13.12.23.
//

import Foundation
import Combine

protocol GenreFetchServiceProtocol {
    func getGenres() -> AnyPublisher<[Genre], APIError>
}

class GenreFetchService {
    static let shared: GenreFetchServiceProtocol = GenreFetchService()
    private init() { }
}

extension GenreFetchService: GenreFetchServiceProtocol {
    func getGenres() -> AnyPublisher<[Genre], APIError> {
        let url = URL(string: "http://localhost:9090/api/v1/genres")
        
        guard let url = url else {
            return Fail(error: .invalidRequestError("Cannot construct URL for the requested resource.")).eraseToAnyPublisher()
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
                        let genres = try decoder.decode([Genre].self, from: data)
                        return genres
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
