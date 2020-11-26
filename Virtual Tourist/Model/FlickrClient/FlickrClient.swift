//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Jae Paek on 11/24/20.
//

import Foundation

class FlickrClient {
    
    static var pageNumber:Int?
    static var maxPage:Int?
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/"
        static let imageBase = "https://live.staticflickr.com/"
        static let methodParam = "?method=flickr.photos.search"
        static let apiKeyParam = "&api_key=\(FlickrClient.getApiKey())"
        
        case search(Double, Double)
        case image(String, String, String)
        
        var stringValue: String {
            switch self {
            case .search(let lat, let lon):
                
                return Endpoints.base + Endpoints.methodParam + Endpoints.apiKeyParam + "&lat=\(lat)&lon=\(lon)&format=json&per_page=9&page=\(pageNumber ?? 1)"
            case .image(let serverId, let id, let secret):
                return Endpoints.imageBase + "\(serverId)/\(id)_\(secret)_t.jpg"
            default:
                return ""
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    static func getApiKey() -> String {
        guard let apiKeyPath = Bundle.main.path(forResource: "FlickrInfo", ofType: "plist") else {
            return ""
        }
        
        let apiKeyUrl = URL(fileURLWithPath: apiKeyPath)
        
        let apiKeyContent = try! Data(contentsOf: apiKeyUrl)
        
        guard let apiKeyMap = try! PropertyListSerialization.propertyList(from: apiKeyContent, options: .mutableContainers, format: nil) as? [String: String] else {
            return ""
        }
        return apiKeyMap["API_KEY"] ?? ""
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseThpe: ResponseType.Type, completion: @escaping(ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let range = 14..<data.count - 1
            let newData = data.subdata(in: range)
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(FlickrResponse.self, from: newData) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    class func getPhotos(latitude: Double, longitude: Double, completion: @escaping([FlickrPhoto], Error?) -> Void) {
        let _ = taskForGETRequest(url: Endpoints.search(latitude, longitude).url, responseThpe: PhotoResult.self, completion: {response, error in
            if let response = response {
                FlickrClient.maxPage = response.photos.pages
                completion(response.photos.photo, nil)
            } else {
                completion([], error)
            }
            
        })
    }
    
    class func downloadPhotoImage(photo: FlickrPhoto, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.image(photo.server, photo.id, photo.secret).url) { data, response, error in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
    }
}
