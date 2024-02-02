//
//  AdvertService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation

protocol AdvertServiceProtocol {
    func create(advertCreateRequest: CreateUpdateAdvert, completion: @escaping (Result<Advert, APIError>) -> Void)
    func getById(advertId: Int, completion: @escaping (Result<Advert, APIError>) -> Void)
    func getAll(pageNo: Int, pageSize: Int, artistTypeIds: [Int]?, genreIds: [Int]?, completion: @escaping (Result<[Advert], APIError>) -> Void)
    func update(advertId: Int, advertUpdateRequest: CreateUpdateAdvert, completion: @escaping (Result<Advert, APIError>) -> Void)
    func delete(advertId: Int, completion: @escaping (Result<Void, APIError>) -> Void)
}

class AdvertService {
    static let shared: AdvertServiceProtocol = AdvertService()
    
    private static let baseURL = URL(string: "http://localhost:9090/api/v1/advertisements")!
    private let decoder = JSONDecoder()
    private let formatter = DateFormatter()
    
    private init() {
        formatter.locale = .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
    }
}

extension AdvertService: AdvertServiceProtocol {
    func create(advertCreateRequest: CreateUpdateAdvert, completion: @escaping (Result<Advert, APIError>) -> Void) {
        var request = URLRequest(url: AdvertService.baseURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(advertCreateRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        RequestHandler.makeRequest(request: request) { [weak self] requestCompletion in
            switch requestCompletion {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.invalidResponseError))
                    return
                }
                do {
                    let response = try self?.decoder.decode(Advert.self, from: data)
                    guard let response = response else {
                        completion(.failure(.unknownError))
                        return
                    }
                    completion(.success(response))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getById(advertId: Int, completion: @escaping (Result<Advert, APIError>) -> Void) {
        let endpoint = AdvertService.baseURL.appending(path: "/\(advertId)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        RequestHandler.makeRequest(request: request) { [weak self] requestCompletion in
            switch requestCompletion {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.invalidResponseError))
                    return
                }
                do {
                    let response = try self?.decoder.decode(Advert.self, from: data)
                    guard let response = response else {
                        completion(.failure(.unknownError))
                        return
                    }
                    completion(.success(response))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getAll(pageNo: Int, pageSize: Int, artistTypeIds: [Int]?, genreIds: [Int]?, completion: @escaping (Result<[Advert], APIError>) -> Void) {
        var queryArtistTypeIds: [URLQueryItem] = []
        var queryGenreIds: [URLQueryItem] = []
        
        if let artistTypeIds = artistTypeIds {
            queryArtistTypeIds = artistTypeIds.map {
                URLQueryItem(name: "artistTypeIds", value: "\($0)")
            }
        }
        
        if let genreIds = genreIds {
            queryGenreIds = genreIds.map {
                URLQueryItem(name: "genreIds", value: "\($0)")
            }
        }
        
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "pageNo", value: "\(pageNo)"))
        queryItems.append(URLQueryItem(name: "pageSize", value: "\(pageSize)"))
        queryItems.append(contentsOf: queryArtistTypeIds)
        queryItems.append(contentsOf: queryGenreIds)

        let endpoint = AdvertService.baseURL.appending(queryItems: queryItems)
                
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        RequestHandler.makeRequest(request: request) { [weak self] requestCompletion in
            switch requestCompletion {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.invalidResponseError))
                    return
                }
                do {
                    let response = try self?.decoder.decode([Advert].self, from: data)
                    guard let response = response else {
                        completion(.failure(.unknownError))
                        return
                    }
                    completion(.success(response))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func update(advertId: Int, advertUpdateRequest: CreateUpdateAdvert, completion: @escaping (Result<Advert, APIError>) -> Void) {
        let endpoint = AdvertService.baseURL.appending(path: "/\(advertId)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONEncoder().encode(advertUpdateRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        RequestHandler.makeRequest(request: request) { [weak self] requestCompletion in
            switch requestCompletion {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.invalidResponseError))
                    return
                }
                do {
                    let response = try self?.decoder.decode(Advert.self, from: data)
                    guard let response = response else {
                        completion(.failure(.unknownError))
                        return
                    }
                    completion(.success(response))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func delete(advertId: Int, completion: @escaping (Result<Void, APIError>) -> Void) {
        let endpoint = AdvertService.baseURL.appending(path: "\(advertId)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "DELETE"
        
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        RequestHandler.makeRequest(request: request) { requestCompletion in
            switch requestCompletion {
            case .success:
                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
