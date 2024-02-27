//
//  S3Service.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.02.24.
//

import Foundation
import PhotosUI
import Combine

protocol AWSS3ServiceProtocol {
    func uploadImage(signedURL: URL, image: UIImage, completion: @escaping (Result<Void, APIError>) -> Void)
    func fetchUploadSignedURL(objectKey: String) -> AnyPublisher<URL, APIError>
}

class AWSS3Service {
    static let shared: AWSS3ServiceProtocol = AWSS3Service()
    
    private init() { }
}

extension AWSS3Service: AWSS3ServiceProtocol {
    func uploadImage(signedURL: URL, image: UIImage, completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            completion(.failure(.s3UploadError))
            return
        }
        
        var request = URLRequest(url: signedURL)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in
            if let error = error as? URLError {
                completion(.failure(error.toAPIError()))
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(.success(Void()))
            } else {
                if let response = response as? HTTPURLResponse {
                    print(response.statusCode)
                }
                completion(.failure(.s3UploadError))
            }
        }.resume()
    }
    
    func fetchUploadSignedURL(objectKey: String) -> AnyPublisher<URL, APIError> {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "key", value: objectKey))
        queryItems.append(URLQueryItem(name: "contentType", value: "image/jpeg"))
        
        let endpoint = URL(string: "\(Secrets.baseApiURL)/aws-s3/put")?.appending(queryItems: queryItems)
        
        guard let endpoint = endpoint else {
            return Fail(error: APIError.invalidURLError).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return RequestHandler.makeRequest(request: request)
            .tryMap { data -> URL in
                guard let urlAsString = String(data: data, encoding: .utf8),
                      let url = URL(string: urlAsString) else {
                    throw APIError.invalidResponseError
                }
                return url
            }
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    return apiError
                } else {
                    return .unknownError
                }
            }
            .eraseToAnyPublisher()
    }
}
