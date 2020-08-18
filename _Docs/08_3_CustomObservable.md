# 08.3 Custom Observable

Nói chính xác hơn là phần này bạn sẽ tập viết `Model` với việc áp dụng RxSwift vào. Nó sẽ có một số chút khác lạ so với cách viết truyền thống. Và vấn đề chúng ta cần quan tâm lần này là

> Call back

Để bắt đầu thì chúng ta sẽ vào phần đầu tiên là chuẩn bị

### Chuẩn bị

Vẫn là project dành cho 2 phần trước. Nếu bạn quên thì có thể truy cập vào đây

* **Link:** [checkout](../Examples/BasicRxSwift)
* **Thư mục:** `/Examples/BasicRxSwift`

Phần này chúng ta không có thêm bất cứ ViewController nào hết. Thay vì đó chúng ta có 1 file là `RegisterModel`. File này giả định là sẽ dùng tương tác với API để tiến hành đăng kí 1 account cho người dùng.

> Tất cả đều là giả sử thôi nghen.

Ta có code ban đâu của nó như sau:

```swift
import Foundation
import UIKit

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
    
    func register(username: String?, password: String?, email: String?, avatar: UIImage?) {
        
    }
}
```

Trong class có

* 1 singleton để tiện tay mà gọi cho khoẻ, không cần new nhiều đối tượng cho nó phiền phức
* 1 function chính là `register` với 4 tham số
* các tham số này nhận dữ liệu trực tiếp từ các View, nên chúng nó sẽ là các `optional`

Tiếp theo, ta sẽ Rx hoá class này bằng việc import

```swift
import RxSwift
```

Và biến đổi lại function `register` thành như sau

```swift
func register(username: String?, password: String?, email: String?, avatar: UIImage?) -> Observable<Bool> {
        
    }
```

Bạn sẽ thấy chúng ta sẽ return về 1 `Observable`. Và kiểu dữ liệu Output là Tuple với 

* `Bool` cho việc thành công hay thất bại
* `String` thông tin lỗi gì

### Create Observable

Phần tiếp theo, bạn cần phải viết code cho function trên. Đầu tiên chúng ta cần phải `return` về 1 Observable trước.

```swift
func register(username: String?, password: String?, email: String?, avatar: UIImage?) -> Observable<Bool> {
        return Observable.create { observer in
            return Disposables.create()
        }
    }
```

Như đã được trình bày ở các bài trước, thì với toán tử `.create` chúng ta cần 1 một closure để handle cho nó, khi tạo ra 1 Observable. Đối tượng `observer` sẽ quyết định các logic & hành vi của Observable. Rồi từ đó phát các dữ liệu liên quan.

Cuối cùng phải có 1 `Disposable` để nó có thể ném vào đc túi rác nào đó.

Phần tiếp theo nữa là bạn cần xử lý logic trong `create`. Vì đây là đặc điểm riêng của từng class hay từng project theo ý đồ nào đấy. Còn trong demo ví dụ này thì sẽ như sau

* Kiểm tra các tham số đầu vào của function `register`. Nếu chúng lỗi thì phải `emit` lỗi trở về, phân biệt từng loại lõi cho từng tham số
* Khi các tham số thoải mãn điều kiện. Giả sử chúng ta gọi API để thực hiện và sau khoản 2 giây sau thì `emit` đi dữ liệu mô tả việc gọi thành công.

Để quản lý đám `error` , chúng ta cần phải custom lại Protocol Error. Bạn thêm đoạn code này vào đâu cũng đc. Ahihi

```swift
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
```

Error cũng đã được define rồi. Và nghe qua logic trên thì cũng đơn giản phải không nào. Ít hôm tới bài RxSwift với API thì chúng ta sẽ đau não sau. Giờ tạm thời code sẽ như thế này

```swift
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
```

Bạn cần chú ý:

* Trường hợp muốn phát đi `.error`

  ```swift
  observer.onError(APIError.error("username is empty"))
  ```

  Sử dụng hàm `.onError` và ném vào đó 1 đối tượng Error theo ý mình

