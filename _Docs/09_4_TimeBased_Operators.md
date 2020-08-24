# 09.4 Time-Based Operators

Dân gian hay nói câu

> Thời gian là vàng.

Vâng, nó đúng với lập trình, nhất là lập trình Reactive nói chung và RxSwift nói riêng. Về mặc này, RxSwift được lên ý tưởng từ việc xử lý luồng dữ liệu bất đồng bộ theo thời gian. Đây chính là ẩn số cuối cùng trong thế giời Reactive Programming.

Để có thể nắm bắt được cơ bản thì RxSwift cũng như các thư viện khác sẽ hỗ trợ bạn rất nhiều bằng các toán tử mà nó cung cấp cho bạn để xử lý dữ liệu theo 2 phần quan trọng là:

* Luồng
* Thời gian

Để chuẩn bị cho bài này, thì bạn hãy tạo tiếp 1 Playground trong project thần thánh kia. Và để hiểu được thì bạn phải thêm cách để `print` cho đẹp theo từng luồng/thread trong các đoạn code ví dụ. Hoặc bạn có thể custom thêm 1 project để hinh hoạ các `event` của các Observable được xử lý theo `time-life`. Điều này thì nghe có vẻ chua lắm. Nên thôi cứ `console` thần thánh mà sài vậy.

Và nếu mọi thứ đã okay rồi thì 

> Hãy bắt đầu thôi!

### 1. Buffering operators

Nhóm toán tử này dựa trên việc xử lý bộ đêm. Cho bạn có nhiều quyền hơn với việc phát lại các phần tử cho các subscriber. Hay kiểm soát thời điểm phát cho phù hợp với yêu cầu dự án.

#### 1.1. Basic with Timer

Để hiểu rõ thì chúng ta sẽ đi qua ví dụ một cách `step by step`. Hãy mở file playground lên và tiến thành định nghĩa vài biến cơ bản trước nào.

```swift
let elementsPerSecond = 1
let maxElements = 5
let replayedElements = 1
let replayDelay: TimeInterval = 3
```

Đâu tiên thì bạn sẽ tử với việc tạo ra 1 Observable có thể `emit` các phần tử theo thời gian. Khá là cơ bản, tuy nhiên cũng hơi hack não bạn đó. Bạn xem đoạn code sau:

```swift
    let observable = Observable<Int>.create { observer -> Disposable in
        
        var value = 1
        
        let source = DispatchSource.makeTimerSource(queue: .main)
        source.setEventHandler {
            if value <= maxElements { observer.onNext(value)
            value += 1 }
        }

        source.schedule(deadline: .now(), repeating: 1.0 / Double(elementsPerSecond), leeway: .nanoseconds(0))
        source.resume()
        
        return Disposables.create {
            source.suspend()
        }
    }
```

Trong đó:

* `Observable<Int>.create` thì khá là quen thuộc rồi. Trong closure đó thì chúng ta sẽ xử lý login trong này. Nhớ phải return về 1 `Disposables` nha
* Sử dụng `DispatchSource.makeTimerSource` để tạo ra 1 timer trên `main queue`
* Cung cấp 1 closure cho `source` để xử lý sự kiện sau mỗi vòng lặp tời gian
* `source.schedule` lên kế hoạch phát dữ liệu theo các tham số trên
* `source.resume()` để kích hoạt
* Về mặt `Disposables.create` thì chúng ta handle luôn luôn việc dừng `souce` tại đây. Đây cũng chính là thắc mắc lâu nay với hàm create để làm gì.

Xong rồi thì tới tiết mục `subcribe`. Vì playground không phải là môi trường app. Nó không có UI, nên main thread sẽ không mặc định chạy. Muốn mọi việc hoạt động thì bạn phải `subcribe` ở Main Thread. Các phần sau sẽ áp dụng tương tự cách này.

Còn giờ xem code subcribe thôi

```swift
    DispatchQueue.main.async {
        observable
            .subscribe(onNext: { value in
                print("🔵 : ", value)
            }, onCompleted: {
                print("🔵 Completed")
            }, onDisposed: {
                print("🔵 Disposed")
            })
            .disposed(by: bag)

    }
```

Vẫn là như trước, không có gì thay đổi. Tuy nhiên, nếu bạn thực thi code, sẽ thấy việc print sẽ lần lượt xuất hiện. 

#### 1.2. Replaying past elements

Tất nhiên là chúng ta sẽ không code như cách cơ bản trên. Vì nó tốn thời gian và tiềm tàn nhiều rủi ro không biết được. Vì vậy, chúng ta sẽ bắt đầu lại. Phần này là 2 toán tử

