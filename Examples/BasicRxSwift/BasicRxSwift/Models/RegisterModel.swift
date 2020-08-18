//
//  LoginModel.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 8/18/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

enum APIError: Error {
    case error(String)
    case errorURL
    
    var localizedDescription: String {
        switch self {
        case .error(let string):
            return string
        case .errorURL:
            return "URL String is error."
        }
    }
}

final class RegisterModel {
    
    //singleton
    private static var sharedRegisterModel: RegisterModel = {
        let sharedRegisterModel = RegisterModel()
        return sharedRegisterModel
    }()
    
    class func shared() -> RegisterModel {
        return sharedRegisterModel
    }
    
    // init
    private init() {}
    
    func register(username: String?, password: String?, email: String?, avatar: UIImage?) -> Observable<(Bool)> {
        return Observable.create { observer in
           
            // check params
            // username
            if let username = username {
                if username == "" {
                    observer.onError(APIError.error("username is empty"))
                }
            } else {
                observer.onError(APIError.error("username is nil"))
            }
            
            // password
            if let password = password {
                if password == "" {
                    observer.onError(APIError.error("password is empty"))
                }
            } else {
                observer.onError(APIError.error("password is nil"))
            }
            
            // email
            if let email = email {
                if email == "" {
                    observer.onError(APIError.error("email is empty"))
                }
            } else {
                observer.onError(APIError.error("email is nil"))
            }
            
            // avatar
            if avatar == nil {
                observer.onError(APIError.error("avatar is empty"))
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                observer.onNext((true))
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func register2(username: String?, password: String?, email: String?, avatar: UIImage?) -> Single<Bool> {
        return Single.create { single in
            // check params
            // username
            if let username = username {
                if username == "" {
                    single(.error(APIError.error("username is empty")))
                }
            } else {
                single(.error(APIError.error("username is nil")))
            }
            
            // password
            if let password = password {
                if password == "" {
                    single(.error(APIError.error("password is empty")))
                }
            } else {
                single(.error(APIError.error("password is nil")))
            }
            
            // email
            if let email = email {
                if email == "" {
                    single(.error(APIError.error("email is empty")))
                }
            } else {
                single(.error(APIError.error("email is nil")))
            }
            
            // avatar
            if avatar == nil {
                single(.error(APIError.error("avatar is empty")))
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                single(.success(true))
            }
            
            return Disposables.create()
        }
    }
}
