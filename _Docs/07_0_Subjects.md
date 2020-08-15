# 07 Subjects

Đi tới được đây thì bạn cũng khá là kiên trì với mớ kiến thức khó nhồi nhét này. Bạn đã biết được cách tạo ra các Observables, handle các giá trị nhận được và quản lý tốt các đối tượng & đăng ký. Đó cũng là những phần cơ bản nhất của RxSwift. Nhưng bạn cũng nhận ra một điều:

* Chúng ta không thể thích phát dữ liệu đi lúc nào mà chúng ta muốn. tất cả đều phải được nạp vào.
* Phải cài đặt các phương thức hoạt động (observer) để điều kiển việc phát dữ liệu đi hay kết thúc nó

Cái mà kết hợp được cả 2 observable & observer là `Subjects`. Đây chính là phần cứu cánh cho chúng ta để giải quyết được nhiều bài toán hơn nữa.

### Demo Code

Bạn hãy tạo 1 playgound trong project mà chúng ta đã cài đặt từ bài đầu tiên. Bắt đầu với việc khai báo 1 Subject.

```swift
let subject = PublishSubject<String>()
```

Khá là đơn giản phải không nào!

* `PublishSubject` là 1 trong họ hàng nhà Subject
* `String` là kiểu dữ liệu cho Output

Và không cần truyền thêm bất cứ giá trị nào hết. Và theo lời giới thiệu ở trên thì Subject là sự kết hợp hoàn hảo, nên chúng ta thử phát đi 1 dữ liệu xem sao.

```swift
subject.onNext("Chào bạn")
```

Để xem dữ liệu có nhận được không thì bạn cần phải tạo ra một `subscription` . Thêm đoạn code sau vào

```swift
   let subject = PublishSubject<String>()
    
    subject.onNext("Chào bạn")
    
    let subscription1 = subject
        .subscribe(onNext: { value in
            print(value)
        })
```

Hãy thử chạy đoạn code bạn sẽ không thấy gì xuất hiện hết. Vì chúng ta đăng ký tới `subject` sau khi nó phát ra dữ liệu đầu tiên. Thử thêm 1 phần phát nữa, lần này bạn hay để dòng code này ở sau cùng

```swift
subject.onNext("Chào bạn lần nữa")
```

Okay, giờ thì chúng ta đã nhận được rồi. Và bạn có thể phát thoải mái nhoé. Xem lại tổng thể code như thế nào

```swift
let subject = PublishSubject<String>()
    
    subject.onNext("Chào bạn")
    
    let subscription1 = subject
        .subscribe(onNext: { value in
            print(value)
        })

    subject.onNext("Chào bạn lần nữa")
    subject.onNext("Chào bạn lần thứ 3")
    subject.onNext("Mình đứng đây từ chiều")
```

Vâng, chúng ta đã xong phần tìm hiểu ban đầu Subject là gì rồi.

### Subject là gì?

**Subject** trong RxSwift hoạt động như vừa là một **Observable**, vừa là một **Observer**. Khi một **Subject** nhận một **.next** event thì ngay lập tức nó sẽ phát ra các emit cho các **subscriber** của nó.

Trong RxSwift, chúng ta có 4 loại Subject với các cách thức hoạt động khác nhau, bao gồm:

- **[PublishSubject](07_1_PublishSubjects.md)**: Khởi đầu "empty" và chỉ emit các element mới cho subscriber của nó.
- [**BehaviorSubject**](07_2_BehaviorSubjects.md): Khởi đầu với một giá trí khởi tạo và sẽ relay lại element cuối cùng của chuỗi cho Subscriber mới.
- [**ReplaySubject**](07_3_ReplaySubjects.md): Khởi tạo với một kích thước bộ đệm cố định, sau đó sẽ lưu trữ các element gần nhất vào bộ đệm này và relay lại các element chứa trong bộ đệm cho một Subscriber mới.
- **AsyncSubject**: Chỉ phát ra sự kiện `.next` cuối cùng trong chuỗi và chỉ khi subject nhận được `.completed`. Cái này ít được sử dụng, nên chắc skip và hẹn ở một thời gian sau.
- [**PublishRelay** & **BehaviorRelay**](07_4_Relays.md) : là các subject được bọc lại (wrap), nhưng chúng chỉ chấp nhận `.next`. Bạn không thể thêm các `.error` hay `.completed`. Vì vậy chúng thích hợp cho các sự kiện không bao giờ kết thúc.

Cụ thể các loại Subject này hoạt động như thế nào thì chúng ta sẽ tìm hiểu ở các phần sau.

