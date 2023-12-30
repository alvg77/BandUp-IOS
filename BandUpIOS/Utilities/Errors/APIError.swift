//
//  NetworkError.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 15.12.23.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURLError
    case noConnectionError
    case decodingError
    case serverError(statusCode: Int, reason: String? = nil)
    case unknownError
        
    var errorDescription: String? {
        switch self {
        case .invalidURLError:
            return "Cannot build a URL for the requested resource."
        case .noConnectionError:
            return "Please check your internet connection and try again later."
        case .decodingError:
            return "The server returned data in an unexpected format. Try updating the app."
        case .serverError(let statusCode, let reason):
            return "\(statusCode) \(reason ?? "Oops! Something went wrong.")"
        case .unknownError:
            return "An unknown error has occured."
        }
    }
}