* `replay(_:)`
* `replayAll()`

Ta dùng 1 function để show thời gian trong mỗi lần `print` cho nó dễ thấy. Tuỳ ý bạn viết nha, không bắt buộc theo mình. Tham khảo đoạn code sau.

```swift
public func printValue(_ string: String) {
    let d = Date()
    let df = DateFormatter()
    df.dateFormat = "ss.SSSS"
    
    print("\(string) --- at \(df.string(from: d))")
}
```

Với `replay(_:)` thì ta cần cung cấp số lượng phần tử `buffer` mà nó có thể replay lại cho bạn. Các phần tử được lưu lại là các phần tử mới nhất mà Observable kia phát ra. Ta hãy tạo 1 Observable replay như sau, từ `observable` ở trên.

```swift
let replaySource = observable.replay(1)
```

Tiếp theo, bạn cần subcribe để xem `replaySource` đó phát ra gì.

```swift
    DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
        replaySource
            .subscribe(onNext: { value in
                printValue("🔵 : \(value)")
            }, onCompleted: {
                print("🔵 Completed")
            }, onDisposed: {
                print("🔵 Disposed")
            })
            .disposed(by: bag)
    }
```

Chúng ta sẽ bắt đầu `subscribe` với `replaySource` sau `3 giây`. Để đảm bảo là observable kia đã phát đi vài phần tử rồi. Tới đây, nếu bạn thử thực thi đoạn code này thì sẽ không có gì xảy ra.

> Vì chúng thuộc `ConnectableObservable` . Nên muốn thực thi thì bạn phải kết nối nó với Observable gốc. Toán tử đó là `.connect()`.

Viết thêm 1 dòng code nữa để kết nối, bạn đặt sau đoạn Dispatch trên.

```swift
replaySource.connect()
```

Kết quả thực thi cả 2 đoạn code như sau:

* `đỏ` là cho Observable gốc
* `xanh` là cho Replay Observable

```
🔴 : 1 --- at 23.2900
🔴 : 2 --- at 24.2880
🔴 : 3 --- at 25.2880
🔵 : 3 --- at 26.2670
🔵 : 4 --- at 26.2680
🔴 : 4 --- at 26.2880
🔵 : 5 --- at 27.2680
🔴 : 5 --- at 27.2870
```

Bạn sẽ thấy phần tử xanh đầu tiên phát ra là số `3` và lúc đó thì `4` cũng được Observable gốc phát ra, nên Replay sẽ phát luôn. Các phần tử `1` & `2` không có vì bộ đệm chỉ có 1 phần tử mà thôi.

Tiếp theo, ban dùng toán tử `replayAll()` thay cho toán tử trên

```swift
let replaySource = observable.replayAll()
```

Thực thi code thì sẽ thấy kết quả rất vi diệu

```
🔴 : 1 --- at 09.8820
🔴 : 2 --- at 10.8780
🔴 : 3 --- at 11.8780
🔵 : 1 --- at 12.8590
🔵 : 2 --- at 12.8600
🔵 : 3 --- at 12.8600
🔵 : 4 --- at 12.8610
🔴 : 4 --- at 12.8780
🔵 : 5 --- at 13.8590
🔴 : 5 --- at 13.8790
```

#### 1.3. Controlled buffering

Tiếp theo, là kiểm soát bộ đệm. Chúng ta sẽ dùng toán tử sau:

```swift
buffer(timeSpan:count:scheduler:)
```

Nhìn qua thì bạn thấy có nhiều tham số cho bạn lựa chọn, hứa hẹn một toán tử phức tạp thêm nữa rồi. Để bắt đầu chúng ta cũng thông qua các ví dụ `step by step` cho đơn giản. 

Đầu tiên thì định nghĩa vài biến cần dùng

```swift
let bufferTimeSpan = RxTimeInterval.milliseconds(4000)
let bufferMaxCount = 2

let source = PublishSubject<String>()
```

Các biến này thì không có gì cần giải thích. Chủ yếu đi vào đoạn sau, đoạn bí thuật nằm ở đây.

```swift
source
    .buffer(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
    .map { $0.count }
    .subscribe(onNext: { (value) in
        printValue("🔵 \(value)")
    })
    .disposed(by: bag)
```

Phân tích nó chút nha

