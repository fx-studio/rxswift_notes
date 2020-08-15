# 07.2 Behavior Subject

Nó cũng là một loại Subject và cũng tương tự như Publish Subject. Tuy nhiên, có chỗ khác biệt là `Behavior Subject` sẽ luôn cung cấp giá trị cuối cùng mà nó phát ra cho các subscriber khi đăng kí tới.

>  Kkông cần quan tâm tới thời điểm mà subscriber đăng ký tới, cứ hễ đăng kí là sẽ nhận được giá trị từ `subject`.

Chuyển sang xem code ví dụ cho dễ hiểu hơn nào. Bắt đầu bằng việc khai báo 1 Behavior Subject

```swift
let subject = BehaviorSubject(value: "0")
```

Bạn sẽ thấy chúng ta

* Cần phải cung cấp dữ liệu đầu tiên cho subject
* Dựa vào kiểu dữ liệu `value` mà sẽ suy ra được kiểu dữ liệu cho Output phát ra

Tiếp theo ví dụ, khai báo thêm túi rác quốc dân & enum define cho mã lỗi

```swift
    let disposeBag = DisposeBag()
    
    enum MyError: Error {
      case anError
    }
```

Bắt đầu với việc subscribe tới subject và xem có nhận được phần tử `0` lúc khai báo hay là không?

```swift
    subject .subscribe {
        print("🔵 ", $0)
      }
    .disposed(by: disposeBag)

		subject.onNext("1")
```

Kết quả như sau:

```
🔵  next(0)
🔵  next(1)
```

Bạn sẽ thấy `subscribe` đầu tiên nhận hết các giá trị được phát ra từ subject. Và bạn tiếp tục thêm 1 `subscriber` nữa để xem sao

```swift
subject .subscribe {
        print("🔴 ", $0)
      }
    .disposed(by: disposeBag)
```

Lúc này thì `subscriber` thứ 2 nhận được giá trị `1`. Do lúc này `1` là mới nhất. Cuối cùng, ta kết thúc subject với 1 `.error`. 

```swift
    // error
    subject.onError(MyError.anError)
    
    //Subscribe 3
    subject .subscribe {
        print("🟠 ", $0)
      }
    .disposed(by: disposeBag)
```

Lúc này thì 2 subscriber trước đó sẽ nhận `.error` và subscriber mới sẽ nhận được `error`. Ta xem kết quả như sau

```
🔵  next(0)
🔵  next(1)
🔴  next(1)
🔵  error(anError)
🔴  error(anError)
🟠  error(anError)
```

Full code ví dụ trên cho bạn có hình dung tổng quát

```swift
    let disposeBag = DisposeBag()
    
    enum MyError: Error {
      case anError
    }
    
    let subject = BehaviorSubject(value: "0")
    
    //Subscribe 1
    subject .subscribe {
        print("🔵 ", $0)
      }
    .disposed(by: disposeBag)
    
    // emit
    subject.onNext("1")
    
    //Subscribe 2
    subject .subscribe {
        print("🔴 ", $0)
      }
    .disposed(by: disposeBag)
    
    // error
    subject.onError(MyError.anError)
    
    //Subscribe 3
    subject .subscribe {
        print("🟠 ", $0)
      }
    .disposed(by: disposeBag)
```

Với Behavior Subject này thì cũng không quá hack não phải không nào!

---

### Tóm tắt

* `Behavior Subject` sẽ phát đi các giá trị cuối cùng của nó cho các subscirber khi đăng kí tới nó. 
* Đảm bảo các subscriber luôn nhận được giá trị khi đăng ký tới
* Phải cung cấp giá trị ban đầu khi khởi tạo subject
* Khi subject kết thúc thì các subcriber mới sẽ nhận được `.error` hay `.completed`.

