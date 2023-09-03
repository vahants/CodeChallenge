//
//  CHNetworkWorker.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 26.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import Foundation

@objcMembers class CHNetworkWorker: NSObject {
    
    typealias CallBack<T> = (_ result: Challenge.Result<T>) -> Void
    
    let network = Challenge.shared.network
    
    @discardableResult
    func request<T: Decodable>(request: CHRequest, decoder: IDecoder, callBack: @escaping CallBack<T>) -> INetworkOperation? {
        return self.network.request(decodable: request, decoder: decoder) { (result: Challenge.Result<T>) in
            DispatchQueue.main.async {
                callBack(result)
            }
        }
    }
    
}

@objcMembers class CHFlickrPhotosNetworkWorker: CHNetworkWorker {
    
    static var apiKey = "2ed35a9f4fda03bc96e73dbd03602780"
    
    @objc enum FlickrPhotosSort: Int {
        case datePostedDesc
        case datePostedAsc
        
        case dateTakenDesc
        case dateTakenAsc
        
        case interestingnessDesc
        case interestingnessAsc
        case relevance
        
        var hashString: String {
            switch self {
            case .datePostedDesc:
                return "date-posted-desc"
            case .datePostedAsc:
                return "date-posted-asc"
            case .dateTakenDesc:
                return "date-taken-desc"
            case .dateTakenAsc:
                return "date-taken-asc"
            case .interestingnessDesc:
                return "interestingness-desc"
            case .interestingnessAsc:
                return "interestingness-asc"
            case .relevance:
                return "relevance"
            }
        }
    }
    
    func requestPhotos(type: String, pageNumber: Int, perPage: Int, sort: FlickrPhotosSort, success: @escaping (CHFlickrPhotoPageResult) -> Void, failure: @escaping (NSError) -> Void) -> INetworkOperation? {
                
        let url = "https://api.flickr.com/services/rest/"
        
        do {
            let request = try CHRequest(urlStr: url, queryParams: ["method": "flickr.photos.search", "api_key": Self.apiKey, "tags": "\(type)", "per_page": "\(perPage)", "page": "\(pageNumber)", "format": "json", "nojsoncallback": "\(1)", "extras": "date_taken,description,tags", "sort": sort.hashString])
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom({ decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)

                let formater = DateFormatter()
                formater.dateFormat = "yyyy-MM-dd HH:mm:ss"
                guard let date = formater.date(from: dateString) else {
                    throw CHError.incorrectParsing(message: dateString, code: -10234)
                }
                return date
            })
            return self.request(request: request, decoder: decoder) { (result: Challenge.Result<CHFlickrPhotoResult>) in
                switch result {
                case .success(let result):
                    success(result.page)
                case .failure(let error):
                    failure(error as NSError)
                }
            }
        } catch {
            failure(CHError.error(error: error) as NSError)
        }
        
        return nil
    }
}
