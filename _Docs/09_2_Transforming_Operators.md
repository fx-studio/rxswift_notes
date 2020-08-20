# 09.2 Transforming Operators

Chương này bao gồm những Operators quan trọng nhất của RxSwift. Nó tập trung vào việc biến đổi.

* Biến đổi từ kiểu dữ liệu này thành kiểu dữ liệu khác
* Biến đổi Observable sequence này thành Observable sequence khác
* ...

Trong Swift thì cũng có các function tương tự như `map` & `flatMap`. Nếu bạn đã biết tới nó rồi thì các kiến thức đó sẽ giúp bạn nhiều trong phần này.

Chúng ta vẫn sử dụng project trước đây, bạn tạo mới 1 Playground nữa để dùng làm demo code. Nếu bạn đã quên cách tạo thì có thể tham khảo lại các bài trước đó. Còn bây giờ thì

> Bắt đầu thôi!

### 1. Transforming elements

#### 1.1. `toArray`

Việc nhận từ phần tử một thì rất tốn thời gian, đôi khi bạn muốn nhận hết một lèo tất cả phần tử của 1Observable thì hãy dùng toán tử này. Nó sẽ giúp bạn gom tất cả phần tử được phát đi thành 1 array. Việc này sẽ thực hiện sau khi Observable kết thúc.

Xem đoạn code ví dụ sau

```swift
    let bag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6)
        .toArray()
        .subscribe(onSuccess: { value in
            print(value)
        })
        .disposed(by: bag)
```

Thực thi code thì bạn sẽ thấy giá trị nhận được là một Array Int. Điểm đặc biệt ở đây là với toán tử `toArray` thì nó sẽ biến đổi Observable đó về thành là 1 `Single`. Khi đó thì chỉ cho `.onSuccess` hoặc `.error` mà thôi.

#### 1.2. `map`

Toán tử `map` thần thành. Xuất hiện nhiều ở nhiều ngôn ngữ và ý nghĩa không thay đổi. Khi sử dụng toán tử này thì có một số đặc điểm sau

* Biến đổi từ kiểu dữ liệu này thành kiểu dữ liệu khác cho các phần tử nhận được
* Việc biến đổi được xử lý bằng một closure
* Sau khi biến đổi nên bạn subscribe thì hãy chú ý tới kiểu dữ liệu mới đó, tránh bị nhầm lẫn.

Xem ví dụ code thôi!

```swift
    let bag = DisposeBag()
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    Observable<Int>.of(1, 2, 3, 4, 5, 10, 999, 9999, 1000000)
        .map { formatter.string(for: $0) ?? "" }
        .subscribe(onNext: { string in
            print(string)
        })
        .disposed(by: bag)
```

Thực thi code như sau

```
one
two
three
four
five
ten
nine hundred ninety-nine
nine thousand nine hundred ninety-nine
one million
```

Đoạn code trên sẽ biến đỗi các giá trị là `Int` thành `String` và hàm biến đổi được thực hiện dựa vào một đối tượng `NumberFormatter` dùng để đọc các số đó. Thật là ảo diệu phải không nào.

Thử tiếp với toán tử `enumerated` kết hợp với `map` xem như thế nào. Ví dụ như sau

```swift
    let disposeBag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6)
        .enumerated()
        .map { index, integer in
            index > 2 ? integer * 2 : integer
        }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
```

Đây là một pha bẻ lái đi vào lòng người

* Từ một Observable với `Int` là kiểu dữ liệu cho các phần tử được phát đi
* `enumerated` biến đổi Observable đó với kiểu dữ liệu giờ là 1 `Tuple`, do sự kết hợp thêm `index` từ nó
* Lại qua `map` để tính toán và biến đổi nó về lại 1 `Int`
* `subscribe` thì như bình thường

Đây là cách bạn lấy được `index` của các phần tử rồi sau đó biến chúng về lại kiểu giá trị ban đầu. Rất chi là có ý nghĩa.

### 2. **Transforming inner observables**