* Trường hợp muốn phát đi  `.onNext`

  ```swift
  observer.onNext((true))
  ```

  Vì chúng ta chỉ muốn báo là thành công hay không nên dùng 1 biến Bool đơn giản thôi.

Vì khi phát đi `error` thì sequence observable sẽ kết thúc. Nên nếu bạn chỉ có phát đi `.onNext` một lần thôi thì phải thêm đoạn completed cho sequence observable.

```swift
observer.onCompleted()
```

Vậy là tạm thời xong phần Model!

### Subcribe

Giờ là cách sử dụng function vừa được tạo ra. Bạn về lại file `RegisterViewController`. tại hàm `register` chúng ta tiến hành `subscribe` nó

```swift
    @IBAction func register(_ sender: Any) {
        RegisterModel.shared().register(username: usernameTextField.text,
                                        password: passwordTextField.text,
                                        email: emailTextField.text,
                                        avatar: avatarImageView.image)
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
    }
```

Trong đó

* `.onNext` để handle dữ liệu nhận được
* `.onError` để handle lỗi nhận được
* `.onCompleted` để handle khi observable kết thúc

Luôn ghi nhớ việc lưu trữ lại `subscription` tại disposebag. Còn lại đoạn code trên chỉ show log ở console mà thôi. Trong thực tế thì bạn sẽ handle thêm về UI hay chuyển màn hình tại đó.

### Traits

Bạn cũng thấy phần `LoginModel` thì function `register` chỉ có phát đi một lần và kết thúc, cho dù là `error` đi chăng nữa. Và trong thực tế cuộc sống cũng như vậy, khi đó thì không cần thiết phải dùng đầy đủ các tính năng của 1 Observable.

> Hãy nhớ tới Trait

Chúng ta có 3 Trait hay dùng trong RxSwift

* Single
* MayBe
* Completable

Nếu bạn nào quên thì có thể xem lại ở bài Traits. Còn với ví dụ demo này thì có thể viết 1 function `register` mới với tham số trả về là  `Single`

```swift
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
```

Với `Single` thì bạn cần quan tâm tới 2 trạng thái

* `success` là thành công 
* `error` là thất bại

Và bạn cũng không cần quan tâm phải kết thúc sequence observable của mình nữa. Nhiều trường hợp lỗi vì bất cẩn cũng vì thế được giảm đi rất nhiều.

Tiếp tới là phần sử dụng. Cũng như như subscribe tới 1 Observable, tuy nhiên với Single thì đơn giản hơn nhiều.

````swift
        RegisterModel.shared().register2(username: usernameTextField.text,
                                         password: passwordTextField.text,
                                         email: emailTextField.text,
                                         avatar: avatarImageView.image)
            .subscribe(onSuccess: { done in
                print("Register successfully")
            }, onError: { error in
                if let myError = error as? APIError {
                    print("Register with error: \(myError.localizedDescription)")
                }
            }).disposed(by: bag)
````

Tương tự như bên tạo ra Single thì bên subcribe tới nó cũng chỉ quan tâm tới 2 trạng thái

* `onSuccess` handle thành công
* `onError` handle thất bại

Bạn muốn biến Single trở lại Observable thì chỉ cần gọi `asObservable()` thôi. Xem ví dụ luôn cho nóng.

```swift
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
```



OKAY! Tới đây là kết thúc bài viết này. Tuỳ thuộc vào yêu cầu mà bạn hay sử dụng chúng nó một cách hợp lý nha!

---

### Tóm tắt

Tất cả ở trên cũng chỉ là 1 phương pháp call back về cho nó xịn xò hơn thôi. Bạn thử xem dòng code sau

```swift
func register( ..... , completion: Result<Bool> -> Void) {

}
```

thì hãy chú ý tới tham số `completion` đó. Bạn sẽ nhận thấy `dăm ba cái đồ RxSwift` thôi mà!

Hết