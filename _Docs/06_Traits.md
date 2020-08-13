# 06 Traits

> Sống đơn giản cho đời thanh thản.

### Trait

Đó là phương châm chính mà phần này hướng tới. Thay vì bạn phải cất công `create` hay `subcribe` đầy đủ các sự kiện mà 1 Observable phát ra. Thì bạn có thể tạo ra các Observable đặc biệt và đơn thuần thôi. RxSwift gọi là `Trait`. Vậy nó là gì?

- **Trait** là một wrapper struct với một thuộc tính là một **Observable Sequence** nằm bên trong nó. **Trait** có thể được coi như là một sự áp dụng của **Builder Pattern** cho **Observable**.
- Để chuyển **Trait** về thành **Observable**, chúng ta có thể sử dụng operator `.asObservable()`

```swift
struct Single<Element> {
    let source: Observable<Element>
}

struct Driver<Element> {
    let source: Observable<Element>
}
...
```

*(code ví dụ mô tả thôi, đừng đè nặng vào đây nha!)*

**Các đặc điểm của Trait bao gồm:**

- Trait không xảy ra lỗi.
- Trait được observe và subscribe trên MainScheduler.
- Trait chia sẻ Side Effect.

> **Side Effect** là những thay đổi phía bên ngoài của một **scope** (khối lệnh). Trong RxSwift, Side Effect được dùng để thực hiện một tác vụ nào đó nằm bên ngoài của **scope** mà không làm ảnh hưởng tới **scope** đó.

Chúng ta có 2 loại `Trait`, một cái cho RxSwift và một cái RxCocoa. Phần Cocoa chúng ta sẽ đề cập ở các bài sau. Còn quay về Trait trong RxSwift thì chúng ta có 3 loại:

* Single
* Completable
* Maybe

Giờ đi vào sơ lược từng loại nha! Ahihi

### Single

- **Single** là một biến thể của **Observable** trong RxSwift.
- Thay vì emit được ra một chuỗi các element như Observable thì **Single** sẽ **chỉ emit ra duy nhất một element** hoặc **một error**.

Xem code ví dụ sau:

```swift
   enum FileError: Error {
        case pathError
    }
    
    let bag = DisposeBag()
    
    func readFile(path: String?) -> Single<String> {
        return Single.create { single -> Disposable in
            if let path = path  {
                single(.success("Success!"))
            } else {
                single(.error(FileError.pathError))
            }
            
            return Disposables.create()
        }
    }
```

Ta tạo ra 1 enum cho `error` và 1 túi rác quốc dân. Sau đó tạo tiếp function `readFile` với tham số `path` là 1 String Optional.

* Với `path == nil` thì trả về `error`
* Với `path != nil` thì trả về `Success!`

Function `readFile` có giá trí trả về là 1 `Single` với kiểu Output là `String`. Vì Single cũng là 1 Observable nên ta lại áp dụng toán tử  `.create` để tạo. Và quan trọng là handle các thao tác trong đó (lúc nào là error hay giá trị ....)

Sang phần subscribe nó nào!

```swift
readFile(path: nil)
        .subscribe { event in
            switch event {
            case .success(let value):
                print(value)
            case .error(let error):
                print(error)
            }
        }
        .disposed(by: bag)
```

Bạn sẽ thấy, ta sẽ `switch ... case` được giá trị mà Single trả về. Với 2 trường hợp. 

Ngoài ra, bạn

> Có thể biến 1 `Observable` thành một `Single` bằng toán tử `.asSingle()`.

Cuối cùng,

> Tới đây thì bạn đã thấy được ứng dụng RxSwift vào trong các Model gọi API rồi đó. Hay chung hơn là các `call back`.

### Completable

- Giống với **Single**, **Completable** cũng là một biến thể của **Observable**.
- Điểm khác biệt của **Completable** so với **Single** đó là nó chỉ có thể emit ra một **error** hoặc **chỉ complete** (không emit ra event mà chỉ terminate).

