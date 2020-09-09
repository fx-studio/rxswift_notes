# Binding Observables

Bây giờ, chúng ta lại lang thang để đi tìm định nghĩa cho một thực thể mới. Nó là gì? Nó tới trái đất này với mục đích gì? ... Tuy nhiên chúng ta cũng cần từng bước lý giải dần chúng thông qua việc mổ sẽ và demo mà thôi.

> Bắt đầu thôi!

### 1. Binding Observables là gì?

#### 1.1. Binding Observables

Bắt đầu câu chuyện thì chúng ta giả đinh có 2 thực thể như sau:

* Producer : thực thể tạo ra giá trị
* Consumer : xử lý giá trị từ Producer

Và một luật được đặt ra trong binding của RxSwift đó là Consumer không được phép return về giá trị. Và nếu bạn suy nghĩ về Binding 2 chiều thì hãy để sau nha.

Còn về cơ bản thì áp dụng binding thì bằng cách sử dụng `bind(to:)` của đối tượng Observable tới 1 đối tượng nào đó. Tất nhiên, yêu cầu Consumer phải là kiểu `ObserverType`. 

> ObserverType là các thực thể chỉ chấp nhận việc ghi (write-only) dữ liệu và chúng không thể subscribe được.

#### 1.2. ObserverType

Qua trên thì lại thêm một định nghĩa mới, đó là ObserverType. Mới nghe qua thì nghe khá mệt mỏi. Nhưng bạn hãy nhớ lại các thực thể Subject đã học trước đây.

> Subject = ObserverType + ObservableType

Nó vừa gởi vừa nhận được. Subject nó lại lưu trữ được dữ liệu nữa. Giúp cho bạn liên kết UI với dữ liệu. Ngoài ra, có thể đăng ký tới để kích hoạt những thực thể khác nếu cần.

Ngoài Subject thì Relay cũng có thể sử dụng được với `bind(to:)`. 

### 3. Sử dụng Binding Observable

Project demo vẫn và project cũ và mà hình `WeatherCityViewController`. Nếu bạn nào quên thì có thể truy cập lại đây:

* **Link:** [checkout](../Examples/BasicRxSwift)
* **Thư mục:** `/Examples/BasicRxSwift`

Trong phần này, chúng ta sẽ áp dụng thử Binding Observable để hiển thị dữ liệu lên UI thì như thế nào. 

Ta có mô hình như sau: 

```
      |----- bind ----> UI Control 1
      |
      |----- bind ----> UI Control 2	
Data -|
      |----- bind ----> UI Control 3
      |
      |----- bind ----> UI Control n
```

Và ta có đoạn code lấy dữ liệu từ API và nhận kết quả trả về là 1 Observable trong bài trước như sau, à bạn truy cập vào function `viewDidLoad` và tìm nó

```swift
        // Check TextField
        searchCityName.rx.text.orEmpty
            .filter { !$0.isEmpty }
            .flatMap { text in
                return WeatherAPI.shared.currentWeather(city: text).catchErrorJustReturn(Weather.empty)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { weather in
                self.cityNameLabel.text = weather.cityName
                self.tempLabel.text = "\(weather.temperature) °C"
                self.humidityLabel.text = "\(weather.humidity) %"
                self.iconLabel.text = weather.icon
            })
            .disposed(by: bag)
```

Bạn cũng đã biết, ta có 1 nguồn phát dữ liệu và Subcribe tới nó. Tại nơi subcribe đó ta lại đưa dữ liệu lên nhiều UI Control một lúc. Giờ với `bind(to:)` thì cần phải tinh gọn em nó lại. Công việc chia ra 2 phần chính:

#### 2.1. Tách nguồn

```swift
let search = searchCityName.rx.text.orEmpty
            .filter { !$0.isEmpty }
            .flatMap { text in
                return WeatherAPI.shared.currentWeather(city: text).catchErrorJustReturn(Weather.empty)
            }
            .share(replay: 1)
            .observeOn(MainScheduler.instance)
```

Ta tạo ra 1 đối tượng Observable là `search`. Vẫn là các đoạn code quen thuộc mà thôi. Tuy nhiên, ta biết sắp tới sẽ đưa dữ liệu của Observable cho nhiều phần tử. Nên việc đảm bảo tính toàn vẹn của Observable thì ta dùng toán tử `share(relay: 1)`.

Với toán tử `share` trên thì còn có ý nghĩa là không cần phải gọi lại việc request API khi có một subscription mới. Chỉ dùng lại kết quả mới nhất mà thôi.

#### 2.2. Binding to UI Control

Giờ đã có Observable rồi. Nó hiện tại đóng vai trò là Producer. Chúng ta thử với Consumer là UILable cho city name nào.

```swift
search.map { $0.cityName }
            .bind(to: cityNameLabel.rx.text)
            .disposed(by: bag)
```

Trong đó:

* `map` dùng để biến đổi cả đối tượng `Weather` thành 1 `String` đơn giản mà thôi
* `bind` để đưa dữ liệu kia tới đúng đối tượng cần tới
* `text` nằm trong không gian của `UILable.rx`, nó là 1 kiểu ObserverType

Bạn hãy truy lùng nó trong thư viện xem `text` là ai?

```swift
public var text: RxCocoa.Binder<String?> { get }
```

Lại thêm 1 khái niệm mới là `Binder`. Tạm thời để sau nha.

Build app và test thử xem việc `bind` đầu tiên đã oke chưa. Còn nếu đã ổn rồi thì bạn quất luôn cho các UI còn lại.

```swift
        search.map { "\($0.temperature) °C" }
            .bind(to: tempLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.cityName }
            .bind(to: cityNameLabel.rx.text)
            .disposed(by: bag)
        
        search.map { "\($0.humidity) %" }
            .bind(to: humidityLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.icon }
            .bind(to: iconLabel.rx.text)
            .disposed(by: bag)
```

Cũng không quá phức tạ nhĩ! Bạn tiếp tục build và test chúng xem dữ liệu đã hiển thị đầu đủ hết chưa.

### 3. Binder

#### 3.1. Khái niệm

Đây là class để tạo ra các đối tượng mang tính chất là `ObserverType`. Nhằm để giúp việc `bind` data của một Observable. 

Trong không gian ReactiveX (Rx) của RxCocoa, thì ta có nhiều thuộc tính cho nhiều UI Control mang kiểu Binder này. Nó sẽ giúp liên kết chặt chẽ giữa property UI với dữ liệu của nguồn phát. Phản ứng lại với từng giá trị mà nó nhận được.

Ta lấy ví dụ cho UIProgressView, với 1 property Binder như sau

```swift
  public var progress: Binder<Float>
```

Và code xem dung lượng file được upload 

```swift
let progressBar = UIProgressBar()

let uploadFileObs = uploadFile(data: fileData)

uploadFileObs
   .map { sent, totalToSend in
       return sent / totalToSend
    }
   .bind(to: progressBar.rx.progress) 
   .disposed(by: bag)
```

Khi lượng dung lượng được upload được gởi đi, thì sẽ nhận được giá trị. Tiến hành biến đổi nó thành `Float` và `bind(to:)` tới thuộc tính `progress` trong không gian Rx. Khi đó về mặt UI thì nó sẽ tự cập nhật luôn trên thanh UIProgressView. Mà ta không cần phải xử lý gì nữa.

#### 3.2. Custom Binder

Chúng ta thực hiện custom Binder một cách đơn giản nhất thôi nha. Chỉ mở rộng thêm class có sẵn và cho nó gia nhập vào không gian của Rx. Công việc ta gôm các bước sau:

Bước 1: Xác định thuộc tính cần liên kết. Hiển nhiên đây là các thuộc tính bình thường của class

* Ta chọn `WeatherCityViewController` làm ví dụ cho cuộc vui này.
* `.title` là thuộc tính của VC đó, hiển thị tên của VC trên NavigationBar

Bước 2: Mở rộng không gian `rx` cho WeatherCityViewController

* Không gian `rx` thì là các phần `extension` của lớp `Reactive`. Bạn tạo 1 extension mới cho nó, theo như đoạn code sau
* Chú ý `Base` chính là class của chúng ta muốn thêm vào không gian `rx`

```swift
extension Reactive where Base: WeatherCityViewController {
    //...
}
```

Bước 3: Tạo Binder Property

* Về tên đặt thì bạn thích tên gì cũng được, ở đây mình chọn tên là `title` cho hack não
* Và kiểu dữ liệu là `String`

```swift
extension Reactive where Base: WeatherCityViewController {
    var title: Binder<String> {
        return Binder(self.base) { (vc, value) in
            vc.title = value
        }
    }
}
```

* Quan trọng là hành động gì mà bạn cài đặt trong khối lệnh khởi tạo `Binder`
* Trong đó
  * Tham số cho `Binder(_:)` là `base`. Nghĩa là chính là ViewController của chúng ta
  * Closure cung cấp với 2 tham số
    * `target` là base, hay lúc này chính là ViewController
    * `value` là giá trị nhận được khi Observable gọi hàm `bind(to:)`
  * Thực hiện logic trong closure cho phù hợp

Bước 4: binding to UI

* Xác định Observable
* Xử lý dữ liệu phù hợp cho Binder
* Gọi hàm `bind(to:)` tới đối tượng Binder vừa tạo

```swift
search.map { $0.cityName }
            .bind(to: self.rx.title)
            .disposed(by: bag)
```

Đoạn code này đặt ở `viewDidLoad` cùng với các đoạn code binding vừa tạo ở phần trên. Bạn hãy build lại project và cảm nhận kết quả thay đổi nha.

---

Cảm ơn bạn đã đọc bài viết này!