Đây là nhóm toán tử phức tạp. Để sử dụng là ví dụ cho các ví tiếp theo thì mình sẽ khai báo 1 struct như sau

```swift
struct User {
    let message: BehaviorSubject<String>
}
```

Trong đó

* `User` là tên struct để tạo ra những đối tượng người dùng
* `message` là thông điệp mà đối tượng nào đó muốn phát đi

OKAY! bắt đầu loạn não thôi.

#### 2.1. `flatMap`

Tên của nó có nghĩa là làm phẳng. Vậy là làm phẳng những gì?

Lần này chúng ta có 1 toán tử, sẽ biến đổi nhiều Observable thành 1 Observable. Mà các Observable đó là các giá trị do 1 Observable lớn hơn phát đi. Ta có thể mô tả qua như sau

* Ta có 1 Observable gốc có kiểu dữ liệu cho các `element` của nó là 1 kiểu thuộc `Observable`
* Vì các `element` có kiểu Observable thì nó có thể phát dữ liệu. Lúc này chúng ta có rất nhiều `stream` phát đi
* Muốn nhận được tất cả dữ liệu từ tất cả các `element` của Observable gốc thì ta dùng toán tử `flatMap`
* Chúng sẽ hợp thể tất cả các giá trị của các `element` đó phát đi thành 1 Observable ở đầu cuối. Mọi công việc `subcirbe` vẫn bình thường và ta không hề hay biết gì ở đây.

Chúng ta sẽ đi vào ví dụ cho dễ hiểu nào

```swift
    let bag = DisposeBag()
    
    let cuTy = User(message: BehaviorSubject(value: "Cu Tý chào bạn!"))
    let cuTeo = User(message: BehaviorSubject(value: "Cu Tèo chào bạn!"))
    
    let subject = PublishSubject<User>()
```

Bắt đầu với việc khởi tạo các đối tượng

* `bag` thì khỏi nói rồi
* `cuTy` & `cuTeo` là 2 đối tượng của Struct `User` trên. Chúng cần phải khởi tạo `message` của nó. Và kiểu dữ liệu của `message` là 1 `BehaviorSubject`. Tức là thuộc tính này phát đc dữ liệu đi
* `subject` là nơi thực hiện toán từ `flatMap`

Cuộc vui giờ mới bắt đầu. Tiến hành sử dụng `flatMap` nào.

```swift
    subject
        .flatMap { $0.message }
        .subscribe(onNext: { msg in
            print(msg)
        })
        .disposed(by: bag)
```

Ta sử dụng `flatMap` để biến đổi từ `User` về là `String` vì kiểu dữ liệu phát đi của thuộc tính `message` là String. Tiếp theo tiến hành phát tín hiệu.

```swift
    // subject
    subject.onNext(cuTy)
    
    // cuTy
    cuTy.message.onNext("Có ai ở đây không?")
    cuTy.message.onNext("Có một mình mình thôi à!")
    cuTy.message.onNext("Buồn vậy!")
    cuTy.message.onNext("....")
    
    // subject
    subject.onNext(cuTeo)
    
    // cuTy
    cuTy.message.onNext("Chào Tèo, bạn có khoẻ không?")
    
    // cuTeo
    cuTeo.message.onNext("Chào Tý, mình khoẻ. Còn bạn thì sao?")
    
    // cuTy
    cuTy.message.onNext("Mình cũng khoẻ luôn")
    cuTy.message.onNext("Mình đứng đây từ chiều nè")
    
    // cuTeo
    cuTeo.message.onNext("Kệ Tý. Ahihi")

```

Bạn hãy chú ý

* Có 3 đối tượng luân phiên nhau phát dữ liệu
* `subject` đóng vài trò là Observable gốc, sẽ phát đi các dữ liệu là các Observable khác
* `cuTy` & `cuTeo` sẽ phát đi mà `String`

Với `flatMap` thì chúng sẽ được gom lại thành 1 Observable và các subscriber sẽ nhận được trọn vẹn. Thực thi như sau:

```
Cu Tý chào bạn!
Có ai ở đây không?
Có một mình mình thôi à!
Buồn vậy!
....
Cu Tèo chào bạn!
Chào Tèo, bạn có khoẻ không?
Chào Tý, mình khoẻ. Còn bạn thì sao?
Mình cũng khoẻ luôn
Mình đứng đây từ chiều nè
Kệ Tý. Ahihi
```

#### 2.2. `flatMapLatest`

Cái tên thì bạn sẽ cũng hình dung ra rồi, đó là sự kết hợp của

> `map` + `switchLatest` = `flatMapLatest`

Về cơ bản thì giống như `flatMap` về việc nhập các Observable lại với nhau. Tuy nhiên, điểm khác là nó sẽ chỉ phát đi giá trị của Observable cuối cùng tham gia vào. Ví dụ

* Có 3 Observable là `O1`, `O2` và `O3` join vào lần lượt
* `flatMapLatest` sẽ biến đổi các Observable đó thành 1 Observable duy nhất
* Giá trị nhận được tại một thời điểm chính ta giá trị của phần tử cuối cùng join vào lúc đó

Khó hiểu phải không nào, xem code ví dụ thôi!

```swift
    let bag = DisposeBag()
    
    let cuTy = User(message: BehaviorSubject(value: "Tý: Cu Tý chào bạn!"))
    let cuTeo = User(message: BehaviorSubject(value: "Tèo: Cu Tèo chào bạn!"))
    
    let subject = PublishSubject<User>()
    
    subject
        .flatMapLatest { $0.message }
        .subscribe(onNext: { msg in
            print(msg)
        })
        .disposed(by: bag)
    
    // subject
    subject.onNext(cuTy)
    
    // cuTy
    cuTy.message.onNext("Tý: Có ai ở đây không?")
    cuTy.message.onNext("Tý: Có một mình mình thôi à!")
    cuTy.message.onNext("Tý: Buồn vậy!")
    cuTy.message.onNext("Tý: ....")
    
    // subject
    subject.onNext(cuTeo)
    
    // cuTy
    cuTy.message.onNext("Tý: Chào Tèo, bạn có khoẻ không?")
    
    // cuTeo
    cuTeo.message.onNext("Tèo: Chào Tý, mình khoẻ. Còn bạn thì sao?")
    
    // cuTy
    cuTy.message.onNext("Tý: Mình cũng khoẻ luôn")
    cuTy.message.onNext("Tý: Mình đứng đây từ chiều nè")
    
    // cuTeo
    cuTeo.message.onNext("Tèo: Kệ Tý. Ahihi")
```

À, mà là ví dụ trên thôi. Chỉ theo bằng `flatMapLatest` cho `flatMap` và thêm chút vào message cho dễ phân biệt. Xem kết quả thực thi trước

```
Tý: Cu Tý chào bạn!
Tý: Có ai ở đây không?
Tý: Có một mình mình thôi à!
Tý: Buồn vậy!
Tý: ....
Tèo: Cu Tèo chào bạn!
Tèo: Chào Tý, mình khoẻ. Còn bạn thì sao?
Tèo: Kệ Tý. Ahihi
```

Sau khi, `cuTeo` join vào thì `cuTy` nói chuyện. Tuy nhiên, `subject` không nhận được tín hiệu gì từ nó. Buồn thật!

Hi vọng qua ví dụ trên bạn đã hiểu được phần nào về `flatMapLatest`. Còn nó có rất nhiều trường hợp có thể áp dụng vào. 

### 3. **Observing events**

Với 2 toán tử trên, bạn có suy nghĩ nếu chúng phát đi `error` hay `completed` thì như thế nào. Sẽ sụp đổ tất cả hay làm ra sao .... Nhưng chắc một điều rằng, bạn không thể nào quản lý được hết tất cả chúng. Nhất là khi các Observable đó là 1 property của một đối tượng khác.

Sử dụng lại ví dụ trên với 2 người bạn `cuTeo` & `cuTy` để xem thử lỗi sẽ như thế nào.

