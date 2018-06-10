//
//  AuthApi.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/3/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation
import SwiftyJSON

class AuthApi {
    
    func login(with phone:String, completion handler:((Error?, ARUser?)->Void)?) {
        
        Requester.sendRequestToPath("user", method: .post, parameters:["phone":phone]) { (error, data, result, statusCode) in
            DispatchQueue.main.async {
                if let data = data {
                    if  let resultJson = try? JSON.init(data: data) {
                        print(resultJson)
                        let user = ARUser(json: resultJson)
                        ARUser.currentUser = user
                        ARUser.currentUser?.me = true
                        ARUser.currentUser?.save()
                        handler?(nil, user)
                        return
                    }
                    handler?(error, nil)

                }
            }
        }
        
    }
}
