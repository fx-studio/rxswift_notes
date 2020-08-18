//
//  RegisterViewController.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 8/15/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RegisterViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    // MARK: Properties
    var avatartIndex = 0
    private let bag = DisposeBag()
    private let image = BehaviorRelay<UIImage?>(value: nil)
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        
        configUI()
        
        //subscription
        image.asObservable()
            .subscribe(onNext: { img in
                self.avatarImageView.image = img
            })
            .disposed(by: bag)
    }
    
    // MARK: Config
    func configUI() {
        avatarImageView.layer.cornerRadius = 50.0
        avatarImageView.layer.borderWidth = 5.0
        avatarImageView.layer.borderColor = UIColor.gray.cgColor
        avatarImageView.layer.masksToBounds = true
        
        let rightBarButtonItem = UIBarButtonItem(title: "Change Avatar", style: .plain, target: self, action: #selector(self.changeAvatar))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    // MARK: Actions
    @IBAction func register(_ sender: Any) {
//        RegisterModel.shared().register(username: usernameTextField.text,
//                                        password: passwordTextField.text,
//                                        email: emailTextField.text,
//                                        avatar: avatarImageView.image)
//            .subscribe(onNext: { done in
//                print("Register successfully")
//            }, onError: { error in
//                if let myError = error as? APIError {
//                    print("Register with error: \(myError.localizedDescription)")
//                }
//            }, onCompleted: {
//                print("Register completed")
//            })
//            .disposed(by: bag)
        
        RegisterModel.shared().register2(username: usernameTextField.text,
                                                password: passwordTextField.text,
                                                email: emailTextField.text,
                                                avatar: avatarImageView.image)
            .asObservable()
            .subscribe(onNext: { done in
                print("Register successfully")
            }, onError: { error in
                if let myError = error as? APIError {
                    print("Register with error: \(myError.localizedDescription)")
                }
            }, onCompleted: {
                print("Register completed")
            })
            .disposed(by: bag)
        
//        RegisterModel.shared().register2(username: usernameTextField.text,
//                                         password: passwordTextField.text,
//                                         email: emailTextField.text,
//                                         avatar: avatarImageView.image)
//            .subscribe(onSuccess: { done in
//                print("Register successfully")
//            }, onError: { error in
//                if let myError = error as? APIError {
//                    print("Register with error: \(myError.localizedDescription)")
//                }
//            }).disposed(by: bag)
    }
    
    @IBAction func clear(_ sender: Any) {
    }
    
    @objc func changeAvatar() {
        let vc = ChangeAvatarViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
        //subscribe
        vc.selectedPhotos
            .subscribe(onNext: { img in
                self.image.accept(img)
            }, onDisposed: {
                print("Complete changed Avatar")
            })
        .disposed(by: bag)
    }
    
}
