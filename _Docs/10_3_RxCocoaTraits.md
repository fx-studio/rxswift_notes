# RxCocoa Traits

Về Traits thì mình đã có đề cập tại phần trước là `RxSwift Traits`. Trong phần đó chỉ giới thiệu các Traits trong không gian RxSwift. Còn với Traits trong không gian RxCocoa thì sẽ có gì.

### Chuẩn bị

Khâu chuẩn bị cũng khá đơn giản, vì là RxCocoa sẽ liên quan tới giao diện nên bạn sử dụng vào project trước đó nha. Mình sẽ cố gắng tạo các đoạn code demo và ví dụ đơn giản để bạn có thể theo dõi đc. Hoặc các bạn mới đọc cũng có thể tiếp thu nhanh chóng.

Dành cho các bạn quên link check out:

* **Link:** [checkout](../Examples/BasicRxSwift)
* **Thư mục:** `/Examples/BasicRxSwift`

### RxCocoa Traits

Bắt đầu thì chúng ta lượt về một số khái niệm về Traits trong không gian RxCocoa trước. Về khái nhiệm thì như sau

>`Trait` là một wrapper struct với một thuộc tính là một Observable Sequence nằm bên trong nó. Trait có thể được coi như là một sự áp dụng của Builder Pattern cho Observable.

Về đặc trưng thì RxCocoa là không gian mở rộng cho iOS. Chúng sẽ làm việc với các thành phần giao diện và trên Main Thread là chủ yếu. Do đó, các Traits này sẽ có các đặc tính tương tự.

Chúng có các nhóm sau:

* Driver
* Signal
* ControlProperty & ControlEvent

### Driver

Đây là Trait được xem hoàn thành đầy đủ nhất trong RxCocoa. Mục đích của nó cung cấp một cách trực quan để viết code Rx với UI Control hoặc bất cứ khi nào đưa luồng dữ liệu từ model lên UI. 

Đặc điểm của nó như sau:

- **Không** tạo ra lỗi.
- **Observe** và **Subscribe** trên **Main Scheduler**.
- Có chia sẻ **Side Effect**.

Nó mang tên Driver thì cũng với mục đích chuẩn bị cho bạn, khi bạn phát triển mô hình lên cao cấp hơn như MVVM, VIPER ...

* Điều kiển UI từ Model
* Điều kiển UI từ sử dụng các biến từ các UI khác
* Two-way binding

Vì chỉ hoạt động trên Main và không bao giờ sinh ra lỗi. Nên nó hoàn toàn tương thích và an toàn với các UI Control. Bạn sẽ không cần lo lắng gì khi sử dụng nó.

#### Áp dụng nào!

Bạn mở file `WeatherCityController` và tìm tới đoạn code tạo Observable từ việc giá trị text của UITextField.

```swift
        let search = searchCityName.rx.text.orEmpty
            .filter { !$0.isEmpty }
            .flatMap { text in
                return WeatherAPI.shared.currentWeather(city: text).catchErrorJustReturn(Weather.empty)
            }
            .share(replay: 1)
            .observeOn(MainScheduler.instance)
```

Bạn để ý các toán tử sau:

* `.catchErrorJustReturn` nó giúp triệt tiêu error và thay error bằng `empty`
* `.share(replay: 1)` để tạo ra bộ đệm, nhắm các subscription sau khi đăng kí tới thì không gọi lại API mà chúng sẽ sử dụng kết quả ở lần gọi trước đó
* `.observeOn(MainScheduler.instance)` vì là tương tác với UI Control nên phải ở Main Thread, nếu không sẽ crash chương trình

Bạn thấy chúng vất vả phải không nào. Giờ sang thử dùng Trait `Driver` xem như thế nào. Thay đoạn code trên bằng đoạn này.

```swift
        let search = searchCityName.rx.text.orEmpty
            .filter { !$0.isEmpty }
            .flatMap { text in
                return WeatherAPI.shared.currentWeather(city: text).catchErrorJustReturn(Weather.empty)
            }
            .asDriver(onErrorJustReturn: Weather.empty)
```

Các phần trên giờ đc thay bằng 1 dòng lệnh duy nhất `.asDriver(onErrorJustReturn: Weather.empty)`. Nó sẽ corver hết các trường hợp, kể cả API trả về error nữa.

Để đảm bảo cho quá trình chuyển đổi từ 1 Observable thành Driver thì áp dụng toán tử `asDriver(...)`. Và toán tử này có 3 phiên bản

* `.asDriver(onErrorJustReturn:)` trả về 1 giá trị nào đó, có thể emtpy hoặc rỗng ...
* ` .asDriver(onErrorDriveWith:)` phương thức dành cho các bạn trẻ đam mê bộ môn handler error. Khi xử lý xong error thì hãy nhớ trả về 1 Driver mới nha.
* `.asDriver(onErrorRecover:)` cứu nét nó bằng một Driver khác

Trên là cách biến đổi 1 Observable thành 1 Driver. Tiếp theo là cách sử dụng Driver cho UI Control.

```swift
        search.map { "\($0.temperature) °C" }
            .drive(tempLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.cityName }
            .drive(cityNameLabel.rx.text)
            .disposed(by: bag)
        
        search.map { "\($0.humidity) %" }
            .drive(humidityLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.icon }
            .drive(iconLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.cityName }
            .drive(self.rx.title)
            .disposed(by: bag)
```

