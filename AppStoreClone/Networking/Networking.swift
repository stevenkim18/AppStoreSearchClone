//
//  Networking.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/11/02.
//

import Foundation
import RxSwift

enum HomeApi {
    case fetchAppsInfo(String)
}

extension HomeApi: ApiTargetType {
    var host: String {
        return "itunes.apple.com"
    }

    var path: String {
        switch self {
            case .fetchAppsInfo:
                return "/search"
        }
    }

    var mehtod: HttpMethod {
        return .get
    }
    
    var parameters: [String: Any] {
        switch self {
        case let .fetchAppsInfo(keyword):
            return ["term": keyword,
                    "entity": "software",
                    "country": "kr",
                    "limit": 1000]
        }
    }
}



enum ApiError: Error {
    case noResponse
    case invalidData
    case unexpected
}

extension ApiError: CustomStringConvertible {
    var description: String {
        switch self {
            case .noResponse:
                return "서버에 응답이 없습니다 잠시후 다시 이용해 주세요."
            case .invalidData:
                return "잘못된 데이터가 입력되었습니다."
            case .unexpected:
                return "현재 일시적인 문제가 생겨 빠르게 개선중입니다.\n이용에 불편을 드려 죄송합니다.\n잠시 후 다시 접속해주세요."
        }
    }
}

protocol NetworkingProtocol {
    func request<T>(_ targetType: ApiTargetType) -> Single<T> where T: Codable, T: Decodable
}

struct Networking: NetworkingProtocol {
    func request<T>(_ targetType: ApiTargetType) -> Single<T> where T: Codable, T: Decodable {
        guard let request = targetType.createCompmnents() else { return Single.error(ApiError.noResponse) }

        return Single.create { single -> Disposable in

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                guard let status = response as? HTTPURLResponse else {
                    single(.failure(ApiError.unexpected))
                    return
                }

                guard 200..<300 ~= status.statusCode else { single(.failure(ApiError.unexpected))
                    return
                }

                guard let data = data else { single(.failure(ApiError.unexpected))
                    return
                }
                
                print("data = \(String(decoding: data, as: UTF8.self))")
                
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    single(.success(decodedData))
                    return
                } catch {
                    print(error)
                    single(.failure(ApiError.invalidData))
                    return
                }
            }

            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }
}
