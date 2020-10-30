# 10.6 Merge Observables Input

### Vấn đề

Trong các phần trước, chúng ta đã lần lượt đi qua từng vấn đề trong UIKit được giải quyết bằng RxCocoa. Và cũng từ đó chúng ta thấy có nhiều vấn đề mới phát sinh thêm. Trong số đó, nguy hiểm nhất vẫn là các sự kiện khác nhau xảy ra, nhưng lại kích hoạt cũng 1 xử lý/tương tác trong project.

Ví dụ, lấy phần gọi API để phân tích.

* UITextField
  * Khi gõ chữ thì chúng ta tiến hành kiến tra TextField.
  * Nếu kiểm tra xong cho text của TextField đã oke, thì sẽ gọi API
* User Location
  * Lắng nghe sự update dữ liệu Current Location
  * Mỗi khi dữ liệu nhận được mà phù hợp các tiêu chí search, thì tiến hành gọi API
* Data default
  * Thường khi khởi tạo 1 ViewController, ta sẽ cung cấp dữ liệu mặc định cho nó.
  * Trường hợp này sẽ được khởi tạo và gọi API
* *... (còn nhiều trường hợp khác mà tuỳ thuộc vào yêu cầu của project)*

Không chỉ đơn giản trong ví dụ đó là chỉ có 1 xử lý/tương tác được thực hiện. Mà chúng ta còn có các Side Effect khác hoặc các xử lý phụ đi kèm. Ví dụ, như loading view ...

Đó là những vấn đề thường ngày khi bạn làm dự án. Nhất là với các dự án thường xuyên thay đổi yêu cầu. Giải quyết nó thì không khó. Khó là ...

> Cần xử lý một cách tập trung và thống nhất.

Tạm thời mượn lại ví dụ đang dang dở để tiến hành viết tiếp câu chuyện này ....

### Get data with Current Location

Với ví dụ của chúng ta thì API lấy thông tin thời tiết, ngoài việc tìm kiếm bằng tên thành phố. Chúng ta có thể tìm kiếm theo vị trí toạ độ GPS. Do đó, ta hãy thêm một function trong file **WeatherAPI.swift** . Bạn tham khảo đoạn code sau:

```swift
    func currentWeather(at coordinate: CLLocationCoordinate2D) -> Observable<Weather> {
      return request(pathComponent: "weather", params: [("lat", "\(coordinate.latitude)"),
                                                        ("lon", "\(coordinate.longitude)")])
        .map { data in
          let decoder = JSONDecoder()
          return try decoder.decode(Weather.self, from: data)
        }
    }
```

Chỉ là thay đổi lại `params` truyền vào thôi. Mọi thứ vẫn không thay đổi nhiều.

### Create Location Search

Ở bài trước, ta dùng `button.rx.tap` để bắt sự kiện người dùng. Từ đó kích hoạt đối tượng `CLLocationManager` tiến hành tracking GPS.

```swift
        locationButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.startUpdatingLocation()
            })
            .disposed(by: bag)
```

Và code lắng nghe sự thay đổi dữ liệu Current Location từ việc Custom Delegate Proxy của CLLocationManager.

```swift
        locationManager.rx.didUpdateLocation
            .subscribe(onNext: { locations in
                print(locations)
            })
            .disposed(by: bag)
```

Hiện tại, chúng ta cần tạo đối tượng để quản lý việc search và lắng nghe này.

**Bước 1:** Tạo đối tượng lắng nghe sự thay đổi Current Location

```swift
        let currentLocation = locationManager.rx.didUpdateLocation
            .map { locations in locations[0] }
            .filter { location in
                return location.horizontalAccuracy < kCLLocationAccuracyHundredMeters
            }
```

Tại bước này, chỉ là lấy Observable từ Delegate Proxy mà thôi. Tất nhiên, thêm chút điều kiện để lọc bớt các `location` quá gần nhau.

**Bước 2:** Tạo đối tượng lấy sự kiện từ Button liên quan tới Location

