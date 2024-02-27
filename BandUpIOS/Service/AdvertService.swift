//
//  AdvertService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation
import Combine

protocol AdvertServiceProtocol {
    func create(advertCreateRequest: CreateEditAdvert) -> AnyPublisher<Advert, APIError>
    func getById(advertId: Int) -> AnyPublisher<Advert, APIError>
    func getAll(pageNo: Int, pageSize: Int, filter: AdvertFilter?, userId: Int?) -> AnyPublisher<[Advert], APIError>
    func edit(advertId: Int, advertEditRequest: CreateEditAdvert) -> AnyPublisher<Advert, APIError>
    func delete(advertId: Int) -> AnyPublisher<Void, APIError>
}


class AdvertService {
    static let shared: AdvertServiceProtocol = AdvertService()
    
    private static let baseURL = URL(string: "\(Secrets.baseApiURL)/advertisements")!
    private let decoder = JSONDecoder()
    private let formatter = DateFormatter()
    
    private init() {
        formatter.locale = .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
    }
}

extension AdvertService: AdvertServiceProtocol {
    func create(advertCreateRequest: CreateEditAdvert) -> AnyPublisher<Advert, APIError> {
        var request = URLRequest(url: AdvertService.baseURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(advertCreateRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return RequestHandler.makeRequest(request: request)
            .decode(type: Advert.self, decoder: decoder)
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
    
    func getById(advertId: Int) -> AnyPublisher<Advert, APIError> {
        let endpoint = AdvertService.baseURL.appending(path: "/\(advertId)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return RequestHandler.makeRequest(request: request)
            .decode(type: Advert.self, decoder: decoder)
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
    
    func getAll(pageNo: Int, pageSize: Int, filter: AdvertFilter?, userId: Int?) -> AnyPublisher<[Advert], APIError> {
        var queryArtistTypeIds: [URLQueryItem] = []
        var queryGenreIds: [URLQueryItem] = []

        if let artistTypeIds = filter?.searchedArtistTypes.map({ $0.id }) {
            queryArtistTypeIds = artistTypeIds.map {
                URLQueryItem(name: "artistTypeIds", value: "\($0)")
            }
        }
        
        if let genreIds = filter?.genres.map({ $0.id }) {
            queryGenreIds = genreIds.map {
                URLQueryItem(name: "genreIds", value: "\($0)")
            }
        }
        
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "pageNo", value: "\(pageNo)"))
        queryItems.append(URLQueryItem(name: "pageSize", value: "\(pageSize)"))
        queryItems.append(URLQueryItem(name: "city", value: filter?.location?.city))
        queryItems.append(URLQueryItem(name: "administrativeArea", value: filter?.location?.administrativeArea))
        queryItems.append(URLQueryItem(name: "country", value: filter?.location?.country))
        queryItems.append(URLQueryItem(name: "userId", value: userId != nil ? "\(userId!)" : nil))
        queryItems.append(contentsOf: queryArtistTypeIds)
        queryItems.append(contentsOf: queryGenreIds)

        let endpoint = AdvertService.baseURL.appending(queryItems: queryItems)
                
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  
        return RequestHandler.makeRequest(request: request)
            .decode(type: [Advert].self, decoder: decoder)
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
    
    func edit(advertId: Int, advertEditRequest: CreateEditAdvert) -> AnyPublisher<Advert, APIError> {
        let endpoint = AdvertService.baseURL.appending(path: "/\(advertId)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONEncoder().encode(advertEditRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return RequestHandler.makeRequest(request: request)
            .decode(type: Advert.self, decoder: decoder)
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
    
    func delete(advertId: Int) -> AnyPublisher<Void, APIError> {
        let endpoint = AdvertService.baseURL.appending(path: "\(advertId)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "DELETE"
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return RequestHandler.makeRequest(request: request)
            .map { _ in Void() }
            .eraseToAnyPublisher()
    }
}
