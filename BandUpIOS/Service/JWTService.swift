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
    func removeToken() throws
    func getToken() -> String?
    func checkTokenExpiration() -> Bool
    func extractEmail() -> String?
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
    
    func removeToken() throws {
        try keychain.remove("jwt")
        jwt = nil
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
    
    private func decodeJWT() -> [String: Any]? {
        guard let jwt = jwt else {
            return nil
        }
        
        var encoded = jwt.components(separatedBy: ".")[1]

        while encoded.count % 4 != 0 {
            encoded += "="
        }
        
        let decoded = Data(base64Encoded: encoded , options:.ignoreUnknownCharacters)!
        let json = try! JSONSerialization.jsonObject(with: decoded, options: []) as! [String:Any]
        
        return json
    }
    
    func checkTokenExpiration() -> Bool {
        guard let json = decodeJWT() else {
            return false
        }
        
        let exp = json["exp"] as! Int
        let expDate = Date(timeIntervalSince1970: TimeInterval(exp))
        
        return expDate.compare(Date()) == .orderedDescending
    }
    
    func extractEmail() -> String? {
        guard let json = decodeJWT() else {
            return nil
        }
                
        let email = json["sub"] as! String
        return email
    }
}
