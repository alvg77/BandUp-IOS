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
    case transportError(String)
      
    /// Received an invalid response, e.g. non-HTTP result
    case invalidResponse
      
    /// Server-side validation error
    case validationError(String)
      
    /// The server sent data in an unexpected format
    case decodingError(Error)
    
    /// General server-side error. If `retryAfter` is set, the client can send the same request after the given time.
    case serverError(statusCode: Int, reason: String? = nil)
        
    var errorDescription: String {
        switch self {
        case .invalidRequestError(let message):
            return "Invalid request: \(message)"
        case .transportError(let message):
            return message
        case .invalidResponse:
            return "Invalid response"
        case .validationError(let reason):
            return reason
        case .decodingError:
            return "The server returned data in an unexpected format. Try updating the app."
        case .serverError(let statusCode, let reason):
            return "Server error with code \(statusCode), reason: \(reason ?? "no reason given")"
        }
    }
}
