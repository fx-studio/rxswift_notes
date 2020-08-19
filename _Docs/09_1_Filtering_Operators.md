# 09.1 Filtering Operators

Bạn đã trãi qua các phần cơ bản với RxSwift, nếu như bạn học kĩ và tiến từng bước chắc chắn thì tới đây bạn sẽ bắt đầu tăng tốc. Và luyện tập nhiều hơn để quen với thế giới Rx.

Với nhóm `operators` này giúp cho bạn sẽ có được những giá trị mà bạn mong muốn nhận được. Và bạn đã dùng `.filter` trong code iOS trước đây thì nó cũng có ý nghĩa tương tự. Nhưng phần hay còn rất nhiều ở sau. 

Trong phần này bạn chỉ cần tạo 1 Playground để code demo. Bạn hãy tạo nó trong iOS Project đã sử dụng từ những bài đầu tiên. Còn bây giờ thì

> Bắt đầu thôi!

### 1. Ignoring operators

Bắt đầu là nhóm toán tử cho phép việc bỏ qua sự tiếp nhận các phần tử một Observable.

#### 1.1. `ignoreElements`

Toán tử này thì sẽ bỏ qua tất cả các giá trị `.next` phát ra. Tuy nhiên, nó sẽ cho phép các sự kiện `.completed` & `.error`.

Rất đơn giản phải không nào. Dễ hiểu hơn nữa thì hãy xem đoạn code sau.

```swift
    let subject = PublishSubject<String>()
    let bag = DisposeBag()
    
    subject
    .ignoreElements()
        .subscribe { event in
              print(event)
            }
        .disposed(by: bag)
    
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    subject.onCompleted()
```

Khi bạn thực thi đoạn code trên thì chỉ thấy nhận được mỗi `completed`. Và trong khi gõ code thì Xcode sẽ không suggestion một function `subscribe` với chỉ 2 tham số `onCompleted` và `onError`.

#### 1.2. `elementAt(_:)`

Toán tử tiếp theo sẽ giúp bạn lấy đúng phần tử thứ `n` nào đó. Và theo truyền thống lập trình, việc đếm sẽ bắt đầu từ `0`. Sau đây là code ví dụ cho bạn, à chỉ cần thay toán tử cho đoạn code trên là được

```swift
    let subject = PublishSubject<String>()
    let bag = DisposeBag()
    
    subject
    .elementAt(2)
        .subscribe { event in
              print(event)
            }
        .disposed(by: bag)
    
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    subject.onCompleted()
```

Kết quả thực thi như sau

```swift
next(3)
completed
```

Tất nhiên, 2 sự kiện `completed` và `error` thì vẫn nhận được. Và khi bạn xoá dòng code `subject.onCompleted()` này đi thì vẫn thấy kết quả như trên. Mặc dù `subject` của bạn ko hề kết thúc. 

Từ đó thì một điều thú vị nữa là

> Khi toán tử `elementAt` này đạt được mục đích của nó thì subscription sẽ tự động kết thúc.

#### 1.3. `filter{ }`

Khi bạn có quá nhiều phần tử cần phải lấy thì 2 toán tử trên sẽ không đảm bảo cho bạn. Giờ chúng ta sẽ sử dụng toạn tử `filter` để có thể lấy nhiều phần tử mà mình mong muốn.

Bạn xem qua đoạn code sau

```swift
    let bag = DisposeBag()
    let array = Array(0...10)
    
    Observable.from(array)
        .filter { $0 % 2 == 0 }
        .subscribe(onNext: {
            print($0) })
        .disposed(by: bag)
```

Trong đó

* `array` là 1 mãng Int với các giá trị từ 0 đến 10
* `.from` để tạo ra 1 Observable và phát ra các giá trị lần lượt trong array trên
* `.filter` với điều kiện lấy những giá trị chẵn

Tuỳ thuộc vào yêu cầu bài toán của bạn thì sẽ có điều kiện khác để phù hợp.

### 2. Skip Operators

#### 2.1. `skip(_:)`

Đại diện cho nhóm toán tử này là toán tử `skip`. Với 1 tham số truyền vào cho nó, là số lượng các phần tử bị bỏ đi. Và subscriber sẽ không nhận chúng. Subscriber sẽ nhận các phát ra thứ `n` cho đến khi Observable kết thúc.

