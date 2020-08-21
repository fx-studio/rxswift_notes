# 09.3 Combining Operators

Đây là nhóm toán tứ thứ ba. Bạn đã trải qua rất nhiều toán tử rồi. Từ toạ, lọc và biến đổi. Đến đây chúng ta sẽ kết hợp lại. Và cũng như các phần trước, để ví dụ code demo thì bạn có thể sử dụng project trước. Tạo một playground để thao tác với nhóm toán tử Combining.

> Bắt đầu thôi!

### 1. **Prefixing and concatenating**

#### 1.1. `startWith(_:)`

Đôi lúc chúng ta cần thêm một phần tử trước khi nó bắt đầu. Để là gì, thì tuỳ ý bạn. Có khi đơn giản chỉ là muốn nó luôn có 1 giá trị nào đó đầu tiên mà thôi. Toán tử này là `startWith`

Tham số truyền vào chính là giá trị mà có cùng kiểu giá trị với phần tử của Observable phát đi.

Ví dụ đoạn code sau

```swift
    let bag = DisposeBag()
    
    Observable.of("B", "C", "D", "E")
        .startWith("A")
        .subscribe(onNext: { value in
            print(value)
        })
        .disposed(by: bag)
```

Bạn sẽ thấy với Observable phát ra các giá trị bắt đầu từ `B`. Thì để chèn thêm 1 phần tử ở trước ta dùng toán tử `startWith` và thêm `A` vào. Kết quả ra như sau

```
A
B
C
D
E
```

Quá dễ phải không nào!

#### 1.2. `Observable.concat`

Ta xem qua đoạn code sau

```swift
    let bag = DisposeBag()
    
    let first = Observable.of(1, 2, 3)
    let second = Observable.of(4, 5, 6)

    let observable = Observable.concat([first, second])

    observable
        .subscribe(onNext: { value in
            print(value)
        })
        .disposed(by: bag)
```

Bạn sẽ nhận ra là `observable` được tạo ra từ toán tử `concat` và 1 tham số là 1 array Observable. Thử chạy kết quả xem như thế nào

```
1
2
3
4
5
6
```

Tới đây thì bạn cũng hiểu ra rồi. `concat` sẽ nối các phần tử của nhiều sequence observable lại với nhau.

#### 1.3. `concat`

Toán tử trên là một phương thức tạo Observable từ việc nối nhiều Observable lại với nhau. Còn đây là toán tử `concat` dùng với 1 đối tượng observable. Nó sẽ nối các phần tử của một đối tượng observable khác vào. 

Phương pháp này giúp bạn có thêm 1 lúc nhiều phần tử, khắc phục nhược điểm của phần 1.

Code ví dụ như sau

```swift
    let bag = DisposeBag()
    
    let first = Observable.of("A", "B", "C")
    let second = Observable.of("D", "E", "F")
    
    let observable = first.concat(second)
    
    observable
        .subscribe(onNext: { value in
            print(value)
        })
        .disposed(by: bag)
```

Ta dùng `first.concat` với tham số là `second`. Kết quả in ra như sau

```
A
B
C
D
E
F
```

Cũng khá là đơn giản phải không nào. Đặc điểm của toán tử này là sử dụng bănhf 1 đối tượng Observable.

> Chú ý: Toán tử `concat` này sẽ đợi Observable gốc hoàn thành. Thì sau đó Observable thử 2 tiếp tục.

#### 1.4. `concatMap`

Khi có từ `map` trong trên của 1 toán tử thì bạn cũng sẽ rằng sẽ có sự biến đổi về kiểu dữ liệu ở đây. Toán tử này đảm bảo việc các chuỗi được đóng lại trước khi chuỗi tiếp theo được đăng kí vào. Đảm vảo thứ tự trình tự.

Code ví dụ

```swift
    let bag = DisposeBag()
    
    let cities = [ "Mien Bac" : Observable.of("Ha Noi", "Hai Phong"),
                   "Mien Trung" : Observable.of("Hue", "Da Nang"),
                   "Mien Nam" : Observable.of("Ho Chi Minh", "Can Tho")]
    
    let observable = Observable.of("Mien Bac", "Mien Trung", "Mien Nam")
        .concatMap { name in
            cities[name] ?? .empty()
        }
    
    observable
        .subscribe(onNext: { (value) in
            print(value)
        })
        .disposed(by: bag)
```

