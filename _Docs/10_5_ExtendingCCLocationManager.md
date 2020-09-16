# 10.5 Extending CCLocationManager

Đôi khi những class của Cocoa không phải lúc nào cũng có các function trong không gian ReactiveX. Lúc này thì bạn cần nâng cao thêm skill mới để biến Non-Rx thành Rx. Và cũng trong cách bài trước bạn đã cũng đã tự custom được `Binder` đơn giản cho properties của 1 Class.

Bài này sẽ tập trung việc Rx hoá cho các protocol Delegate của class `CCLocationManager`. Từ đó, bạn sẽ rút ra được cách Rx hoá protocol Delegate một cách tổng quát.

### Bước 1 : tạo extension

Tạo file `*.swift` với tên là `CLLocationManager+Rx.swift` để định nghĩa các phương thức & thuộc tính nằm trong không gian `Rx`. Để đảm bảo được việc này thì chúng nó phải lại mở rộng `Reactive<Base>` và nó lại kế thừa tới `ReactiveCompatible` protocol .

Tiếp theo nữa thì có một khái niệm `Delegate Proxy`. Delegate Proxy sẽ là lớp trung gian, đối tượng này sẽ đảm nhận việc nhận dữ liệu và phát lại dưới dạng Observable.

Sự kết hợp của `Delegate Proxy` và `Reactive` sẽ biến các `extention` của các class trong Cocoa trở thành Rx hoá.

```
Delegate proxy
     +             = AClass.rx...
Reactive<AClass>
```

Quay lại chủ đề chính của chúng ta. Tạo 2 extension như sau:

* CLLocationManager

```swift
extension CLLocationManager: HasDelegate {
    public typealias Delegate = CLLocationManagerDelegate
}
```

Extension này sẽ báo cho Rx biết class đó có `Delegate`. Bạn cần nhớ là `CLLocationManager` & `CLLocationManagerDelegate` là 2 thực thể khác nhau. Chỉ giống nhau cái tên phía trước thôi.

* RxCLLocationManagerDelegateProxy

```swift
class  RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {
   
}

```

Class này sẽ là Proxy cho class `CLLocationManager`. Và ngay sau đó thì 1 đối tượng Observable sẽ được tạo ra và có subscription. Điều này đơn giản hoá bới `HasDelegate protocol` (được cung cấp bởi `RxCocoa`). Nếu không làm công việc này thì phải cần phải khai báo thêm 2 function sau cho việc kế thừa `DelegateProxyType`

```swift
    public static func currentDelegate(for object: ParentObject) -> Delegate? {
        return object.delegate
    }

    public static func setCurrentDelegate(_ delegate: Delegate?, to object: ParentObject) {
        object.delegate = delegate
    }
```

> Thầm cảm ơn tới `HasDelegate` protocol. Em nó giúp cho bạn giản đi 1 nữa công việc rồi.

### Bước 2: Register

Như trên thì 1 class Proxy thì cần phải có các phương thức sau:

```swift
class  RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {
  
    static func registerKnownImplementations() {
        
    }
    
    static func currentDelegate(for object: AnyObject) -> Any? {
       
    }
    
    static func setCurrentDelegate(_ delegate: Any?, to object: AnyObject) {
      
    }
    
}
```

Do 2 function về delegate đã được giải quyết với `HasDelegate` rồi. Nên ta sẽ xoá nó đi và quản tâm tói em `register` thôi. Nhưng mà việc đầu tiên cần phải làm vẫn là khai báo thêm 1 thuộc tính cho `Base` (CLLocationManager).

```swift
weak public private(set) var locationManager: CLLocationManager?
```

Vì chúng ta có 1 Property mới nên nó cần phải được khởi tạo. Do đó, ta phải thêm 1 function `init` nữa.

```swift
    public init(locationManager: ParentObject) {
        self.locationManager = locationManager
        super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }
```

Bạn cần chú ý tới:

* `ParrentObject` nó chính là `Base` và cũng là `CLLocationManager` trong ví dụ của chúng ta.
* Sau đó gán thuộc tính với tạo với tham số `ParrentObject`
* Cuối cùng gọi `super.init` để hoàn thiện việc khởi tạo

Khi các việc khởi tạo đã xong thì tới việc chính là đăng ký các function delegate và uỷ quyền cho class Proxy này.

```swift
    static func registerKnownImplementations() {
        self.register { RxCLLocationManagerDelegateProxy(locationManager: $0) }
    }
```

Nó sẽ `register` tất cả và đăng ký tới tất cả các function của Delegate (CLLocationManagerDelegate). Nhằm đưa dữ liệu từ đối tượng Base (CLLocationManager) đến các đối tượng Observable được kết nối tới.

> Đây là cách mở rộng (extension) 1 class bằng `delegate proxy pattern` từ RxCocoa.

### Bước 3: Mở rộng không gian Rx cho class

Bây giờ, ta tiếp tục mở rộng thêm không gian Rx từ struct chính là `Reactive` cho class `CLLocationManager`. Để có thể sử dụng `.rx` huyền thoại. Thêm 1 extension như sau:

```swift
public extension Reactive where Base: CLLocationManager {
    
}
```

Chúng ta đã quen thuộc với cách tạo thêm function hoặc property trong không gian `Reactive` này rồi. Bạn hãy nhớ lại phần custom Binder nha.

