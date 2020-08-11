# 03 Observables (nguồn phát)

Khi bạn đã cài đặt và cũng thực hiện build thành công `Hello RxSwift` rồi, thì chúng ta bắt vào bước vào thế giới của `RxSwift`. Và **Observable** là thành phần quan trọng đầu tiên cần phải được khai phá.

## Trái tim của RxSwift

Đây là phần trung tâm của RxSwift. Observable chính là trái tim của cả hệ thống. Nó là nơi mà các thành phần khác có thể quan sát được. Nó tác động trực tiếp tới giao diện của bạn, dựa vào những gì mà nó phát ra cho bạn.

![image_003](../_images/rx_003.png)

> Everything is a sequence.

Đây chính là một câu nỗi tiếng mà bất cứ đồng chí nào lao đầu vào đó thì đều cũng bắt gặp ngay. Nhưng đó cũng chính là nơi hầu hết mọi người đều gục ngã. Tại sao như vậy?

Khi tìm hiểu về RxSwift hay Rx nói chung thì bạn sẽ nghe tới các khái niệm `observable`, `observable sequence` hay đơn giản là `sequence`. Khá là mơ hồ nhưng tất cả chúng đều làm 1 và ám chỉ tới nguồn phát. Khác như ở góc độ họ muốn mình hiểu.

* **Observable** : là nguồn phát ra dữ liệu mà các đối tượng khác có thể quan sát được và đăng ký tới được.
* **Sequence** : là luồng dữ liệu được nguồn phát phát đi. Vấn đề quan trọng bạn cần hiểu nó như 1 Array, nhưng chúng ta ko thể lấy hết 1 lúc tất cả các giá trị của nó. Và chúng ta ko biết nó lúc nào kết thúc hay lúc nào lỗi ...

Để tăng thêm độ hack não thì một số cha dev còn sinh thêm từ khoá `Stream`. Trong trường hợp này thì bạn hãy hết sức bình tĩnh. Vì Stream cũng được xem là một Sequence mà thôi, quá ez! Và tất nhiên nó phải luồng hay thread nha. Bạn xem chúng như là một dòng chảy dữ liệu mà ta quan sát được từ nguồn phát.

Và ngta tránh việc nhầm lẫn khó hiểu thì sử dụng `marble diagrams` để mô tả sự hoạt động của nguồn phát. Bạn vào trang này để xem https://rxmarbles.com/. Với 1 biểu đồ thì bao gồm như sau:

* Bắt đầu từ trái sang phải
* Các giá trị phát ra là các số được vòng tròn tô màu lại
* dấu `|` biểu tượng cho kết thúc (completed) 
* dấu `X` biểu tượng cho lỗi (error) 

## Vòng đời Observable

Cuộc đời của Observable rất chi là đơn giản. Nó chỉ có một nhiệm vụ là `bắn` những gì mà nó có đi thôi. Nên cuộc đời nó sẽ xoay quanh giá trị và nó bắn đi. Với 3 kiểu giá trị mà 1 Observable đc phép bắn đi như sau:

* Value : chính là giá trị dữ liệu nguồn phát phát đi trong `Output`
* Error: là lỗi khi có gì đó sai sai trong quá trình hoạt động
* Completed: kết thúc cuộc đời

Thông qua 3 giá trị đó thì mô tả cuộc đời Observable như sau:

* Khởi tạo Observable
* cứ `onNext` là sẽ phát giá trị đi
* quá trình này cứ lặp đi lặp lại cho tới khi
  * Hết thì sẽ là `completed`
  * Lỗi thì sẽ là `error`
* Khi khi đã `completed` hoặc `error` thì Observable không thể phát ra được gì nữa --> kết thúc

## Cách tạo Observables

Đây chỉ là những cách đơn giản mà thôi, phần khó nâng cao sẽ ở sau. Nhưng bạn cũng cần phải nắm được kiến thức cơ bản này.