Ta có một ví dụ giả tưởng như sau:

```swift
    let bag = DisposeBag()
    
    enum FileError: Error {
        case pathError
        case failedCaching
    }
    
    func cacheLocally() -> Completable {
        return Completable.create { completable in
           // Store some data locally
           //...
           //...
            
            let success = true

           guard success else {
               completable(.error(FileError.failedCaching))
               return Disposables.create {}
           }

           completable(.completed)
           return Disposables.create {}
        }
    }
```

Function `cacheLocally` trả về một kiểu `Completable`. Và áp dụng cách tương tự như Single, thì sử dụng `.create` để tạo một Observabe Completable và hành vi của nó. Cách sử dụng cũng tương tự như trên.

```swift
cacheLocally()
    .subscribe { completable in
        switch completable {
            case .completed:
                print("Completed with no error")
            case .error(let error):
                print("Completed with an error: \(error)")
        }
    }
    .disposed(by: bag)
```

Hoặc cụ thể cho khỏi nhập nhèn với `onCompleted` & `onError`.

```swift
cacheLocally()
    .subscribe(onCompleted: {
                   print("Completed with no error")
               },
               onError: { error in
                   print("Completed with an error: \(error)")
               })
    .disposed(by: bag)
```

### Maybe

Đọc qua cái tên của nó thì cũng hiểu được là gì rồi. Đây là thèn ba phải nhiều nhất hội. Vì sao:

- **Maybe** cũng là một biến thể của **Observable** và là sự kết hợp giữa **Single** và **Completable**.
- Nó có thể emit **một element**, **complete mà không emit ra element** hoặc emit ra **một error**.

**Đặc điểm của Maybe:**

- Có thể phát ra duy nhất một element, phát ra một error hoặc cũng có thể không phát ra bất cứ evenet nào và chỉ complete.
- Sau khi thực hiện bất kỳ 1 trong 3 sự kiện nêu trên thì Maybe cũng sẽ terminate.
- Không chia sẻ Side Effect.

Ví dụ thôi

```swift
   let bag = DisposeBag()
    
    enum MyError: Error {
        case anError
    }
    
    func generateString() -> Maybe<String> {
        return Maybe<String>.create { maybe in
            maybe(.success("RxSwift"))
            
            // OR
            
            maybe(.completed)
            
            // OR
            
            maybe(.error(MyError.anError))
            
            return Disposables.create {}
        }
    }
```

Về `Maybe` thì tương tự như 2 cái trên về cách tạo và xử lý. Nó có thể phát đi cái gì cũng đc, linh hoạt hơn. Dùng cho cách xử lý mà có thể trả không cần phát đi gì cả hoặc kết thúc.

Cách `subscribe` như sau:

```swift
generateString()
        .subscribe { maybe in
            switch maybe {
            case .success(let element):
                print("Completed with element \(element)")
            case .completed:
                print("Completed with no element")
            case .error(let error):
                print("Completed with an error \(error.localizedDescription)")
            }
    }
    .disposed(by: bag)
```

Hoặc full option như sau:

```swift
generateString()
        .subscribe(onSuccess: { element in
            print("Completed with element \(element)")
        }, onError: { error in
            print("Completed with an error \(error.localizedDescription)")
        }, onCompleted: {
            print("Completed with no element")
        })
        .disposed(by: bag)
```

Và còn một điều nữa,

> Bạn có thể dùng toán tử `.asMayBe()` để biến 1 `Observable` thành 1 `Maybe`.

---

### Tóm tắt

* Trait trong RxSwift và RxCocoa có thể xem là các Observable đặc biệt. Chỉ đảm đương vài tính chất hoặc 1 tính chất nào đó
* Trong RxSwift thì bao gồm
  * Single
  * Completable
  * Maybe
* Có thể chuyển đổng từ Observable sequence thành 1 Trait thông 2 toán tử sau:
  * `.asSingle()`
  * `.asMaybe()`

