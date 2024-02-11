//
//  PostFlair.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.01.24.
//

import Foundation
import Combine

protocol PostFlairServiceProtocol {
    func getPostFlairs() -> AnyPublisher<[PostFlair], APIError>
}

class PostFlairService {
    static let shared: PostFlairServiceProtocol = PostFlairService()
    private init() { }
}

extension PostFlairService: PostFlairServiceProtocol {
    func getPostFlairs() -> AnyPublisher<[PostFlair], APIError> {
        let endpoint = URL(string: "\(Secrets.baseApiURL)/post-flairs")
        
        guard let endpoint = endpoint else {
            return Fail(error: APIError.invalidURLError).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: endpoint)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return RequestHandler.makeRequest(request: request)
            .decode(type: [PostFlair].self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                switch error {
                case is DecodingError:
                    return .decodingError
                case is APIError:
                    return error as! APIError
                default:
                    return .unknownError
                }
            }
            .eraseToAnyPublisher()
    }
}
