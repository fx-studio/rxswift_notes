# 07.4 Relay

`Relay` là thành phần mới được thêm vào RxSwift. Đi kèm với đó là khai tử đi `Variable` , một trong nhưng Class sử dụng rất rất nhiều trong các project với RxSwift.

Thứ nhất, Relay là một `wraps` cho một subject. Tuy nhiên, nó không giống như các subject hay các observable chung chung. Ở một số đặc điểm sau:

* Không có hàm `.onNext(_:)` để phát đi dữ liệu
* Dữ liệu được phát đi bằng cách sử dụng hàm `.accept(_:)`
* Chúng sẽ không bao giờ `.error` hay `.completed`

Nó sẽ liên quan tới 2 Subject khác và ta có 2 loại Relay

* `PublishRelay` đó là warp của **PublishSubject**. Relay này mang đặc tính của PublishSubject
* `BehaviorRelay` đó là warp của **BehaviorSubject**. Nó sẽ mang các đặc tính của subject này

Đúng là không có gì mới, ngoại trừ cái tên được thay thế thôi. Chúng ta sẽ đi vào ví dụ cụ thể cho từng trường hợp nào

### PublishRelay

Để nhanh thì chúng ta sẽ phân tích ví dụ code sau

```swift
    let disposeBag = DisposeBag()
    enum MyError: Error {
      case anError
    }
    
    let publishRelay = PublishRelay<String>()
    
    publishRelay.accept("0")
    
    // subcribe 1
    publishRelay
      .subscribe { print("🔵 ", $0) }
      .disposed(by: disposeBag)
    
    publishRelay.accept("1")
    publishRelay.accept("2")
    publishRelay.accept("3")
    
    // subcribe 2
    publishRelay
      .subscribe { print("🔴 ", $0) }
      .disposed(by: disposeBag)
    
    publishRelay.accept("4")
    
//    publishRelay.accept(MyError.anError)
//    publishRelay.onCompleted()
```

Phân tích:

* Khai báo túi rác quốc dân & define các mã lỗi sử dụng
* Tạo một `PublishRelay` với kiểu dữ liệu phát đi là `String`
* Vì mang trong mình đặc tính của PublishSubject thì chúng ta ko cần cung cấp giá trị ban đầu cho nó
* Việc phát đi dữ liệu thông qua hàm `.accpect(_:)`
* Khi nào có `subscriber` đăng kí tới và subscriber đó sẽ nhận được các giá trị được phát sau thời điểm đăng kí
* Test tiếp với việc subscribe lần 2
* 2 việc phát đi `error` & `completed` thì đều bị trình biên dịch ngăn cản

Nếu như bạn gặp vấn đề khi khai báo `PublishRelay` thay hãy thêm import này

```swift
import RxCocoa
```

Xem kết quả của đoạn code trên như sau

```
🔵  next(1)
🔵  next(2)
🔵  next(3)
🔵  next(4)
🔴  next(4)
```

Giờ chúng ta sang đối tượng Relay tiếp theo

### Behavior Relay

Cũng như trên, chúng ta sẽ tiếp cận thông qua đọc code demo

```swift
    let disposeBag = DisposeBag()
    enum MyError: Error {
      case anError
    }
    
    let behaviorRelay = BehaviorRelay<String>(value: "0")
    
    behaviorRelay.accept("0")
    
    // subcribe 1
    behaviorRelay
      .subscribe { print("🔵 ", $0) }
      .disposed(by: disposeBag)
    
    behaviorRelay.accept("1")
    behaviorRelay.accept("2")
    behaviorRelay.accept("3")
    
    // subcribe 2
    behaviorRelay
      .subscribe { print("🔴 ", $0) }
      .disposed(by: disposeBag)
    
    behaviorRelay.accept("4")
    
    // current value
    print("Current value: \(behaviorRelay.value)")
```

Bạn chỉ cần thay đổi lại `BehaviorRelay` cho PublishRelay là được. Bên cạnh đó vì là mang các đặc tính của BehaviorSubject, nên ta cần phải cung cấp giá trị ban đầu cho nó.

Vẫn là việc phát đi dữ liêu bằng `.accpet(_:)` và `subscribe` với các thời điểm khác nhau để xem sự thay đổi về cách nhận dữ liệu ở các `subcriber`.

Ngoài ra, có điều đặc biệt ở đây là chúng ta có thể truy cập vào giá trị hiện tại của `relay` này thông qua việc truy cập tới `.value` của nó.

Bạn xem kết quả như sau

```
🔵  next(0)
🔵  next(1)
🔵  next(2)
🔵  next(3)
🔴  next(3)
🔵  next(4)
🔴  next(4)
Current value: 4
```

Thì `3` sẽ được subcriber 2 nhận được, mặc dù subcriber 2 đã subscribe sau khi phát 3.

OKAY! tới đây là kết thúc Relay nha!

---

### Tóm tắt

* `Relay` là wrap một subject
* Đặc điểm
  * Không có `.onNext`, `.onError` và `.onCompleted`
  * Phát giá trị đi bằng `.accpet(_:)`
* Không bao giờ kết thúc
* Các class của Relay sẽ có các đặc tính của class mà nó `wrap` lại.
  * `PublishRelay` là wrap của PublishSubject
  * `BehaviorRelay` là wrap của BehaviorSubject