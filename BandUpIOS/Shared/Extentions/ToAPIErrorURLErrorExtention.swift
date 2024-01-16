//
//  ToAPIErrorURLErrorExtention.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 13.01.24.
//

import Foundation

extension URLError {
    func toAPIError() -> APIError {
        switch self.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternetError
        case .cannotConnectToHost:
            return .cannotConnectToHost
        case .timedOut:
            return .timedOut
        default:
            return .unknownError
        }
    }
}