Trong đó

* `cities` là một Dictionary với key là String và value là 1 Observable
* Tạo ra 1 Observable với kiểu dữ liệu cho phần tử là `String`
* Dùng `concatMap` để biến đổi từ `String` thành `String`. Tuy nhiên có sự can thiệp là nối các chuỗi thuộc value của Dictionary trên lại với nhau

kết quả ra như sau

```
Ha Noi
Hai Phong
Hue
Da Nang
Ho Chi Minh
Can Tho
```

Cũng khá là đơn giản. Nói chung tụi này sẽ xoay vòng với nhau thôi. Chúng ta tiếp tục với nhóm tiếp theo nào.

### 2. **Merging**

Toán tử đầu tiên chính là `merge`. Cái tên cũng nói lên tất cả. Đặc điểm của toán tử này như sau

* `merge` sẽ tạo ra 1 Observable mới, khi một Observable có các `element` kiểu là Observable
* Observable của merge sẽ kết thúc khi tất cả đều kết thúc
* Nó không quan tâm tới thứ tự các Observable được thêm vào. Nên nếu có bất cứ phần tử nào từ các Observable đó phát đi thì cũng đều nhận được

Code ví dụ như sau

```swift
    let bag = DisposeBag()
    
    let chu = PublishSubject<String>()
    let so = PublishSubject<String>()
    
    let source = Observable.of(chu.asObserver(), so.asObserver())
    
    let observable = source.merge()
    
    observable
        .subscribe(onNext: { (value) in
            print(value)
        })
        .disposed(by: bag)
    
    chu.onNext("Một")
    so.onNext("1")
    chu.onNext("Hai")
    so.onNext("2")
    chu.onNext("Ba")
    so.onCompleted()
    so.onNext("3")
    chu.onNext("Bốn")
    chu.onCompleted()
```

Trong đó

* `chu` & `so` là 2 Subject, chịu trách nhiệm phát đi dữ liệu
* `source` được tạo ra từ 2 Observable `chu` & `so` . Nó là 1 Observable
* `observable` được tạo ra bằng toán tử `merge`
* Vẫn subscribe như bình thường
* việc phát dữ liệu được thực hiện xen kẻ

Kết quả như sau

```
Một
1
Hai
2
Ba
Bốn
```

Và tất nhiên bạn có thể hạn chế được số lượng các Observable được phép merge vào thông qua tham số `.merge(maxConcurrent:)`

### 3. **Combining elements**

#### 3.1. `combineLatest`

Toán tử này sẽ phát đi những giá trị là sự kết hợp của các cặp giá trị mới nhất của từng Observable. Để hình dung cụ thể thì ta qua từng bước ví dụ sau đây

Tạo các observable, sẽ phát dữ liệu đi. Có thể không theo lần lượt

```swift
    let chu = PublishSubject<String>()
    let so = PublishSubject<String>()
```

Sử dụng `combinedLatest` với 2 Observable trên. Sau đó tiến hành subcirbe như bình thường

```swift
    let observable = Observable.combineLatest(chu, so)
    
    observable
        .subscribe(onNext: { (value) in
            print(value)
        })
    .disposed(by: bag)
```

Giờ chúng ta phát dữ liệu đi một cách lần lượt xem thế nào

```swift
    chu.onNext("Một")
    chu.onNext("Hai")
    so.onNext("1")
    so.onNext("2")
    
    chu.onNext("Ba")
    so.onNext("3")
    chu.onNext("Bốn")
    so.onNext("4")
    so.onNext("5")
    so.onNext("6")
```

Kết quả sẽ khác dự đoán của bạn một chút

```
("Hai", "1")
("Hai", "2")
("Ba", "2")
("Ba", "3")
("Bốn", "3")
("Bốn", "4")
("Bốn", "5")
("Bốn", "6")
```

Kết quả là sự kết hợp dữ liệu của 2 dữ liệu được Observable phát đi. Bạn sẽ thấy là không có `("Một", "1")`. Vì lúc đó Observable `so` chưa phát ra gì cả. Khi `so` phát ra phần tử đầu tiên thì sẽ kết hợp với phần tử mới nhất của `chu`, đó là `Hai`.