Tạo các Observables thông qua việc thực thi các toán tử sau `just`, `of` và `from`. Kiểu dữ liệu của Observable là `Observable`. Để dể hiểu hơn bạn hãy tạo 1 Playground từ project của bài 2 và thêm đoạn code setup sau.

```swift
let iOS = 1
let android = 2
let flutter = 3
```

3 biến đơn giản với kiểu dữ liệu là `Int`. Tiếp theo bạn khai báo một Observable nào

```swift
let observable1 = Observable<Int>.just(iOS)
```

Trong đó:

* `observable1` là biến kiểu Observable
* `<Int>` chính là kiểu dữ liệu cho `Output` của Observable
* `just` là toán tử để tạo ra 1 observable sequence với 1 phần tử duy nhất

Tại sao là `just`? Thì cái tên này cũng nói lên tất cả rồi. Nó sẽ tạo ra 1 observable và phát đi 1 giá trị duy nhất. Sau đó sẽ kết thúc.

Tiếp tục với công việc vui vẻ tạo thêm các Observables nào. Bạn thêm dòng code này vào.

```swift
let observable2 = Observable.of(iOS, android, flutter)
```

Trong đó:

* Ta thấy đối tượng Observable lần này sử dụng toán tử `of` 
* Không cần khai báo kiểu dữ liệu cho Output
* Thư viện tự động nội suy ra kiểu dữ liệu từ các dữ liệu cung cấp trong `of(.....)`

Theo ví dụ trên thì kiểu dữ liệu của `observable2` là `Observable<Int>`. Để hiểu kĩ hơn thì ta biến tấu nó thêm một chút nữa. Bạn xem đoạn code sau:

```swift
let observable3 = Observable.of([iOS, android, flutter])
```

Cũng vẫn là `of` , nhưng kiểu dữ liệu cho `observable3` lúc này là `Observable<[Int]>`. Nó khác cái trên ở chỗ kiểu cho mỗi giá trị phát ra là 1 Array Int, chứ không phải Int riêng lẻ. Nó cũng khá nhập nhèn dữ liệu ở đây. 

Chúng ta tiếp tục thêm dòng code sau playground của bạn

```swift
let observable4 = Observable.from([iOS, android, flutter])
```

Lần này, sử dụng toán tử `from`, tham số cần truyền vào là 1 array. Và kiểu dữ liệu cho biến `observalbe4` là `Observable<Int>`. Cách này giúp bạn đỡ phải `of` nhiều phần tử :-)

Vâng, bạn đã có trong tay 3 vũ khí đầu tiên để tạo ra một `Observable` rồi. Giờ sang phần tiếp theo nào ...

## Subscribing to observables

Có được nguồn phát rồi, công việc hiện tại là lắng nghe nó thôi. Mình chắc là bạn cũng đã ít nhiều lần code với KVO trong iOS rồi. Đó là hình thức sơ khai của mô hình này. Đây là lăng nghe tứ sự kiện của bàn phím.

```swift
let observer = NotificationCenter.default.addObserver( forName: UIResponder.keyboardDidChangeFrameNotification, object: nil,
queue: nil) { notification in
  // Handle receiving notification
}
```

Thì RxSwift cũng tương tự vậy thôi. Trong UIKit hay các thư viện được build sẵn trong OS của Apple thì các singleton cũng có khả năng phát đi được dữ liệu. Đó chính là thuyết âm mưu mà Apple đã dày công gài sẵn.

Với RxSwift thì bạn có thể xem các dữ liệu mà Observable phát ra thì cũng là 1 sequence trình tự lần lượt phát đi các phần tử của mình. Nó tương đương với hàm `onNext` của Observable. Đoạn code sau mô tả cho việc phát đi lần lượt các giá trị. 

```swift
let sequence = 0..<3
var iterator = sequence.makeIterator()
while let n = iterator.next() {
	print(n) 
}
```

