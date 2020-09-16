# 10.4 Working with multi Control

Hiển nhiên một điều là trong project thực tế thì 1 màn hình không đơn giản chỉ hiển thị bằng 1 UI Control. Và cũng không phải im lìm nằm chờ Server gởi dữ liệu về. Và chúng ta phải hiểu một điều cực kì đơn giản nữa. Ngoài UI ra, thì UX cũng là một thành phần quan trọng trong việc hiển thị giao diện.

Ví dụ như lúc loading việc connect tới Server thì phải hiện ra UI loading. Nhằm cho người dùng biết trạng thái là app của bạn đang xử lý việc kết nối ...

### Chuẩn bị

Link check out project:

Dành cho các bạn quên link check out:

* **Link:** [checkout](../Examples/BasicRxSwift)
* **Thư mục:** `/Examples/BasicRxSwift`

### 1. Show loading view

Theo ví dụ trên và theo demo từ hôm bữa tới chừ. Chúng ta đang thiếu cái này. Với `loading view` thì không phải gì mới hết. Bạn có thể sài các thư viện có sẵn như HUB ... Nhưng trong phạm vi demo thì việc code tay vẫn sướng hơn và có nhiều việc cho bạn làm hơn.

Khi nào sẽ show loading:

* Việc hiển thị loading view sẽ cùng lúc với việc request API

Khi nào sẽ hide loading:

* Khi có lỗi xảy ra trong quá trình request và parse data từ API
* Khi nhận được response data từ API

Cũng trình bày ở trên, việc ảnh hưởng tới nhiều UI Control 1 lúc thì xem như hiển nhiên. Ví dụ:

* Show loading --> ẩn đi các Lable khác
* Hide loading --> hiển thị cac Lable khác

Đó chỉ là một trong những ví dụ đơn giản nhất trong các ví dụ đơn giản mà thôi.

Để chuẩn bị thì bạn hay thêm một `UIActivityIndicatorView` vào file `WeatherCityController` cho 2 file `swift` & `xib`.

```
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
```

Bạn build test thử nó đã xuất hiện chưa. Khi đã ổn về mặt setup UI rồi. Thì bạn tới phần dữ liệu.

### 2. Tách Observable

Hiện tại, đây là Observable chính cho việc search API liên quan tới UITextField.

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

Bạn chắc nhận ra là tất cả tụi nó đều gùi hết vào 1 cái duy nhất. Và chúng ta đâu chỉ có mỗi search với UITextField, có thể search với cái khác nữa ... (phần sau sẽ học tới). Nên công việc cần làm bây giờ là tách chúng nó ra.

Bạn xem đoạn code tách sau:

```swift
        let searchInput = searchCityName.rx.controlEvent(.editingDidEndOnExit)
            .map { self.searchCityName.text ?? "" }
            .filter { !$0.isEmpty }
        
        let search = searchInput
            .flatMapLatest { text  in
                return WeatherAPI.shared.currentWeather(city: text)
                    .catchErrorJustReturn(Weather.empty)
            }
            .asDriver(onErrorJustReturn: Weather.empty)
```

Trong đó:

* `searchInput` sẽ chỉ liên quan tới UITextField. Nó chỉ có 1 nhiệm vụ duy nhất là `emit` ra một String. 
* `search` bây giờ là Observable với dữ liệu từ API trả về. Vẫn là các bắt error cũ
* `asDriver` để sử dụng Trait cho các UI Control ở dưới. Đảm bảo an toàn trên UI và MainThread

Bây giờ, ta đã có các Observable riêng lẻ cho từng mục đích sử dụng. Chuyển qua việc handling phức hợp với nhiều UI.

### 3. Handle

Cách dễ nhất là bạn phải có 1 đối tượng nào đó để nắm chốt hết các trường hợp xãy ra. Ví dụ quan tâm của chúng ta đang là `loading view`. Rồi từ đối tượng đó, các UI Control sẽ chịu tác động theo.

Về các trường hợp liên quan tới `loading view` thì như nhắc ở trên. Bây giờ ta chọn việc tạo ra 1 Observable mà kết hợp lại nhiều điều kiện hay là nhiều Observable đã tách ở trên.

Bạn xem đoạn code sau:

```swift
let loading = Observable.merge(
                searchInput.map { _ in true },
                search.map { _ in false }.asObservable()
            )
            .startWith(true)
            .asDriver(onErrorJustReturn: false)
```

Trong đó:

- `merge` truyền thống. Dùng để gôm các Observable lại với nhau
- Observable nào cuối cùng phát đi giá trị. Thì nó sẽ nhận đc là mới nhất
- `searchInput` thì khi người dùng nhấn gõ và khác rỗng thì sẽ phát đi `true`. Tức là yêu cầu `loading view` hiển thị
- `search` khi có kết quả từ API về thì sẽ phát ra `false` , tức là hoàn thành 1 tác vụ gọi API. Lúc đó yêu cầu `loading view` ẩn đi
- `starWith` để cho `loading view` bắt đầu bằng gì đó mặc định, có thể là show trước tiên
- `asDriver` để biến nó thành Driver, phục vụ cho Binding lên UI dễ hơn

Cuối cùng là sử dụng nó trên UI như thế nào. Bắt đầu với em `activityIndicator`

```swift
        loading
            .skip(1)
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: bag)
```

Cũng đơn giản phải không nào. Về `skip(1)` hay gì đó là do bạn setup ban đầu. Vì mình để ActivityIndicator hiển thị ngay lúc bắt đầu của ViewController. Nên có thể bỏ qua phần tử đầu tiên.

Áp dụng tương tự cho các UI còn lại.

```swift
        loading
            .drive(containerView.rx.isHidden)
            .disposed(by: bag)
        
        loading
            .drive(tempLabel.rx.isHidden)
            .disposed(by: bag)
        
        loading
            .drive(iconLabel.rx.isHidden)
            .disposed(by: bag)
        
        loading
            .drive(humidityLabel.rx.isHidden)
            .disposed(by: bag)
        
        loading
            .drive(cityNameLabel.rx.isHidden)
            .disposed(by: bag)
```

Nếu OKE tất cả, thì bạn hãy build lại project và test lại xem chúng đã hoạt động theo ý mình chưa. Và nếu hoạt động OKE là bạn sẽ thấy `loading view` xuất hiện mỗi lần bạn gõ và nhấn enter. Sau khi API kết thúc thì nó cũng ẩn theo.

---

Chúc bạn thành công & cảm ơn bạn đã đọc bài viết này!