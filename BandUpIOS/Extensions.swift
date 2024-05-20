//
//  Extensions.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 17.01.24.
//

import Foundation
import SwiftUI
import MapKit

extension URL {
    func isReachable(completion: @escaping (Bool) -> ()) {
        var request = URLRequest(url: self)
        request.httpMethod = "HEAD"
        
        let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode == 200)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
}

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

extension Int {
    func formattedString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        
        let thousand = 1000
        let million = thousand * thousand
        
        if self >= million {
            let formattedNumber = Double(self) / Double(million)
            return "\(formatter.string(from: NSNumber(value: formattedNumber)) ?? "")M"
        } else if self >= thousand {
            let formattedNumber = Double(self) / Double(thousand)
            return "\(formatter.string(from: NSNumber(value: formattedNumber)) ?? "")K"
        } else {
            return "\(self)"
        }
    }
}

extension Binding {
    func isNotNil<T>() -> Binding<Bool> where Value == T? {
        .init(get: {
            wrappedValue != nil
        }, set: { _ in
            wrappedValue = nil
        })
    }
}

extension MKMapItem: Identifiable {
    public var id: String {
        return name ?? ""
    }
}

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 512_000_000, diskCapacity: 10_000_000_000)
}