Áp dụng tương tự cho các phần tử tiếp theo. Còn với complete thì như thế nào?

```swift
    chu.onNext("Một")
    chu.onNext("Hai")
    so.onNext("1")
    so.onNext("2")
    
    chu.onNext("Ba")
    so.onNext("3")
    chu.onCompleted()
    chu.onNext("Bốn")
    
    so.onNext("4")
    so.onNext("5")
    so.onNext("6")
    
    so.onCompleted()
```

Kết quả thực thi như sau

```
("Hai", "1")
("Hai", "2")
("Ba", "2")
("Ba", "3")
("Ba", "4")
("Ba", "5")
("Ba", "6")
```

Vẫn không ảnh hưởng gì tới sự hoạt động của toán tử này. Nó sẽ vẫn lấy dữ liệu cuối cùng trước khi phát đi `.onCompleted` để kết hợp với các phần tử khác.

#### 3.2. `combineLatest(_:_:resultSelector:)`

Kết quả thực thi ở trên nhìn khá là xấu xí. Tuy nhiên bạn có thể biến đổi nó như các toán tử `map` bằng cách sử dụng thêm tham số `resultSelector` và cung cấp 1 closure để biến đổi chúng.

Ta edit lại ví dụ trên một chút

```swift
    let observable = Observable.combineLatest(chu, so) { chu, so in
        "\(chu) : \(so)"
    }
```

Vì nếu không có tham số này thì giá trị của toán tử là 1 `Tuple` kết hợp đơn giản mà thôi. Còn lại ta sử dụng tham số phụ này thì ta có quyền biến đổi thành kiểu dữ liệu mà ta mong muốn.

Kết quả như sau

```
Hai : 1
Hai : 2
Ba : 2
Ba : 3
Ba : 4
Ba : 5
Ba : 6
```

Và đây là công thức chung có bạn nếu sau này muốn áp dụng nó. Bạn phải thêm `filter` để tăng tính đảm bảo

```swift
let observable = Observable
		.combineLatest(left, right) { ($0, $1) }
    .filter { !$0.0.isEmpty }
```

Thêm 1 ví dụ nữa để thấy sự tiện lợi của toán tử này

```swift
    let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)

    let dates = Observable.of(Date())

    let observable = Observable.combineLatest(choice, dates) { format, when -> String in
        let formatter = DateFormatter()
        formatter.dateStyle = format
        return formatter.string(from: when)
    }
    
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
```

Với 1 giá trị `Date` bạn có thể lựa chọn kiểu format dữ liệu để in ra một cách tiện lợi nhất. Chúng ta không cần gọi hàm đi gọi hàm lại hay là for các kiểu nữa. Còn kết quả như sau

```
8/21/20
August 21, 2020
```

> Toán tử này có rất nhiều tuỳ chọn cho tham số của nó. Bạn hãy khám phá thêm.

#### 3.3. `zip`

Khi bạn quan tâm tới thứ tự kết hợp theo đúng thứ tự phát đi của từng Observable. Nhưng `combinedLatest` không đáp ứng được thì `zip` sẽ thoải mãn cho bạn.

Tất cả mọi thư đều như trên, tuy nhiên chỉ khác là các cặp giá trị kết hợp sẽ theo thứ tự phát với nhau. Xem qua lại ví dụ trên thì bạn sẽ hiểu thôi.

```swift
let observable = Observable.zip(chu, so) { chu, so in
        "\(chu) : \(so)"
    }
```

Vẫn là ví dụ lúc nãy, bạn chỉ cần edit lại thành là `zip`. Và tận hưởng kết quả nào!

```
Một : 1
Hai : 2
Ba : 3
```

Như vậy, là vừa đẹp vừa đúng rồi! Dù vậy, bạn cũng nên quản lý việc `onCompleted` của từng Observable trong đó, để đảm bảo dữ liệu như bạn mong muốn.

### 4. Trigger

Nó sẽ được sử dụng, khi bạn muốn tạo ra 1điều kiện nào đó từ Observable để một Observable khác được phép hoạt động.