Cũng không có gì khó ở đây, bạn thay `bind(to:)` bằng `drive(:)` là được. Thử build lại project và cảm nhận kết quả thôi.

### Signal

Về Signal tương tự như Driver. Có một chút khác biệt là nó sẽ không `share` giá trị. Vì vậy, nó không phát lại giá trị cho các subscriber mới.

> Nó sẽ phù hợp với các model events, còn Driver thì là model state

Đặc điểm như sau:

* Không có error
* Hoạt động trên Main
* Có share resource
* Không replay element

Phần này mình không có ví dụ code nha!

### ControlProperty

Khi bạn có `Observable` kết với với `property` của một UI Control thì bạn có được `ControlProperty`.

- **ControlProperty** là một phần của **Observable**/**ObservableType**. Nó đại diện cho các **property** của các thành phần UI.
- **ControlProperty** giúp chúng ta có thể thay đổi giá trị của một **property** trong UIComponent.
- Các **ControlPeroperty** của các thành phần giao diện hầu hết đã được cung cấp bởi RxCocoa.

Phần code ví dụ thì bạn đã làm quá nhiều rồi. Điển hình ở phần Driver thì bạn đã thay đổi giá trị `text` của các UITextField bằng ControlProperty là `.rx.text`

Bạn tìm tới file `UISwitch+Rx.swift` trong phần CocoaPod `RxCocoa` thì sẽ thấy rõ

```swift
extension Reactive where Base: UISwitch {

    /// Reactive wrapper for `isOn` property.
    public var isOn: ControlProperty<Bool> {
        return value
    }

    /// Reactive wrapper for `isOn` property.
    public var value: ControlProperty<Bool> {
        return base.rx.controlPropertyWithDefaultEvents(
            getter: { uiSwitch in
                uiSwitch.isOn
            }, setter: { uiSwitch, value in
                uiSwitch.isOn = value
            }
        )
    }
    
}
```

### ControlEvent

Ngoài các giá trị ra thì bất cứ sự kiện nào do các UI phát sinh ra thì cũng được Rx hoá hết. Chúng là các Trait trong RxCocoa và được gọi là cái tên thân thương ControlEvent.

- **ControlEvent** là một phần của **Observable**/**ObservableType**. Nó đại diện cho các sự kiện của các thành phần UI.
- **ControlEvent** cho phép chúng ta lắng nghe những sự kiện thay đổi tới từ các **UIComponent** ví dụ như UIButton được bấm, UITextField được nhập text từ người dùng,...
- Do có thể theo dõi và nhận các sự kiện của **UIComponent** thông qua **ControlEvent** nên chúng ta có thể không cần tạo các **IBAction** trong source code mà vẫn có thể handle được các sự kiện đến từ UI. Điều đó giúp cho source code trở nên gọn hơn và dễ dàng bảo trì.

Đặc tính như sau:

* Không thất bại
* Không error
* Hoạt động ở Main
* Không gởi giá trị ban đầu cho các subscription
* Nó sẽ kết thúc khi UI Control đó kết thúc (deinit)

Và đây là ví dụ xem là huyền thoại nè

```swift
Button.rx.tap.asDriver()
            .drive(onNext: { _ in
                print("Button tap !")
            })
            .disposed(by: disposeBag)
```

Bạn thêm nó vào code của bạn thì thèn ngồi bên sẽ lác mắt cho xem. Thời điểm này coi như khỏi phải khéo thả các IBAction mệt mỏi nhoé.

#### Áp dụng nào!

Vẫn quay về đoạn code tạo Driver `search` ở phần Driver. Bạn build ứng dụng và thấy mỗi lần gõ chữ thì chương trình chúng ta phản ứng lại ngay tức thì. Các API sẽ gọi liên tiếp nhau mặc dù ta biết chắc là các từ khoá của ta vẫn chưa đúng. 

Như vậy thì quá tốn tài nguyên và xử lý của thiết bị. Đơn giản hơn, ta sẽ bắt sự kiện kết thúc việc edit của UITextField rồi mới tính chuyện trăm năm sau. Xem đoạn code thay thế sau

```swift
        let search = searchCityName.rx.controlEvent(.editingDidEndOnExit)
            .map { self.searchCityName.text ?? "" }
            .filter { !$0.isEmpty }
            .flatMap { text in
                return WeatherAPI.shared
                    .currentWeather(city: text)
                    .catchErrorJustReturn(Weather.empty)
            }
            .asDriver(onErrorJustReturn: Weather.empty)
```

Khác nhau ở chỗ thay vì dùng `rx.text` thì dùng `searchCityName.rx.controlEvent(.editingDidEndOnExit)`. Tập trung vào 1 sự kiện của Keyboard mà thôi.

Bạn build project và thử gõ vài chữ search, xong nhấn Return để thấy kết quả.

### BindingProperty

Ngoài việc sử dụng các ControlProperty, chúng ta có thể tạo các BindingProperty để binding dữ liệu. Đó là các `Binder` .

Phần này, mình đã đề cập ở phần trước. Bạn có thể tìm đọc lại nó nếu chưa biết cách sử dụng. Và ưu điểm của nó thì giúp bạn custom một cách nhanh chóng cho các Property của UI Control.

---

Cảm ơn bạn đã đọc bài viết này!