Demo code như sau

```swift
    let disposeBag = DisposeBag()
    
    Observable.of("A", "B", "C", "D", "E", "F")
        .skip(3) 
        .subscribe(onNext: {
            print($0) })
        .disposed(by: disposeBag)
```

Subscription sẽ bắt đầu từ giá trị lần thứ `3` phát đi cho đến khi Observable kết thúc.

#### 2.2. `skipWhile { }`

Toán tử này hơn hại não một chút. Nó cũng tương tự như là `filter`. Tuy nhiên, nó có một số đặc điểm sau

* Sẽ bỏ qua các phần tử mà thoải điều kiện của nó, tức là `true`
* Từ phần phần đầu tiên không thoả điều kiện (tức là `false` ) thì sẽ nhận.
* Các phần tử tiếp theo sau đó vẫn được nhận (đây là điểm khác với filter)

```swift
    let bag = DisposeBag()
    
    Observable.of(2, 4, 8, 9, 2, 4, 5, 7, 0, 10)
        .skipWhile { $0 % 2 == 0 }
        .subscribe(onNext: {
            print($0) })
        .disposed(by: bag)
```

Kết quả thực thi như sau

```
9
2
4
5
7
0
10
```

Bạn sẽ thấy 3 phần tử đầu tiên thoả mãn điều kiện là chẵn thì sẽ bị bỏ qua. Trong khi, các phần tử chẵn phát ra sau khi điệu kiện đã sai thì vẫn nhận được.

#### 2.3. `skipUntil(_:)`

Toàn bộ trên là bạn đã lọc hoặc bỏ qua các phần tử với các kiều kiện tĩnh. Còn với `skipUntil` thì sẽ sử dụng một điều kiện động. Ở đây chính là dùng một `observable` khác để làm điều kiện.

Code ví dụ demo như sau

```swift
    let bag = DisposeBag()
    
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    subject
        .skipUntil(trigger)
        .subscribe(onNext: { value in
            print(value)
        })
        .disposed(by: bag)
    
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    subject.onNext("4")
    subject.onNext("5")
    
    trigger.onNext("XXX")
    
    subject.onNext("6")
    subject.onNext("7")
```

Tạo ra 2 subject. Sử dụng toán tử `skipUntil` với tham số là subject kia. Thì subscription sẽ vẫn chờ cho tới khi `trigger` phát ra giá trị đầu tiên. Thì các giá trị của `subject` sau đó phát đi thì mới nhận được.

OKAY! EZ phải không nào!

### 3. Taking Operators

Có toán tử sau đây sẽ ngược lại với skip trên.

#### 3.1. `take(_:)`

Toán tử `take` này cần 1 tham số là Int. Nó sẽ quy định số lượng phần tử cần lấy từ  Observable phát đi. Nếu đủ số lượng thì sẽ tự động kết thúc.

Code ví dụ như sau

```swift
    let bag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9)
        .take(4)
        .subscribe(onNext: { (value) in
            print(value)
        })
        .disposed(by: bag)
```

Kết quả thực thi

```
1
2
3
4
```

Chỉ nhận được 4 giá trị đầu tiên. Các giá trị sau sẽ không nhận được.

#### 3.2. `takeWhile { }`

Toán tử này sẽ giúp bạn lấy hết những giá trị đầu tiên mà thoả mãn điều kiện. Cho tới khi phần tử đầu tiên không thoải mãn điều kiện thì từ đó và tất cả các phần tử sau sẽ không nhận được.

```swift
    let bag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9)
        .takeWhile { $0 < 4 }
        .subscribe(onNext: { (value) in
            print(value)
        })
        .disposed(by: bag)
```

Vẫn là ví dụ trên, nhưng chúng ta thay đổi toán tử thành `takeWhile` với điều kiện các phân tử `< 4` thì sẽ nhận được 4 phần tử đầu tiên phát đi.

#### `enumerated()`

Một sự kết hợp xịn xò hơn nữa là với toán tử `enumerated`. Nó sẽ thêm `index` cho giá trị của bạn, kết hợp với giá trị của element của Observable tạo nên 1 cặp Tuple.

Xem ví dụ sau với điều kiện được nâng cấp hơn