* `source` là nguồn phát
* `buffer` là toán tử tạo và quản lý bộ đệm
* `timeSpan` là thời gian hết hạn của bộ đệm
* `count` là số lượng phần tử tối đa mà bộ đệm của thể lưu trữ được
* `scheduler` hiểu đơn giản là luồng nào chọn để thực thi (tìm hiểu kĩ sau nha)
* `map` vì sau khi hết timeSpan thì sẽ phát đi 1 `event` (nó độc lập với source). Nên biến đổi nó chút để đọc số phần tử hiện tại ở trong bộ đệm

> Kiểu dữ liệu  trong bộ đệm mà ta `subscribe` là một `Array` các element được lưu lại.

Để tiến hành kiểm tra thì bạn cho `source` phát ra giá trị.

```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
    source.onNext("A")
    source.onNext("B")
    source.onNext("C")
    source.onNext("D")
}
```

Sau 4 giây khi mọi thứ đã setup xong thì chúng ta phát ra đồng thời 4 giá trị. Khi này bộ đệm sẽ đọc được

```
🔵 0 --- at 44.1800
🔵 2 --- at 44.1860
🔵 2 --- at 44.1890
🔵 0 --- at 48.1900
🔵 0 --- at 52.1920
```

Thật ra là nó sẽ chạy miết và không kết thúc, mình copy ra cho bạn thấy như vậy. Bạn sẽ thấy giây 44, chưa có gì. Sau đó có 2 vì maxCount bộ đệm là 2. Sau đó 2 tiếp, do chúng ta phát liên tiếp là 4. Sau đó 4 giây (thời gian span của bộ đệm) thì không có gì, và sau đó nữa là 0 có gì.

Cho phần thêm thú vị thì bạn có thể áp dụng việc phát từng phần tử lần lượt để nhìn thấy chúng theo giời gian

```swift
let dispatchSource = DispatchSource.makeTimerSource(queue: .main)
dispatchSource.setEventHandler {
    source.onNext("X")
}

dispatchSource.schedule(deadline: .now(), repeating: 1.0, leeway: .nanoseconds(0))
dispatchSource.resume()
```

Hãy thực thi nó và cảm nhận kết quả!

#### 1.4. window

Toán tử `window` thì tương tự như toán tử `buffer`. Tuy nhiên điểm khác biệt duy nhất là 

> Kiểu dữ liệu trong bộ đệm là 1 `Observable` chứ không còn là Array như của `buffer`.

Nên công việc của chúng ta nó sẽ vất vả hơn nhiều với việc biên đổi. Còn nếu như bạn thích dùng luôn Observable đó thì ko sao.

Về code demo, bạn thay đổi từ khoá `buffer` thành `window` và sửa lại một chút chỗ này.

```swift
source
    .window(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
    .flatMap({ obs -> Observable<[String]> in
        obs.scan(into: []) { $0.append($1) }
    })
    .subscribe(onNext: { (value) in
        printValue("🔵 \(value)")
    })
    .disposed(by: bag)

```

Trong đó:

* Kiểu của element `source.window` là một `Observable<String>`
* Ta biến đổi về thành `Array String` cho giống với `buffer` bằng toán tử `flatmap`
* Vì nó là 1 observable nên `scan` tất cả các giá trị của nó phát ra thành 1 giá trị duy nhất

Kết quả chạy ra như sau, bạn tuỳ chỉnh 1 chút cho `source` phát ra các số tăng dần.

```
🔴 : 1 --- at 24.4560
🔵 ["1"] --- at 24.4590
🔴 : 2 --- at 25.3930
🔵 ["1", "2"] --- at 25.3940
🔴 : 3 --- at 26.3940
🔵 ["3"] --- at 26.3940
🔴 : 4 --- at 27.3940
🔵 ["3", "4"] --- at 27.3950
🔴 : 5 --- at 28.3940
🔵 ["5"] --- at 28.3950
```

Giờ nhìn bộ đệm nó đẹp hơn rồi.

### 2. Time-shifting operators

Giờ chúng ta sẽ chơi đùa với thời gian. À, bạn không thể thay đổi các sự kiện đã xãy ra ở quá khứ nha. Nên cũng đừng làm khó nhau quá.

Tiết kiệm thời gian để tạo `DispatchSource` thì ta viết luôn 1 function cho nó. Nó cũng tương tự như là `Timer` vì vậy ta đặt tên cho nó làm `timer`

> Để lúc nào rãnh rỗi thì mình sẽ viết 1 bài về DispatchSource, xem nó là gì.

```swift
public extension DispatchSource {
  public class func timer(interval: Double, queue: DispatchQueue, handler: @escaping () -> Void) -> DispatchSourceTimer {
    let source = DispatchSource.makeTimerSource(queue: queue)
    source.setEventHandler(handler: handler)
    source.schedule(deadline: .now(), repeating: interval, leeway: .nanoseconds(0))
    source.resume()
    return source
  }
}
```

