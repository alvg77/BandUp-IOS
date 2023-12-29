//
//  JWTService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 28.12.23.
//

import Foundation
import KeychainAccess

protocol JWTServiceProtocol {
    func saveToken(token: String)
    func getToken() -> String?
    func checkTokenExpiration() -> Bool
}

class JWTService {
    static let shared: JWTServiceProtocol = JWTService()
    var keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    var jwt: String?
    
    private init() {
        jwt = keychain["jwt"]
    }
}

extension JWTService: JWTServiceProtocol {
    func saveToken(token: String) {
        keychain["jwt"] = token
        jwt = token
    }
    
    func getToken() -> String? {
        if let jwt = jwt {
            if checkTokenExpiration() {
                return jwt
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func checkTokenExpiration() -> Bool {
        guard let jwt = jwt else {
            return false
        }
        
        var encoded = jwt.components(separatedBy: ".")[1]

        while encoded.count % 4 != 0 {
            encoded += "="
        }
        
        let decoded = Data(base64Encoded: encoded , options:.ignoreUnknownCharacters)!
        let json = try! JSONSerialization.jsonObject(with: decoded, options: []) as! [String:Any]
        let exp = json["exp"] as! Int
        let expDate = Date(timeIntervalSince1970: TimeInterval(exp))
        
        return expDate.compare(Date()) == .orderedDescending
    }
}
