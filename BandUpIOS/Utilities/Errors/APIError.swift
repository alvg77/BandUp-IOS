//
//  NetworkError.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 15.12.23.
//

import Foundation

enum APIError: LocalizedError {
    /// Invalid request, e.g. invalid URL
    case invalidRequestError(String)
      
    /// Indicates an error on the transport layer, e.g. not being able to connect to the server
    case transportError
      
    /// Received an invalid response, e.g. non-HTTP result
    case invalidResponse
      
    /// The server sent data in an unexpected format
    case decodingError(Error)
    
    /// General server-side error. If `retryAfter` is set, the client can send the same request after the given time.
    case serverError(statusCode: Int, reason: String? = nil)
    
    case unknownError
        
    var errorDescription: String? {
        switch self {
        case .invalidRequestError(let message):
            return "Invalid request: \(message)"
        case .transportError:
            return "An error occured. Please check your connection or try again later."
        case .invalidResponse:
            return "Invalid response"
        case .decodingError:
            return "The server returned data in an unexpected format. Try updating the app."
        case .serverError(let statusCode, let reason):
            return "\(statusCode) \(reason ?? "Oops! Something went wrong.")"
        case .unknownError:
            return "An unknown error has occured."
        }
    }
}

extension Int {
    func apiError(data: Data?) -> APIError? {
        switch self {
        case 200..<300:
            return nil
        default:
            if let data = data {
                let errorMessage = try? JSONDecoder().decode(APIErrorMessage.self, from: data)
                return .serverError(statusCode: self, reason: errorMessage?.detail)
            } else {
                return .serverError(statusCode: self)
            }
        }
    }
}
