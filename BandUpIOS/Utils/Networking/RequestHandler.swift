//
//  RequestHandler.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import Foundation
import Combine

struct RequestHandler {
    static func makeRequest(request: URLRequest) -> AnyPublisher<Data, APIError> {
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    throw APIError.invalidResponseError
                }
                
                switch httpResponse.statusCode {
                case 200..<300:
                    return output.data
                case 401:
                    throw APIError.unauthorized
                case 400..<600:
                    throw APIErrorMessage.getServerError(data: output.data)
                default:
                    throw APIError.unknownError
                }
            }
            .mapError { error -> APIError in
                if let urlError = error as? URLError {
                    return urlError.toAPIError()
                } else if let apiError = error as? APIError {
                    return apiError
                } else {
                    return .unknownError
                }
            }
            .eraseToAnyPublisher()
    }
}