```swift
        let locationInput = locationButton.rx.tap.asObservable()
            .do(onNext: {
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.startUpdatingLocation()
                
            })
```

Cứ khi nào người dùng kích vào button. Thì chúng ta sẽ kích hoạt việc update Location từ đối tượng CLLocationManager.

Lúc có dữ liệu mới của GPS update thì đối tượng `currentLocation` sẽ phát đi dữ liệu. Do đó, ta cần bắt được dữ liệu này.

```swift
let locationObs = locationInput
            .flatMap { return currentLocation.take(1) }
```

Và bạn chỉ cần lấy 1 phần tử mà thôi. Nhưng thay vì lấy dữ liệu thì ta dùng `flatMap` để biến nó thành 1 Observable, để tiện sử dụng cho nhiều việc sau.

Tóm lại:

* Nhấn button sẽ kích hoạt việc tracking Location
* Tạo đối tượng lắng nghe sự thay đổi Current Location
* Từ đối tượng của `button.tap` ta tiến hành `flatMap` để tạo ra các Observable bằng cách lấy 1 dữ liệu từ đối tượng lắng nghe Current location

=> Chúng ta sẽ sử dụng các Observable được tạo ra đó để request tới API.

### Merge Search Inputs

Chúng ta đã có nhiều nguồn hay nhiều xuất phát điểm để tiến hành gọi API để lấy dữ liệu. Mọi thức đối với bạn thì vẫn có thể handle trong tầm tay. Nhưng bạn có dám chắc một điều rằng mình bỏ sót 1 hay vài trường hợp nào đó không.

Bạn biết rằng, cứ mỗi sự kiện gọi API thì bạn sẽ nhận được dữ liệu. Cấu trúc dữ liệu bạn nhận được sẽ không đổi. Nên tại sao chúng ta không hợp nhất tất cả sự kiện gọi API về 1 điểm duy nhất. Hay một nguồn phát duy nhất. Khi đó, công việc còn lại thì khá là đơn giản. Lắng nghe những gì nó phát ra.

Okay! tiến hành thôi. 

**Bước 1: Tạo các Observable liên quan**

- Search with UITextField

```swift
        let textSearch = searchInput.flatMap { text in
            return WeatherAPI.shared.currentWeather(city: text)
                .catchErrorJustReturn(.dummy)
        }
```

Chỉ là việc gọi lại function `currentWeather(city:)` với dữ liệu `text` từ TextField. Chúng sẽ trả về một Observable.

- Search with Location

```swift
        let locationSearch = locationObs.flatMap { location  in
            return WeatherAPI.shared.currentWeather(at: location.coordinate)
                    .catchErrorJustReturn(.dummy)
        }
```

Áp dụng tương tự nha. Gọi hàm `currentWeather(at:)` với dữ liệu là `location`.

**Bước 2: Merge**

```swift
let search = Observable
            .merge(locationSearch, textSearch)
            .asDriver(onErrorJustReturn: .dummy)
```

Sử dụng toán tử `merge` với tham số là 2 Observable tạo ở Bước 1. Sau đó biến đổi chúng nó thành 1 `Drive` bằng toán tử `asDriver` , để có thể đưa dữ liệu trực tiếp lên các UI Control của UIKit.

Với toán tử `merge` thì sẽ phát đi dữ liệu khi các Observable con phát đi dữ liệu. Bạn sẽ an tâm, từ bất cứ sự kiện nào gọi API đi nữa. Chúng ta chỉ cần `subscribe` tới Observable merge kia thì sẽ có được dữ liệu.

=> Các công việc còn lại chỉ là `subscribe` hoặc `drive` mà thôi. Chúng không có gì thay đổi hết.

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

---

Tới đây xin tạm kết bài viết nhỏ này. Hi vọng với việc bạn phân tích kĩ logic và các use-case trong project thì sẽ tạo ra được các Observable vô cùng hiệu quả. Qua đó cũng giảm tải đi các lỗi ngớ ngẫn khi code.

Cám ơn bạn đã đọc bài viết này!