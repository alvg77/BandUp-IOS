//
//  ErrorMessage.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 18.12.23.
//

import Foundation

struct APIErrorMessage: Decodable {
    var type: String
    var title: String
    var status: Int
    var detail: String
    var instance: String
    
    static func getServerError(data: Data) -> APIError {
        if !data.isEmpty {
            do {
                let reason = try JSONDecoder().decode(APIErrorMessage.self, from: data)
                return .serverError(reason: reason.detail)
            } catch {
                return .decodingError
            }
        } else {
            return .serverError()
        }
    }
}
