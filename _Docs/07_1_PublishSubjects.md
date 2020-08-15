# 07.1 Publish Subjects

Publish Subject là loại Subject mà chỉ cung cấp cho bạn những giá trị mới nhất từ thời điểm bạn subscribe tới nó. Khi nào subscriber huỹ đăng kí hoặc `.error` hoặc `.completed` thì sẽ dừng việc phát.

Ta có ví vụ sau để bạn dễ hình dung hơn

```swift
    let subject = PublishSubject<String>()
    
    subject.onNext("1")
    
    let subscription1 = subject
        .subscribe(onNext: { value in
            print("Sub 1: ", value)
        })
    
    subject.onNext("2")
    
    let subscription2 = subject
        .subscribe(onNext: { value in
            print("Sub 2: ", value)
        })
    
    subject.onNext("3")
    subject.onNext("4")
    subject.onNext("5")
```

Khi thực thi thì bạn sẽ thấy

- Giá trị `1` sẽ không nhận được, vì trước thời điểm phát đó thì không có subscribe nào tới subject
- `subscription1` sẽ nhận được giá trị `2`, còn `subscription2` sẽ không nhận được `2` vì đã subscribe sau khi phát 2
- Các giá trị liên tiếp sau thì cả 2 đều nhận được

Đơn giản phải không nào. Tiếp theo bạn thêm túi rác quốc dân vào để quan sát tiếp

```swift
let disposeBag = DisposeBag()
```

Và khi `subscription2` đơn phương `dispose()` thì sẽ không nhận được các giá trị mà subject phát tiếp.

```swift
		subscription2.dispose()
    subject.onNext("6")
    subject.onNext("7")
```

Và khi `.completed` hay `.error` thì sao

```swift
		subject.on(.completed)
    subject.onNext("8")
```

Lúc này thì `subject` không thể phát ra bất cứ gì sau khi gọi `.completed` và các subscriber cũng không nhận được gì cả. Chúng ta thử thêm lần nữa subscribe sau khi subject đã phát đi  `.completed` thì như thế nào

```swift
subject .subscribe {
        print("sub 3: ", $0.element ?? $0)
    }
    .disposed(by: disposeBag)
```

Lúc này sẽ nhận được sự kiện `completed` mặc dù `subject` đã kết thúc. Có điều gì hư cấu ở đây rồi, vì theo định nghĩa thì các subscriber sẽ nhận được giá trị mới nhất được phát đi từ sau thời điểm đăng kí. Theo đó thì lúc này sẽ không nhận được gì hết. Chúng ta thử tiếp với việc edit lại `subscription1` xem như thế nào.

```swift
let subscription1 = subject
        .subscribe(onNext: { value in
            print("Sub 1: ", value)
        }, onCompleted: {
            print("sub 1: completed")
        })
```

Kết quả ra như sau:

```
Sub 1:  2
Sub 1:  3
Sub 2:  3
Sub 1:  4
Sub 2:  4
Sub 1:  5
Sub 2:  5
Sub 1:  6
Sub 1:  7
sub 1: completed
sub 3:  completed
```

Và điều này dẫn tới thì khi `subject` đã `.completed` thì các subscriber mới chỉ nhận được sự kiện đó mà thôi. Xem full code lại cho dễ hình dung tổng quát nào

```swift
    let disposeBag = DisposeBag()
    let subject = PublishSubject<String>()
    
    subject.onNext("1")
    
		// subscribe 1
    let subscription1 = subject
        .subscribe(onNext: { value in
            print("Sub 1: ", value)
        }, onCompleted: {
            print("sub 1: completed")
        })
        
		// emit
    subject.onNext("2")
    
		// subscribe 2
    let subscription2 = subject
        .subscribe(onNext: { value in
            print("Sub 2: ", value)
        }, onCompleted: {
            print("sub 2: completed")
        })
    
		// emit
    subject.onNext("3")
    subject.onNext("4")
    subject.onNext("5")

    // dispose subscription2
    subscription2.dispose()

		// emit
    subject.onNext("6")
    subject.onNext("7")

    // completed
    subject.on(.completed)
		// emit
    subject.onNext("8")
    
		// subscribe 3
    subject .subscribe {
        print("sub 3: ", $0.element ?? $0)
    }
    .disposed(by: disposeBag)
```



Qua các ví dụ trên thì cũng cho bạn thấy được Publish Subject là như thế nào rồi. EZ phải không :D

---

### Tóm tắt

* `Publish Subject` là một loại Subject. Chỉ phát giá trị mới nhất của mình cho các subscriber.
* Khi khởi tạo Publish Subject thì không cần cung cấp giá trị ban đầu cho nó.
* Các giá trị đã phát trước thời điểm mà subscriber đăng kí thì sẽ không nhận được. Subscriber chỉ nhận được các giá trị phát sau thời điểm đăng ký.
* Khi Publish Subject kết thúc (`.completed` hay `.error`) thì không thể phát đi giá trị nào nữa. Các subcriber hiện tại và các subscriber tương lai nếu đăng kí tới, thì chỉ nhận được `.completed` hay `.error` 

