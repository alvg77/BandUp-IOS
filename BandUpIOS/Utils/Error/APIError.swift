//
//  NetworkError.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 15.12.23.
//

import Foundation

enum APIError: LocalizedError {
    case unauthorized
    case invalidURLError
    case invalidResponseError
    case cannotConnectToHost
    case timedOut
    case noInternetError
    case decodingError
    case serverError(reason: String? = nil)
    case s3UploadError
    case unknownError
        
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "You need to login or register to be able to access this."
        case .invalidURLError:
            return "Cannot build a URL for the requested resource."
        case .invalidResponseError:
            return "The server returned invalid response."
        case .cannotConnectToHost:
            return "Cannot connect to the server. Please try again later."
        case .timedOut:
            return "Connection timed out. Please try again later."
        case .noInternetError:
            return "Please check your internet connection and try again later."
        case .decodingError:
            return "The server returned data in an unexpected format. Try updating the app."
        case .serverError(let reason):
            return "\(reason ?? "An error has occurred while processing your request.")"
        case .s3UploadError:
            return "Cannot upload the requested object."
        case .unknownError:
            return "An unknown error has occured."
        }
    }
}