````swift
    enum MyError: Error {
      case anError
    }
    
    let bag = DisposeBag()
    
    let cuTy = User(message: BehaviorSubject(value: "Tý: Cu Tý chào bạn!"))
    let cuTeo = User(message: BehaviorSubject(value: "Tèo: Cu Tèo chào bạn!"))
    
    let subject = PublishSubject<User>()
    
    let roomChat = subject
        .flatMapLatest { $0.message }
        
     roomChat
        .subscribe(onNext: { msg in
            print(msg)
        })
        .disposed(by: bag)
    
    subject.onNext(cuTy)
    
    cuTy.message.onNext("Tý: A")
    cuTy.message.onNext("Tý: B")
    cuTy.message.onNext("Tý: C")
    
    cuTy.message.onError(MyError.anError)
    cuTy.message.onNext("Tý: D")
    cuTy.message.onNext("Tý: E")
    
    subject.onNext(cuTeo)
       
    cuTeo.message.onNext("Tèo: 1")
    cuTeo.message.onNext("Tèo: 2")
````

Bạn chú ý tới việc `cuTy` phát ra 1 `onError` nha. Thực thi đoạn code trên và xem kết quả như thế nào

`````
Tý: Cu Tý chào bạn!
Tý: A
Tý: B
Tý: C
Unhandled error happened: anError
`````

Vâng, toàn bộ đã bị sụp đổ. Chúng ta không thể nào handle được các Observable như `cuTy` phát đi `error` hay can thiệp vào property của nó. Để giải quyết chúng nó thì ta có

#### `materialize`

Bạn hãy sử lại đoạn code sau với việc thêm toán tử `materialize`

```swift
    let roomChat = subject
        .flatMapLatest {
            $0.message.materialize()
        }
```

Xem kết quả như thế nào

```
next(Tý: Cu Tý chào bạn!)
next(Tý: A)
next(Tý: B)
next(Tý: C)
error(anError)
next(Tèo: Cu Tèo chào bạn!)
next(Tèo: 1)
next(Tèo: 2)
```

Chúng ta đã nhận hết các phần tử có thể nhận, kể cả `error`. Tuy nhiên, có điều lạ ở đây. Nó chính là việc thay vì nhận các giá trị của `.next` thì bây giờ bất cứ `event` nào cũng sẽ bị biến thành giá trị hết. Và khi trỏ vào `roomChat` và nhấn giữ Option + click chuột thì bạn sẽ thấy kiểu dữ liệu của nó là `Observable<Event<Int>>`

> Như vậy, toán tử `materialize` sẽ biến đổi các `event` của Observable thành một `element`.

#### `dematerialize`

Để biến đổi ngược lại thì như thế nào. Vì chúng ta cần giá trị chứ ko cần `event`. Trái ngược với toán tử trên thì `dematerialize` sẽ biến đổi các `event` và tách ra các `element`.

Nói nôm na là bạn có để lấy lại được giá trị từ nó. Edit lại đoạn code ví dụ đó

```swift
     roomChat
        .filter{
            guard $0.error == nil else {
                print("Lỗi phát sinh: \($0.error!)")
                return false
            }
            
            return true
        }
        .dematerialize()
        .subscribe(onNext: { msg in
            print(msg)
        })
        .disposed(by: bag)

```

Trong đó

* Dùng `filter` để lọc đi các `event` là error
* `dematerialize` chuyển đổi các giá trị là event `.next` thành các `element` 
* `subscribe` như bình thường

Thực thi code thì bạn sẽ thấy điều kì diệu

```
Tý: Cu Tý chào bạn!
Tý: A
Tý: B
Tý: C
Lỗi phát sinh: anError
Tèo: Cu Tèo chào bạn!
Tèo: 1
Tèo: 2
```

Vừa nhận được giá trị, vừa có thể bắt được `error` nữa.

---

Qua trên cũng là kết thúc của phần **Transforming Operators** đầy thú vị này rồi. Hẹn bạn ở phần tiếp theo. Thank you!