#### 4.1. `withLatestFrom`

Bắt đầu bằng ví dụ sau

```swift
  let button = PublishSubject<Void>()
  let textField = PublishSubject<String>()

  let observable = button.withLatestFrom(textField)
    
    _ = observable
        .subscribe(onNext: { value in
            print(value)
        })

    textField.onNext("Đa")
    textField.onNext("Đà Na")
    textField.onNext("Đà Nẵng")
    
    button.onNext(())
    button.onNext(())
```

Trong đó

* `button` là một subject. Với `Void` thì chỉ phát ra sự kiện chứ ko có giá trị nào từ `onNext`
* `textField` là một subject, phát ra các `String`
* `observable` là sự kết hợp của `button` với `textField` thông qua toán tử `withLatestFrom`
* Mỗi lần `button` phát đi tín hiệu thì kết quả sẽ nhận được là phần tử mới nhất từ `textField`

Qua ví dụ trên cũng mô tả cho bạn thấy sự hoạt động của toán tử `withLatestFrom` rồi. Kết quả thực thi code như sau

```
Đà Nẵng
Đà Nẵng
```

#### 4.2. `sample`

Chúng ta thay `withLatestFrom` bằng `sample` trong ví dụ trên

```swift
let observable = textField.sample(button)
```

Kết quả sẽ cho  ra 1  mà thôi. Với `sample` là tương tự như `withFromLatest`. Nhưng nó chỉ phát khi Observable `button` phát ra.

Chú ý:

* `withLatestFrom` thì tham số là dữ liệu của một Observable khác
* `sample` thì tham số là trigger từ một Observable khác

Chúng nó rất dễ nhầm lẫn, vì vậy bạn cần cẩn thận hơn khi sử dụng.

### 5. **Switches**

Các toán tử mới này sẽ cho phép bạn tạo ra một Observable từ nhiều Observable khác. Mà bạn có thể quyết định được việc dữ liệu từ nguồn nào mà các subscriber có thể nhận được.

#### 5.1.  `amb`

Đây là một toán tử khá là mơ hồ, cũng như cái tên của nó là `ambiguity`. Với các đặc tính sau
* Nó sẽ tạo ra một Observable để giải quyết vấn đề quyết định nhận dữ liệu từ nguồn nào
* Trong khi cả 2 nguồn đều có thể phát dữ liệu. Thì nguồn nào phát trước thì nó sẽ nhận dữ liệu từ nguồn đó.
* Nguồn phát sau sẽ bị âm thầm ngắt kết nối

Xem qua code demo cho thông não nè

```swift
let bag = DisposeBag()

let chu = PublishSubject<String>()
let so = PublishSubject<String>()

let observable = chu.amb(so)

observable
    .subscribe(onNext: { (value) in
        print(value)
    })
.disposed(by: bag)

so.onNext("1")
so.onNext("2")
so.onNext("3")

chu.onNext("Một")
chu.onNext("Hai")
chu.onNext("Ba")

so.onNext("4")
so.onNext("5")
so.onNext("6")
   
chu.onNext("Bốn")
chu.onNext("Năm")
chu.onNext("Sáu")
```

Kết quả thực thi ra như sau

```
1
2
3
4
5
6
```

Vì `so` đã phát trước, nên các dữ liệu từ `chu` sẽ không nhận được. Nếu bạn cho thêm `chu` phát `onNext` trước số thì sẽ thấy dữ liệu nhận được sẽ toàn là từ `chu`. 

#### 5.2. `switchLatest`

Toán tử này tương tự như `flatMapLatest` trong bài trước. Và để thấu hiểu nó thì mình sẽ đi qua ví dụ thường bước sau.

Đầu tiên bạn cần tạo ra các Observable

```swift
let chu = PublishSubject<String>()
let so = PublishSubject<String>()
let dau = PublishSubject<String>()

let observable = PublishSubject<Observable<String>>()
```

Ta có:
* 3 subject thay nhau phát dữ liệu
* `observable` với kiểu dữ liệu phát đi là `Obsevable<String>` , chính là kiểu của 3 subject trên

Tiến hành `subscribe` và dùng `switchLatest` như sau