```swift
    let bag = DisposeBag()
    
    Observable.of(2, 4, 6, 8, 0, 12, 1, 3, 4, 6, 2)
        .enumerated()
        .takeWhile { index, value in
            value%2 == 0 && index < 3
        }
        .subscribe(onNext: { (value) in
            print(value)
        })
        .disposed(by: bag)

```

Sử dụng 2 điều kiện là

* các giá trị nhận được là số chẵn
* nằm trong 3 giá trị đầu tiên

Hi vọng nó sẽ giúp bạn thêm vũ khí nữa.

#### 3.3. `takeUntil(_:)`

Đây là phiên bản đối nghịch với `skipUntil`.Nên cũng dễ hiểu thôi, lấy tất cả các phần tử đầu tiên thoả mãn điều kiện

```swift
    let bag = DisposeBag()
    
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    subject
        .takeUntil(trigger)
        .subscribe(onNext: { value in
            print(value)
        })
        .disposed(by: bag)
    
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    subject.onNext("4")
    subject.onNext("5")
    
    trigger.onNext("XXX")
    
    subject.onNext("6")
    subject.onNext("7")
```

Sử dụng lại ví dụ của skipUntil nhưng thay bằng toán tử `takeUntil` thì bạn sẽ nhận được tất cả các giá trị trước khi `trigger` phát ra giá trị đầu tiên.

### 4. Distinct operators

Để bắt đầu cho toán tử mới này thì bạn xem code sau

```swift
    let disposeBag = DisposeBag()
    
    Observable.of("A", "A", "B", "B", "A", "A", "A", "C", "A")
        .distinctUntilChanged()
        .subscribe(onNext: {
            print($0)
            
        })
        .disposed(by: disposeBag)
```

Kết quả thực thi như sau

```
A
B
A
C
A
```

So với array đầu vào thì bạn sẽ thấy rằng, các phần tử giống nhau liên tiếp thì sẽ bị loại bỏ. Như vậy với 2 giá trị `A` thì sẽ giữ lại 1. Với 3 giá trị `A` liên tiếp thì giữ lại 1.

Toán tử `distinctUntilChanged` sẽ thanh lọc các giá trị trùng nhau liên tiếp trong chuỗi các giá trị được phát đi.

Nhưng ở trên là áp dụng cho các kiểu dữ liệu có thể so sánh được. Hay còn gọi là `Equatable`. Còn với các custom type thì như thế nào.

Ta có ví dụ code sau

```swift
    struct Point {
        var x: Int
        var y: Int
    }
    
    let disposeBag = DisposeBag()
    
    let array = [ Point(x: 0, y: 1),
                  Point(x: 0, y: 2),
                  Point(x: 1, y: 0),
                  Point(x: 1, y: 1),
                  Point(x: 1, y: 3),
                  Point(x: 2, y: 1),
                  Point(x: 2, y: 2),
                  Point(x: 0, y: 0),
                  Point(x: 3, y: 3),
                  Point(x: 0, y: 1)]
    
    Observable.from(array)
        .distinctUntilChanged { (p1, p2) -> Bool in
            p1.x == p2.x
        }
        .subscribe(onNext: { point in
            print("Point (\(point.x), \(point.y))")
        })
        .disposed(by: disposeBag)
```

Trong đó

* Định nghĩa ra 1 Struct `Point` với 2 thuộc tính là `x` & `y`
* Tạo 1 `array` với các phân tử là Point. Bạn để ý thì sẽ thấy các point đó thì có vài point liên tiếp có `x` bằng nhau
* Tạo ra `Observable` từ array trên và phát đi liên tiếp cá giá trị của array
* `distinctUntilChanged` lúc này chọn là 1 biểu thức với giá trị trả về từ 1 closue
* Trong closure đó ta sẽ so sánh `x` của 2 point liên tiếp nhau nhau. Nếu chúng bằng nhau thì bỏ qua phần tử tiếp theo đó.
* `subscribe` như trước đây

Vì Struct Point lúc này không thể so sánh được với nhau, nên chúng ta sẽ so sánh với 1 thuộc tính của chúng. Kết quả thực thi ra như sau

```
Point (0, 1)
Point (1, 0)
Point (2, 1)
Point (0, 0)
Point (3, 3)
Point (0, 1)
```



---

OKAY! Tới đây thì mình xin kết thúc bài viết về nhóm toán tử Filtering Operators này. Cảm ơn bạn đã đọc bài viết!