Hiển nhiên, RxSwift không chỉ có vậy. Chúng ta có thể lắng nghe nhiều hơn 1 cái `onNext` kia. Nó tương ứng với từng kiểu giá trị nhận được (3 kiểu mà Observable có thể phát ra). Công việc này được gọi là `.subscribe`. 

Ta sẽ tiếp tục với các `observable` được tạo trên kia. Bắt đầu với việc lắng nghe đơn giản nhất.

```swift
observable1.subscribe { event in
        print(event)
}
```

Dùng biến `observable` và gọi toán tử `.subscribe` . Để handle dữ liệu nhận được thì chúng ta cung cấp cho nó 1 `closure`. Trong closure thì chỉ có in giá trị ra thôi. Kết quả như sau:

```
next(1)
completed
```

Tuy nhiên, có cái chữ `next` cũng khó chịu. Muốn lấy được giá trị trong chữ đó thì phải biến tấu thêm 1 xí nữa.

```swift
	observable2.subscribe { event in
    if let element = event.element {
        print(element)
      }
    }
```

Kết quả cho việc lăng nghe tới `observable2` mượt hơn rồi.

```
1
2
3
```

Tiếp theo, nếu bạn cần lấy thêm các sự kiện `error` hay `completed` thì lại biến tấu tiếp.

* Dành cho `onNext`

```swift
observable3.subscribe(onNext: { element in
      print(element)
    })
```

* Full options

```swift
observable4.subscribe(onNext: { (value) in
        print(value)
    }, onError: { (error) in
        print(error.localizedDescription)
    }, onCompleted: {
        print("Completed")
    }) {
        print("Disposed")
    }
```

## Các dạng đặc biệt của Observable

### Empty

```swift
let observable = Observable<Void>.empty()
    
    observable.subscribe(
      onNext: { element in
        print(element)
    },
      onCompleted: {
        print("Completed")
      }
    )
```

Với toán tử `.empty` này thì sẽ tạo ra 1 Observable và không phát ra phần tử nào hết. Sau đó sẽ kết thúc.

### Never

```swift
let observable = Observable<Any>.never()
    
    observable.subscribe(
        onNext: { element in
            print(element)
        },
        onCompleted: {
            print("Completed")
        }
    )
```

Không có gì phát ra ở đây với việc tạo 1 observable bằng toán tử `.never`.

### Range

````swift
let observable = Observable<Int>.range(start: 1, count: 10)
    var sum = 0
    observable
        .subscribe(
            onNext: { i in
                sum += i
        } , onCompleted: {
            print("Sum = \(sum)")
        }
    )
````

Cách mà bạn có 1 vòng for đơn giản. Observable này lần lượt phát ra các giá trị trong phạm vi nó tạo ra. Và nó chỉ dùng có `Observable<Int>` thôi nha.

---

## Tóm tắt

* Observable là nguồn phát dữ liệu
* Sequence, Observable Sequence hay Stream đều mang ý nghĩa giống nhau
* Có 3 cách tạo 1 Observable đơn gian
  * `just` phát ra phần tử duy nhất và kết thúc
  * `of` phát ra lần lượt các phần tử cung cấp và kết thúc
  * `from` tương tự như `of` mà tham số truyền vào là 1 array, tiết kiệm thời gian ngồi gõ code
* Các observable đặc biết xí
  * `empty` không có gì hết và kết thúc
  * `never` không có gì luôn và ko kết thúc luôn
  * `range` tạo ra 1 vòng for nhỏ nhỏ, dùng cho `Int` và mỗi lần như vậy thì sẽ tăng giá trị lên

> Quan trọng nhất là bạn thắc mắc, tại sao tụi Observable trên cứ in ra 1 lèo hết tất cả như vậy? 
>
> Thì hiện tại chúng ta vẫn tương tác trên code đồng bộ và luồng dữ liệu đồng bộ. Nên chúng nó cứ chạy 1 lèo như rứa. Tới phần UIKit thì mọi thứ sẽ khác bọt đi nhiều.