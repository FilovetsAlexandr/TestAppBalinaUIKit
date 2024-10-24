//
//  NetworkService.swift
//  TestAppBalinaUIKit
//
//  Created by Alexandr Filovets on 24.10.24.
//

import UIKit

struct UrlConstants {
    static var photosUrl = "https://junior.balinasoft.com/api/v2/photo/type"
    static var uploadPhotoUrl = "https://junior.balinasoft.com/api/v2/photo"
}

protocol NetworkProtocol {
    func getPhotos(page: Int, completion: @escaping (Result<Photos, Error>) -> Void)
    func sendPhotoToServer(photo: UIImage, id: Int, userName: String, completion: @escaping (Result<Data, Error>) -> Void)
}

final class NetworkService: NetworkProtocol {

    func getPhotos(page: Int, completion: @escaping (Result<Photos, Error>) -> Void) {
        guard var urlComponents = URLComponents(string: UrlConstants.photosUrl) else { return }
        urlComponents.queryItems = [URLQueryItem(name: "page", value: "\(page)")]

        guard let url = urlComponents.url else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let photos = try JSONDecoder().decode(Photos.self, from: data)
                completion(.success(photos))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    func sendPhotoToServer(photo: UIImage, id: Int, userName: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: UrlConstants.uploadPhotoUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        if let imageData = photo.jpegData(compressionQuality: 1) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"typeId\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(id)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userName)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            completion(.success(data))
        }

        task.resume()
    }
}