```swift
observable
    .switchLatest()
    .subscribe(onNext: { (value) in
        print(value)
    }, onCompleted: {
        print("completed")
    })
.disposed(by: bag)
```

Cũng khá là quen thuộc phải không nào! Giờ sang phần phát dữ liệu đi. Bạn xem tiếp 

```swift
observable.onNext(so)

so.onNext("1")
so.onNext("2")
so.onNext("3")

observable.onNext(chu)

chu.onNext("Một")
chu.onNext("Hai")
chu.onNext("Ba")

so.onNext("4")
so.onNext("5")
so.onNext("6")

observable.onNext(dau)

dau.onNext("+")
dau.onNext("-")
   
observable.onNext(chu)
chu.onNext("Bốn")
chu.onNext("Năm")
chu.onNext("Sáu")
```

Bạn sẽ thấy việc `observable` sẽ phát đi subject nào. Thì `subscriber` trên sẽ nhận được giá trị của subject đó. Kết quả thực thi như sau

```
1
2
3
Một
Hai
Ba
+
-
Bốn
Năm
Sáu
```

Đối với phần này rất dễ bị nhầm lẫn nên bạn muốn hiểu hơn thì hãy thay phiên nhau việc phát dữ liệu.

Còn để kết thúc nó thì phải phải `.dispose` subscription. Chứ không thể tài nào kết thúc nó được, mặc dù các subject có thể `onCompleted` hết tất cả nhưng nó vẫn không kết thúc.

### 6. Combining elements within a sequence

Tiếp theo là sự kết hợp các phần tử trong cùng 1 sequence observable. Có nhiều điểm thú vụ ở đây với các toán tử này.

#### 6.1. `reduce(_:_:)`

Đây là một toán tử khá là quen thuộc. Chắc bạn cũng vài lần sử dụng nó trong các Array để tính toán liên quan tới tất cả các phần tử trong array đó. Ví dụ như cộng tất cả giá trị của một array lại với nhau

```swift
let source = Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9)

let observable = source.reduce(0, accumulator: +)

_ = observable
    .subscribe(onNext: { value in
        print(value)
    })
```

Trong đó `accumulator` là sự rút gọn toán tử `+` lại. Và `0` là giá trị ban đầu được cấp phát cho để thực hiện việc này. Hoặc bạn có thể code xịn sò hơn như sau

```swift
let observable = source.reduce(0) { $0 + $1 }
```

Hoặc code nghiêm chính lại một chút.

```swift
let observable = source.reduce(0) { summary, newValue in
  return summary + newValue
}
```

Việc tích luỹ sẽ bắt đầu bằng giá trị bạn cung cấp cho nó. Khi đó nó sẽ hiểu là `$0`. Tiếp theo khi nhận được 1 giá trị, thì giá trị đó là `$1`. Ta thực hiện biểu thức, kết quả trả về sẽ gán lại cho `$0`. Cứ như thế vòng lặp định mệnh sẽ liếp tục cho đến hết. Tức là Observable phát đi `onCompleted`.  OKAY phải không nào, EZ.

#### 6.2. `scan(_:accumulator:)`

Về cấu trúc và cách viết thì tương tự `reduce`. Có chút khác biệt ở đây là, thay vì chờ Observable kết thúc và đưa ra kết quả cuối cùng. Thì `scan` nó sẽ tính toán và phát đi kết quả khi có dữ liệu từ Observable phát đi. Không quan tâm Observable kết thúc mới thực hiện.

Chỉ cần dùng lại ví dụ trên, thay reduce bằng `scan` là bạn sẽ hiểu thôi

```swift
let source = Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9)

//let observable = source.scan(0, accumulator: +)

//let observable = source.scan(0) { $0 + $1 }

let observable = source.scan(0) { summary, newValue in
  return summary + newValue
}

_ = observable
    .subscribe(onNext: { value in
        print(value)
    })
```

Kết quả thực thi như sau
```
1
3
6
10
15
21
28
36
45
```
Về bản chất thì không khác nhau mấy khi so với `reduce`.

---

Mình xin kết thúc bài dài này tại đây. Hẹn gặp lại bạn ở bài tiếp theo. Cảm ơn vì đã đọc!