Và tất nhiên, chung ta cần tới đối tượng Proxy để làm cầu nối trung gian rồi. Bạn tiếp tục thêm đoạn code sau.

```swift
    var delegate : DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
    }
```

Trong đó:

* `delegate` là đối tượng `DelegateProxy`
* Khởi tạo nó bằng class Proxy được khai báo ở trên
* Với tham số cho `.proxy` chính là `base` (là thực thể CLLocationManager được sử dụng `.rx`)

### Bước 4: Method Invoked

Giờ là phần cuối cùng, bạn muốn dùng tới function nào trong Delegate (CLLocationManagerDelegate) thì hãy mờ nó vào để cùng quẩy. 

> Nếu bạn xem nhiều tutorial khác trên mạng thì khúc này sẽ rối não lắm. Kinh nghiệm xương máu mà mình đúc kết được. Tới đây thì bạn nào logic như thế nào thì sẽ có cách triển khai tương ứng.

Trong ví dụ demo này, ta cần lấy được location mới nhất được update từ đối tượng CLLocationManager. Trước tiên, bạn xác định cần dùng function nào trong CLLocationManagerDelegate. Ta chọn em này

```swift
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
```

OKAY rồi, chúng ta lại quay về extension Reactive ở trên và thêm đoạn code sau:

```swift
    var didUpdateLocation: Observable<[CLLocation]> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
            .map { parameters in
                return parameters[1] as! [CLLocation]
            }
    }
```

Tiến hành phân tích chúng nó một chút

* `didUpdateLocation` là một Observable với kiểu giá trị trả về là một Array CLLocation
* Sử dụng chính delegate proxy bằng việc dùng method `methodInvoked`. Nó như một lời mời gọi function của CLLocationManagerDelegate mà ta đã chọn ở trên.
* Vì là của Objective-C nên bạn sử dụng `#selector` và cung cấp đúng function đã chọn
* Kết quả trả về sẽ là 1 Observable với kiểu như thế này `Observable<[Any]>` Trong đó `[Any]` là một mãng được tạo từ các tham số trong function của CLLocationManagerDelegate.
* Cuối cùng ta dùng `map` để đưa `[Any]` thành `[CLLocation]`. Tất nhiên là không thể đc liên. Vì function của CLLocationManagerDelegate có tới 2 tham số.
* Xác định từ trước thì tham số thứ 2 `parameters[1]` sẽ là `[CLLocation]`. Nên chỉ việc return nó trong `map` là xong.

Cuối cùng cũng xong các bước tạo mệt mỏi này. Hi vọng bạn sẽ kiên trì để hết và kĩ. Nếu chỉ cần lơ là một tí thì lại không hiểu chi hết. Mọi việc cứ copy dán mù quán. Mình đã gãy tại đây tới 3 lần rồi. Đau!

### Bước 5: Sử dụng

Mọi thứ setup đã xong. Bước này chỉ là cách dùng nó thôi. Tại `WeatherCityViewController` bạn khai báo thêm 1 property CLLocationManager. Nhớ import `CoreLocation` trước nha.

```swift
private let locationManager = CLLocationManager()
```

Về mặt UI thì bạn thêm 1 UIButton và tạo IBOutlet cho nó. Ta đặt tên là `locationButton`. Button này chịu trách nhiệm gọi việc `startUpdateLocation`. Thay vì tạo 1 IBAction thì ta cũng dùng luôn `ControlEvent` cho nó xin sò.

Tại `viewDidLoad` bạn thêm đoạn code sau

```swift
        locationButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.startUpdatingLocation()
            })
            .disposed(by: bag)
```

Sử dụng `rx.tap` thì mọi thứ có vẻ trông pro lên liền. Công việc chỉ còn là `subscribe` và handle vào trong đó. Với 2 việc chính

* `requestWhenInUseAuthorization()` để xin cấp quyền
* `startUpdatingLocation()` bắt đầu việc tracking location theo GPS

Tiếp theo, ta cần `subscribe` tới đối tượng `locationManager` để đăng ký tới function update Location mà đã dày công setup ở trên. Thêm tiếp đoạn code sau nha

```swift
        locationManager.rx.didUpdateLocation
            .subscribe(onNext: { locations in
                print(locations)
            })
            .disposed(by: bag)
```

Khá là EZ phải không nào. Từ bây giờ trở đi, chúng ta sẽ quên đi việc implement các function của các Delegate protocol đi là vừa rồi. Cùng nhau quẩy với Rx nào!

Bạn hãy build project và nhấn vào `locationButton` để xem kết quả đúng như ta mong muốn không. Nếu ra được kết quả thì chúc mừng bạn đã vượt qua skill khó này. Ví dụ kết quả như sau:

```
...
[<+37.33044907,-122.02969739> +/- 10.00m (speed 7.01 mps / course 89.09) @ 9/16/20, 3:59:14 PM Indochina Time]
[<+37.33044907,-122.02969739> +/- 10.00m (speed 7.01 mps / course 89.09) @ 9/16/20, 3:59:18 PM Indochina Time]
[<+37.33063636,-122.03063618> +/- 10.00m (speed 2.27 mps / course 158.84) @ 9/16/20, 4:15:16 PM Indochina Time]
[<+37.33061331,-122.03062365> +/- 10.00m (speed 1.90 mps / course 159.97) @ 9/16/20, 4:15:17 PM Indochina Time]
...
```

----

Chúc bạn thành công & cảm ơn bạn đã đọc bài viết này!



