



# 07.3 Replay Subject

Đây cũng là một loại Subject. Đặc điểm của loại subject này thì khi phát đi các giá trị thì đồng thời nó lưu lại các giá trị đó trong bộ đệm của mình. Và khi có một subscriber đăng kí tới thì subject này sẽ phát đi các giá trị trong bộ đêm của nó cho subscriber đó.

Kích thước bộ đệm sẽ được cung cấp lúc khai báo khởi tạo Replay Subject.

Chúng ta xem cách tạo ra một `Replay Subject` như thế nào

```swift
let subject = ReplaySubject<String>.create(bufferSize: 2)
```

Phân tích:

* class sử dụng là `ReplaySubject`
* kiểu giá trị được phát đi là `String`
* bộ đêm lưu trữ tối đa là 2 phần tử

Ngoài ra, muốn bộ đệm lưu trữ tất cả các giá trị thì bạn hay khởi tạo với hàm sau

```swift
let subject = ReplaySubject<String>.createUnbounded()
```

Bạn nhớ khai báo thêm túi ra quốc dân để dùng cho các ví dụ tiếp theo sau. Giờ chúng ta tiến hành phát đi vài dữ liệu & subscribe lần đầu xem các giá trị nhận được là gì

```swift
    // emit
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    // subcribe 1
    subject
      .subscribe { print("🔵 ", $0) }
      .disposed(by: disposeBag)
```

Okay, run chạy và xem kết quả

```
🔵  next(2)
🔵  next(3)
```

Chúng ta tiếp tục phát & subscribe lần 2 để xem ra sao

```swift
    // emit
    subject.onNext("4")
    
    // subcribe 2
    subject
      .subscribe { print("🔴 ", $0) }
      .disposed(by: disposeBag)
```

Subscriber 1 sẽ nhận được giá trị `4` và subscriber 2 chỉ nhận được `3` và `4`

```
🔵  next(2)
🔵  next(3)
🔵  next(4)
🔴  next(3)
🔴  next(4)
```

Còn với `error` thì như thế nào. Ta lại tiếp tục ví dụ với emit `error` và subscribe lần thứ 3

```swift
    // error
    subject.onError(MyError.anError)
    
    // subcribe 3
    subject
      .subscribe { print("🟠 ", $0) }
      .disposed(by: disposeBag)
```

Kết quả ra như sau

```
🔵  next(2)
🔵  next(3)
🔵  next(4)
🔴  next(3)
🔴  next(4)
🔵  error(anError)
🔴  error(anError)
🟠  next(3)
🟠  next(4)
🟠  error(anError)
```

Bạn sẽ thấy subscriber thứ 3 sẽ nhận đầy đủ 2 giá trị trong bộ đêm và kèm theo giá trị `error` của subject. Ngoài ra, 2 subscriber trước đó vẫn nhận `error`. Tiếp tục, với việc `dispose` luôn subject để xem như thế nào

```swift
    // error
    subject.onError(MyError.anError)
    
    // dispose
    subject.dispose()
    
    // subcribe 3
    subject
      .subscribe { print("🟠 ", $0) }
      .disposed(by: disposeBag)
```

Tới đây thì kết quả có chút thay đổi

```
🔵  next(2)
🔵  next(3)
🔵  next(4)
🔴  next(3)
🔴  next(4)
🔵  error(anError)
🔴  error(anError)
🟠  error(Object `RxSwift.(unknown context at $12d143990).ReplayMany<Swift.String>` was already disposed.)
```

Đối tượng subscriber thứ 3 không nhận được các dữ liệu từ bộ đệm nữa.

> Đó là cách cắt đứt dứt sớm, tránh đau khổ về sau khi bạn muốn ReplaySubject không phát lại bất cứ gì cho các subscriber mới.

Xem lại toàn bộ code để có cái nhìn tổng quát nhất

```swift
    let disposeBag = DisposeBag()
    enum MyError: Error {
      case anError
    }
    
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    
    // emit
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    // subcribe 1
    subject
      .subscribe { print("🔵 ", $0) }
      .disposed(by: disposeBag)
    
    // emit
    subject.onNext("4")
    
    // subcribe 2
    subject
      .subscribe { print("🔴 ", $0) }
      .disposed(by: disposeBag)
    
    // error
    subject.onError(MyError.anError)
    
    // dispose
    subject.dispose()
    
    // subcribe 3
    subject
      .subscribe { print("🟠 ", $0) }
      .disposed(by: disposeBag)
```

Bạn nhớ test thử việc unlimited bộ đệm của Subject thì như thế nào nha

```swift
let subject = ReplaySubject<String>.createUnbounded()
```

---

### Tóm tắt

* `ReplaySubject` là subject mà sẽ phát lại các giá trị đã phát cho các subscriber mới đăng kí tới
* Số lượng của các giá trị phát lại tuỳ thuộc vào các cấu hình bộ đệm lúc khởi tạo subject
* Ngay cả khi subject phát đi `error` hay `completed` thì các subscriber mới vẫn sẽ nhận được đầy đủ các giá trị trong bộ đệm và `error` hay `completed` cuối cùng đó.
* Khi sử dụng toán tử `dispose()` của `subject` thì toàn bộ mọi thứ sẽ được xoá hết. Nên các subscriber mới lúc đó sẽ không nhận được gì ngoài `error`.