Bạn sẽ gọi nó lại nhiều lần nha. Giờ vào phần chính nha.

#### 2.1. **Delayed subscriptions**

Toán tử `delaySubscription` giúp bạn trì hoãn việc đăng ký `subscription` lại trong một khoảng thời gian. Tất nhiên, các giá trị được phát ra trước đó thì bạn sẽ không nhận được. 

> Đúng là toán tử không có ích mấy.

Code ví dụ như sau

```swift
let source = PublishSubject<String>()

source
    .delaySubscription(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
    .subscribe(onNext: { value in
        printValue("🔴 : \(value)")
    })
    .disposed(by: bag)

var count = 1
var timer = DispatchSource.timer(interval: 1.0, queue: .main) {
    source.onNext("\(count)")
    count += 1
}
```

Trong đó

* `source` là nguồn phát dữ liệu đi
* `delaySubscription` trì hoãn việc subscription lại trong 2 giây đầu
* Phần `timer` ở dưới thì cứ mỗi giây là `emit` 1 lần

Kết quả thực thi như sau

```
🔴 : 3 --- at 58.7960
🔴 : 4 --- at 59.7960
🔴 : 5 --- at 00.7960
🔴 : 6 --- at 01.7960
🔴 : 7 --- at 02.7960
🔴 : 8 --- at 03.7960
```

Bạn chú ý thì sẽ thấy giá trị nhận được đầu tiên là `3`. Nếu bạn không `timer.suspend()` thì nó sẽ không bao giờ kết thúc.

#### 2.2. **Delayed elements**

Giờ tới việc delay chính là delay `element`. Cũng tương tự như trên thôi. Nhưng việc subscription vẫn bình thường. Mỗi việc các phần tới được phát đi lại nhận được chậm hơn thôi.

Đổi toán tử `delaySubscription` thành `delay` ở đoạn code trên và quan sát.

```swift
let source = PublishSubject<String>()

source
    .delay(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
    .subscribe(onNext: { value in
        printValue("🔴 : \(value)")
    })
    .disposed(by: bag)

var count = 1
var timer = DispatchSource.timer(interval: 1.0, queue: .main) {
    printValue("emit: \(count)")
    source.onNext("\(count)")
    count += 1
}
```

Kết quả thực thi như sau

```
emit: 1 --- at 20.4460
emit: 2 --- at 21.4140
emit: 3 --- at 22.4140
🔴 : 1 --- at 22.4490
emit: 4 --- at 23.4130
🔴 : 2 --- at 23.4520
emit: 5 --- at 24.4140
🔴 : 3 --- at 24.4540
emit: 6 --- at 25.4130
🔴 : 4 --- at 25.4560
emit: 7 --- at 26.4140
🔴 : 5 --- at 26.4570
emit: 8 --- at 27.4130
🔴 : 6 --- at 27.4590
emit: 9 --- at 28.4130
🔴 : 7 --- at 28.4600
```

Dễ hiểu phải không nào, đã phát được 3 giá trị rồi nhưng mới nhận được cái đầu tiên. EZ

### 3. **Timer operators**

Việc liên quan tới `timer` mà bạn hay dùng chính là `lặp` để thực hiện một công việc gì đó. Hầu như các dev mới đều thích cái này. Giờ RxSwift chúng ta xem nó làm được gì để thoải mãn các dev mới không.

#### 3.1. `interval(_:scheduler:)`

Ở các ví dụ trên, bạn thấy mệt mỏi vì sử dụng `DispatchSource`. Trong khi bạn có một cái xịn sò hơn rất nhiều. Giờ xem code ví dụ sau để giải thích nào.

```swift
let source = Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
let replay = source.replay(2)


DispatchQueue.main.asyncAfter(deadline: .now()) {
    
    source
    .subscribe(onNext: { value in
        printValue("🔴 : \(value)")
    }, onCompleted: {
        print("🔴 Completed")
    }, onDisposed: {
        print("🔴 Disposed")
    })
    .disposed(by: bag)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    replay
        .subscribe(onNext: { value in
            printValue("🔵 : \(value)")
        }, onCompleted: {
            print("🔵 Completed")
        }, onDisposed: {
            print("🔵 Disposed")
        })
        .disposed(by: bag)
}

replay.connect()
```

Trong đó:

* `source`  là một Observable với kiểu dữ liệu là Int. Nó được tạo ra bằng toán tử `interval`
* cú 1 giây (theo cài đặt) thì `source` sẽ phát ra 1 giá trị. Và nó cứ tăng dần
* `replay` thì như ở ví dụ đầu tiên, phát lại bộ đệm

Kết quả ra như sau

```
🔴 : 0 --- at 11.4230
🔵 : 0 --- at 12.3700
🔵 : 1 --- at 12.3700
🔴 : 1 --- at 12.4230
🔵 : 2 --- at 13.3700
🔴 : 2 --- at 13.4230
🔵 : 3 --- at 14.3710
🔴 : 3 --- at 14.4230
🔵 : 4 --- at 15.3700
🔴 : 4 --- at 15.4230
🔵 : 5 --- at 16.3710
🔴 : 5 --- at 16.4230
🔵 : 6 --- at 17.3700
🔴 : 6 --- at 17.4230
```

Ví dụ trên cũng là viết lại ví dụ với `replay` mà không dùng tới DispatchSource. EZ!

#### 3.2. `timer`

Cũng giống như `interval` nhưng `timer` đơn giản hơn nhiều. Nó sẽ hẹn giờ và sẽ phát đi 1 tín hiệu. Vậy là xong. 

Code ví dụ như sau

```swift
let source = Observable<Int>.timer(RxTimeInterval.seconds(3), scheduler: MainScheduler.instance)

DispatchQueue.main.asyncAfter(deadline: .now()) {
    
    source
    .subscribe(onNext: { value in
        printValue("🔴 : \(value)")
    }, onCompleted: {
        print("🔴 Completed")
    }, onDisposed: {
        print("🔴 Disposed")
    })
    .disposed(by: bag)
}
```

Chạy thử đoạn code trên bạn sẽ thấy kết qua rất gọn

```
🔴 : 0 --- at 42.5470
🔴 Completed
🔴 Disposed
```

Phát ra 1 sự kiện và kết thúc cuộc đời.

À, nếu bạn muốn nó nó phát thêm phát nữa, thì có thể cheat như sau

```swift
source
.flatMap { _ in
    source.delay(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
}
.subscribe(onNext: { value in
    printValue("🔴 : \(value)")
}, onCompleted: {
    print("🔴 Completed")
}, onDisposed: {
    print("🔴 Disposed")
})
.disposed(by: bag)
```

Có vẻ mọi thứ được giải quyết với `flatMap`.  Với đoạn code trên, tại flatMap đó bạn lại delay tiếp thêm 2 giây nữa. Rồi subscriber mới nhận được dữ liệu.

#### 3.3. `timeout`

Toán tử này cũng thú vụ không kém. Giống như việc request API vậy. Trong 1 khoản thời gian cài đặt, nếu ko có bất kì phản hồi nào thì sẽ auto kết thúc. Còn với RxSwift thì nếu trong khoản thời gian đó, kể từ thời điểm nhận giá trị mới nhất. Mà không nhận thêm được bất cứ giá trị gì thì sẽ kết thúc.

Xem code ví dụ sau

```swift
let source = PublishSubject<Int>()
    
source
    .timeout(RxTimeInterval.seconds(5), scheduler: MainScheduler.instance)
    .subscribe(onNext: { value in
        printValue("🔴 : \(value)")
    }, onCompleted: {
        print("🔴 Completed")
    }, onDisposed: {
        print("🔴 Disposed")
    })
    .disposed(by: bag)


DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    source.onNext(1)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    source.onNext(2)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
    source.onNext(3)
}
```

Trong đó:
* `source` đơn giản là subject dùng để phát dữ liệu
* `timeout` với thời gian cài đặt là 5 giây
* `subscribe` full các sự kiện, để biết chúng có kết thúc hay không
* Theo các thời điểm định sẵn thì sẽ phát ra giá trị.

Bạn xem kết quả chạy như sau

```
🔴 : 1 --- at 03.7530
🔴 : 2 --- at 04.9490
🔴 : 3 --- at 08.7530
Unhandled error happened: Sequence timeout.
🔴 Disposed
```

Sau khi phát `3` đi, thì không phát gì nữa. Vì vậy, nó sẽ auto `dispose` và kết liễu bản thân. 

> Rất là tiện lợi khi bạn sử dụng nó vào trong project cho các tác vụ không nắm đc thời gian kết thúc hoặc không kết thúc đc thì hãy hẹn giờ cho nó kết thúc.

---

Mình xin hết thúc bài viết này tại đây. Hẹn gặp lại bạn ở phần tiếp theo. Cảm ơn bạn đã đọc bài viết này!

