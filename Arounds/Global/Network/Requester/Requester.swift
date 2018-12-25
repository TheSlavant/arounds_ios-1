//
//  Requester.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/3/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import Alamofire
import SwiftyJSON
import Foundation

class Requester {
    
    //MARK: Private block
    private static func appendCustomRequiredHeaders(_ headers: HTTPHeaders?) -> HTTPHeaders? {
        var customHeaders = (headers == nil) ? [String:String]() : headers
        
//        if (UserDefaults.standard.object(forKey: "accsess_token") != nil) {
//            let token = UserDefaults.standard.object(forKey: "accsess_token") as! String
//            customHeaders!["Authorization"] = "Bearer " + token
//        }
        //        customHeaders!["Authorization"] = "Bearer " + ""
        customHeaders?.merge(_requiredHeaders.lazy.map { ($0.key, $0.value) }) { (current, _) in current }

        return customHeaders
    }
    
    private static func makeUrlFromPath(_ path: String) -> String {
        var url = path
        if !path.hasPrefix("http") {
            if !url.hasSuffix("/") {
                url = kBaseUrl + "/" + path
            } else {
                url = kBaseUrl + path
            }
        }
        return url
    }
    
    private static var _requiredHeaders:HTTPHeaders = ["os":"ios","Content-Type":"application/json"]
    
    //MARK: Public block
    static var isInternetReachable = true
    
    static let reachabilityManager = Alamofire.NetworkReachabilityManager.init()
    
    static func listenForReachability() {
        self.reachabilityManager?.listener = { status in
            print("Network Status Changed: \(status)")
            switch status {
            case .notReachable:
                isInternetReachable = false
                break
            case .reachable(_):
                isInternetReachable = true
                break
            case .unknown:
                isInternetReachable = false
                break
            }
        }
        
        self.reachabilityManager?.startListening()
    }
    
    
    static func addToRequiredHeaders(_ h: HTTPHeaders) {
        _requiredHeaders.merge(h.lazy.map { ($0.key, $0.value) }) { (current, _) in current }
    }
    
    static func removeFromRequiredHeaders(key: String) {
        _requiredHeaders.removeValue(forKey: key)
    }
    
    static func sendRequestToPath(_ path: String,
                                  method: HTTPMethod,
                                  parameters: Parameters?,
                                  headers: HTTPHeaders?,
                                  completionHandler: ((NSError?, Data? ,[String:Any]?,Int) -> Void)?) {
        
        let customHeaders = appendCustomRequiredHeaders(headers)
        
        Alamofire.request(makeUrlFromPath(path),
                          method: method,
                          parameters: parameters,
                          encoding: (method == .get || method == .delete) ? URLEncoding.default : JSONEncoding.default,
                          headers: customHeaders).validate().responseJSON
            { response in
                var error:NSError?
                if response.result.error != nil {
                    error = response.result.error as NSError?
                    if let data = response.data {
                        do {
                            if let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any?] {
                                
                                var userInfo = error!.userInfo as [String: Any]
                                userInfo.merge(["error":jsonDictionary].lazy.map { ($0.key, $0.value) }) { (current, _) in current }

                                error = NSError(domain: (error?.domain)!, code: (error?.code)!, userInfo: userInfo)
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
                
                if completionHandler != nil {
                    completionHandler!(error,
                                       response.data,
                                       response.result.value as? [String : Any], response.response?.statusCode ?? 0)
                }
        }
    }
    
    static func sendRequestToPath(_ path: String,
                                  method: HTTPMethod,
                                  parameters: Parameters?,
                                  completionHandler: ((NSError?, Data? ,[String:Any]?,Int) -> Void)?) {
        self.sendRequestToPath(path,
                               method: method,
                               parameters: parameters,
                               headers: nil,
                               completionHandler: completionHandler)
    }
}
