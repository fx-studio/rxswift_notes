# 04 DisposeBag (Túi rác quốc dân)

> Điểm nguy hiểm nhất khi sử dụng RxSwift (hay Reactive Programming) là việc quản lý bộ nhớ không được tối ưu. Khi quá nhiều nguồn phát và quá nhiều đối tượng lắng nghe tới các nguồn phát đó, thì bạn có dám chắc rằng bạn đã giải phóng tất cả các đối tượng hay không.

### Dispose

Khi một Observable được tạo ra, thì nó sẽ không hoạt động hay hành động gì cho tới khi có 1 subscribe đăng ký tới. Việc subscribe khi đăng ký tới thì gọi là `subscription`. Lúc đó thì sẽ kích hoạt observable (hay gọi là `trigger`) bắt đi các giá trị của mình. Việc này cứ lặp đi lặp lại miết cho đến khi phát ra `.error` hoặc `.completed`.

Vấn đề chính bắt đầu từ đây. Bạn không bao giờ biết lúc nào nó kết thúc hoặc bạn phó mặc với số phận. Khi bạn chấp nhận buôn tay thì hậu quả để lại là các đối tượng trong chương trình của bạn không bao giờ bị giải phóng. Và bạn không biết khi nào dữ liệu tới hoặc de-bugs để biết lỗi từ đâu mà ra.

```swift
let observable = Observable<String>.of("A", "B", "C", "D", "E", "F")
    
let subscription = observable.subscribe { event in
    print(event)
}
```

Ta có một đoạn code với việc khai báo 1 observable với kiểu dữ liệu Output là `String`. Tiếp sau đó, tạo thêm 1 `subscription` bằng việc sử dụng toán tử `.subscribe` cho observable. Cung cấp thêm 1 closure để handle các dữ liệu nhận được.

Tiếp theo, để dừng việc phát của observable thì bạn sử dụng hàm `.dispose()` 

```swift
subscription.dispose()
```

Lúc này thì kết nối của `subscription` sẽ đứt và observable sẽ dừng phát.

### DisposeBag

Câu chuyện vẫn còn vui, bạn xem tiếp ví dụ code sau:

```swift
Observable<String>.of("A", "B", "C", "D", "E", "F")
        .subscribe { event in
            print(event)
        }
```

Nếu như bạn tạo ra 1 `subscription` để quản lý các đăng ký. Thì mọi thứ đơn giản rồi. Tuy nhiên vẫn là câu nói cũ `Đời không như là mơ`. Thường trong code Rx thì:

* Các đối tượng subscriber hầu như không tồn tại hoặc không tạo ra
* Các subscription sẽ được tạo ra nhằm giữ kết nối. Nó sẽ phục vụ cho tới khi nào class chứa nó bị giải phóng.
* Nhiều trường hợp muốn subscribe nhanh tới 1 Observable nên các subscription sẽ không tạo ra.

Vậy là vấn đề bộ nhớ vẫn nhức nhói. Do đó, người ta sinh ra khái niệm mới `DisposeBag` (túi rác quốc dân). Bạn xem tiếp code ví dụ trên với việc thêm DisposeBag vào.

```swift
    let bag = DisposeBag()
    
    Observable<String>.of("A", "B", "C", "D", "E", "F")
        .subscribe { event in
            print(event)
        }
        .disposed(by: bag)
```

Lúc này thì bạn không cần bận tâm lắm về observable mình tự do làm càng. Tất cả sẽ được `disposeBag` quản lý và thủ tiêu. Áp dụng vào trong project thì khi bạn khai báo 1 `disposeBag` là biến toàn cục. Khi đó bạn chỉ cần ném tất cả các subscription hoặc các observable vào đó. Và yên tâm về vấn đề bộ nhớ sẽ không bị ảnh hưởng.

> Tất nhiên, nếu bạn quên việc thêm `dispose()` hay `disposeBag` thì trình biên dịch sẽ nhắn lời yêu thương cho bạn biết.

### Create

Tiếp theo, ta sử dụng một toán tử mới có tên là `.create` để tạo ra 1 Observable. Ví dụ được thực hiện với kiểu Output là `String`.

```swift
Observable<String>.create(subscribe: (AnyObserver<String>) -> Disposable##(AnyObserver<String>) -> Disposable>)

```

