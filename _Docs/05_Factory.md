# 05 observable factories

Phần này sẽ không quá nặng về lượng kiến thức truyền tải. Chỉ là giải quyết cho một vấn đề nhỏ nhỏ mà thôi. Các Observable trước đây bạn tạo ra ở các phần trên thì luôn trong trạng thái chờ các `subscriber` đăng ký tới.

> Tạo sao bạn không chủ động cung cấp 1 hoặc nhiều Observable `mới` cho mỗi subscriber. Thay vì phải chờ đợi.

Ta bắt đầu xem qua ví dụ sau:

```swift
    let bag = DisposeBag()
    
    var flip = true
    
    let factory = Observable<Int>.deferred {
        flip.toggle()
        
        if flip {
            return Observable.of(1)
        } else {
            return Observable.of(0)
        }
    }
```

Trong đó:

* `bag` là túi rác quốc dân
* `flip` là cờ lật qua lật lại
* Nếu `flig == true` thì trả về 1 Observable với giá trị phát đi là `1`
* Ngược lại là `0`

Ở đây, mỗi lần return là 1 Observable mới. Tất nhiên, để làm được việc này thì ta sử dụng toán tử `.deferred` để tạo ra 1 Observable, mà người ta gọi là `Observable factories`.

> `.deferred` tạo ra 1 Observable nhưng sẽ trì hoãn nó lại. Và nó sẽ được `return` trong closure xử lí được gán kèm theo.

Nhìn qua thì Observable factories cũng giống như các Observable bình thường khác. Bên ngoài, bạn sẽ không phân biệt được nó có gì khác lạ. Xem tiếp cách sử dụng của nó

```swift
	for _ in 0...10 {
        factory.subscribe(
            onNext: { print($0, terminator: "") })
            .disposed(by: bag)
    
        print()
    }
```

Lặp từ 0 đến 10, cứ mỗi bước in ra giá trị nhận được. Đây là cách đếm chẵn lẻ cao cấp bằng RxSwift

```
0
1
0
1
0
1
0
1
0
1
0
```

---

> *Chúc bạn vui vẻ!*