Tham số cần truyền vào chính là 1 `observer`. Tới đây nhiều bạn sẽ loạn não 1 chút, mình xin tóm gọn lại thế này:

> * **Observable** là nguồn phát
> * **Observer** là nguồn nhận

Công việc của nó chính là:

* Thiết lập đăng kí từ Observable tới Subscribe
* Xác định các dữ liệu được phát ra bởi Observable tới Subscriber

Tiến hành implement đầy đủ cho Observable nào

```swift
Observable<String>.create { observer -> Disposable in
        observer.onNext("1")
        
        observer.onNext("2")
        
        observer.onNext("3")
        
        observer.onNext("4")
        
        observer.onNext("5")
        
        observer.onCompleted()
        
        observer.onNext("6")
        
        return Disposables.create()
    }
```

Bạn sẽ thấy trong closure đó thì chúng ta tuỳ ý phát ra các dữ liệu. Quan trọng là return về `Disposables` để có thể kết thúc việc đăng ký từ bên ngoài. Và nó cũng là đại diện cho mỗi lần đăng ký tới observable.

Bạn khai báo thêm 1 túi rác quốc dân nữa 

```swift
let bag = DisposeBag()
```

Tiếp theo là `.subscribe` tới Observable nào

```swift
.subscribe(
        onNext: { print($0) },
        onError: { print($0) },
        onCompleted: { print("Completed") },
        onDisposed: { print("Disposed") }
        )
    .disposed(by: bag)
```

Handle full các sự kiện với các dữ liệu mà Observable có thể phát ra. Các hàm handle là `onNext`, `onError`, `onCompleted` và `onDisposed` sẽ tương ứng với từng kiểu dữ liệu mà Observable phát ra. Kết quả khi thực thi như sau:

```
1
2
3
4
5
Completed
Disposed
```

Bạn để ý kĩ thì sẽ không thấy `6`. Đơn giản vì nó được phát ra sau `.completed`. Nên sẽ không bao giờ phát đi được và cũng ko bao giờ nhận được. Áp dụng tương tự cho `error`.

Khai báo 1 Error cho dễ quản lý

```swift
enum MyError: Error {
  case anError
}
```

Và phát error như sau:

```swift
observer.onError(MyError.anError)
```

Kết quả thực thi như sau với việc phát ra `error` sau khi phát ra `4`

```
1
2
3
4
anError
Disposed
```

> Lúc này bạn tuỳ ý custom về phát Error rồi nha.

Để nhìn rõ hơn việc `DisposeBag` ảnh hưởng như thế nào thì chúng ta sẽ comment lại các lệnh sau:

* disposed(by: bag)
* observer.onError(MyError.anError)
* observer.onCompleted()

```swift
enum MyError: Error {
      case anError
    }
    
    let bag = DisposeBag()
    
    Observable<String>.create { observer -> Disposable in
        observer.onNext("1")
        
        observer.onNext("2")
        
        observer.onNext("3")
        
        observer.onNext("4")
        
        //observer.onError(MyError.anError)
        
        observer.onNext("5")
        
        //observer.onCompleted()
        
        observer.onNext("6")
        
        return Disposables.create()
    }
    .subscribe(
        onNext: { print($0) },
        onError: { print($0) },
        onCompleted: { print("Completed") },
        onDisposed: { print("Disposed") }
        )
    //.disposed(by: bag)
```

Bạn xem kết quả như sau:

```
1
2
3
4
5
6
```

Như vậy, nếu không có `disposeBag` và không có việc phát ra `error` hay `completed` thì subscribe sẽ vẫn đứng đó chờ observable. Và subscription sẽ không kết thúc được.

---

### Tóm tắt

* `.dispose()` sử dụng cho các subscription để có thể tự kết thúc liên kết. Lúc đó thì Observable sẽ dừng việc phát dữ liệu
* `.disposed(by:)` sử dụng cho các Observable khi `subscribe` nhanh và không cần tạo ra đối tượng subscription để tự kết thúc việc đăng ký
* `Observable<T>.create` giúp cho bạn định nghĩa ra 1 observable và xử lý việc đăng ký & phát dữ liệu thông qua `observer`.
