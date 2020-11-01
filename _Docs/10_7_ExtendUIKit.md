# Extend UIKit

Đối tượng tiêu diệt tiếp theo của RxSwift & RxCocoa lần này sẽ là các UI Control trong UIKit. Ở phần trước, chúng ta đã tìm các tạo ra được các Extention trong không gian `.rx` của một class. Với việc áp dung Proxy Delegate.

Còn lần này chúng ta sẽ thử nghiệm `reactive extension` cho một class của UI Control. Class được chọn là `MKMapView`.

> Bắt đầu thôi!

### Create Extentions

#### Bước 1: tạo extention

Công việc sẽ bắt đầu bằng việc tạo các extention. Bước này sẽ khá là giống với việc tạo `Proxy Delegate`. Bạn tạo một file với tên là `MKMapView+Rx.swift`. Nhớ `import` đầy đủ các con ông cháu cha thư viện vào. Sau đó bạn thêm đoạn code sau.

```swift
extension MKMapView: HasDelegate {
    public typealias Delegate = MKMapViewDelegate
}

class RxMKMapViewDelegateProxy: DelegateProxy<MKMapView, MKMapViewDelegate>, DelegateProxyType, MKMapViewDelegate {
    weak public private(set) var mapView: MKMapView?
    
    public init(mapView: ParentObject) {
        self.mapView = mapView
        super.init(parentObject: mapView, delegateProxy: RxMKMapViewDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { RxMKMapViewDelegateProxy(mapView: $0) }
    }
}
```

Bạn sẽ thấy chúng nó có 2 phần là:

* Extention với `HasDelegate`
  * Bình thường thì MKMapView sẽ không có `delegate protocol` trong đó. Nên chúng ta sẽ kế thừa thêm protocol `HasDelegate`
  * Sau đó khai báo thêm một `typealias` Delegate chính là protocol `MKMapViewDelegate`
* Proxy class
  * Tạo một class mới với tên là `RxMKMapViewDelegateProxy` (chỉ là cái tên thôi nha). 
  * Nhiệm vụ của class này sẽ nhận các delegate từ `MKMapViewDelegate` và biến đổi chúng thành một Observable. Sau đó sẽ phát dữ liệu đi. (nôm na là rứa)
  * Bạn cần kế thừa lại `DelegateProxy` & `DelegateProxyType`.
  * Vì đã khai báo `HasDelegate` ở trên cho MKMapView, nên công việc của bạn sẽ đơn giản hơn.
    * tạo 1 property là `mapView`
    * tạo hàm `init`
    * tạo hàm register với tất cả các delegate từ MKMapViewDelegate

Cũng khá là khó hiểu phải không nào. Nếu không hiểu thì bạn cứ copy và làm thôi. Suy nghĩ nhiều nhanh già lắm. Tóm lại, sau bước 1 này chúng ta đã có một class proxy cho MKMapView. Okay và sang bước 2.

#### Bước 2: Extention Reactive

Bắt đầu bằng việc tạo Extention cho class huyền thoại `Reactive`. Bạn tiếp tục file trên và thêm đoạn code sau vào.

```swift
public extension Reactive where Base: MKMapView {
    
}
```

Mục đích to lớn nhất của nó thì bạn có thể triệu hồi được các function hay properties trong không gian `.rx`.

Tiếp tục, bạn thêm một property là `delegate`. Đây chính là Proxy class ở trên. Và bạn chỉ cần dùng class tạo ở bước 1 và return nó về thôi.

```swift
    var delegate: DelegateProxy<MKMapView, MKMapViewDelegate> {
        return RxMKMapViewDelegateProxy.proxy(for: base)
    }
```

Bây giờ, bạn đã có được không gian `.rx` cho MKMapView và bạn có class proxy cho MKMapViewDelegate rồi. Công việc tiếp theo là bạn muốn gì thì hãy lấy cái đó.

### Forward Delegate

> Cái qq này là cái gì?

Trong bài trước, bạn đã mệt não với Proxy Delegate rồi. Bây giờ còn sinh thêm **Forward Delegate**. Bạn bình tĩnh và làm ly trà, chúng ta tiếp tục tìm hiểu nó là gì.

#### Vấn đề

Thường bạn sẽ thấy các Delegate hầu như sẽ trả về cho bạn 1 sự kiện. Rồi từ đó chúng ta biến đổi thành Observable và gởi kèm về các giá trị. Các giá trị đó chính là các đối số được truyền vào cho tham số của các function delegate.

> Hiển nhiên, công việc này khá là vất vả. Bạn cũng để ý chúng nó toàn là hàm `void`

Và nếu như khác `void` thì TOANG lớn.

* Delegate với có kiểu giá trị trả về thì không dùng để quan sát. Mà dùng để điều chỉnh sự hiện thị/hành vi của đối tượng
* Chúng ta sẽ cần tới 1 giá trị `default` tự động cho mọi trường hợp. Nó đảm bảo sự hoạt động của đối tượng. Tuy nhiên việc này khó lại càng khó.

Giải pháp thì bạn có thể sử dụng tới `Subject` như là một cứu cánh. Nó có thể vừa set được dữ liệu và emit đc dữ liệu.

Tất nhiên, ông trời không tuyệt đường sống của bạn bao giờ. Bạn có thể đảm bảo được việc sử dụng không gian Reactive cho các delegate có trả về giá trị. Vừa có thể điều chỉnh hành vi, vừa có thể quan sát được từ bên ngoài.

```swift
 public static func installForwardDelegate(_ forwardDelegate: AnyObject, retainDelegate: Bool, onProxyForObject object: AnyObject) -> Disposable
```

> Đó là Forward Delegate.

#### Create Forward Delegate

Về lại file `MKMapView+Rx.swift` và thêm function sau vào

```swift
    func setDelegate(_ delegate: MKMapViewDelegate) -> Disposable {
        return RxMKMapViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }
```

Với cách này chúng ta sẽ sử dụng như sau. Bạn về lại file ViewController. Tại function `viewDidLoad` bạn thêm đoạn code sau:

```swift
        mapView.rx.setDelegate(self)
            .disposed(by: bag)
```

Lúc này thì delegate của `mapView` chính là ViewController. Tuy nhiên, nó cũng là một Observable và bạn có thể ném nó vào túi rác quốc dân. Như vậy bạn đã đưa được delegate vào không gian `.rx` rồi.

Tất nhiên, sẽ bị Xcode báo lỗi. Bạn hãy thêm extension sau

```swift
extension WeatherCityViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pin.animatesDrop = true
        pin.pinTintColor = .red
        pin.canShowCallout = true
        return pin
    }
}
```

Mình sẽ dùng hàm `viewForAnnotation` của delegate MapView. Nó cần phải return cho nó 1 View. Chúng ta tạo 1 `pin` cơ bản và return trở về.

Tóm tắt một chút

* Proxy Delegate
  * Bạn chỉ cần quan tâm tới 1 function delegate mà ko có return type
  * Đối tượng sét vào delegate chính là 1 closure
* Forward Delegate
  * Set cả 1 đối tượng bất kì thành delegate
  * Implement các phương thức delegate cần thiết với return type

#### Sử dụng

Vấn đề quan trọng tiếp theo là sử dụng sao cho nó hài hoà với nhau. Bạn hãy nhớ lại Proxy của CLLocationManager. ta sẽ lợi chúng. Bạn tham khảo đoạn code sau

```swift
        locationManager.rx.didUpdateLocation
            .subscribe(onNext: { locations in
                for location in locations {
                    let pin = MKPointAnnotation()
                    pin.coordinate = location.coordinate
                    pin.title = "Pin nè"
                    
                    self.mapView.addAnnotation(pin)
                }
            })
            .disposed(by: bag)
```

Ta lắng nghe sự kiện phát ra từ việc `didUpdateLocation`. Sau đó tạo 1 `pin` và set vào MapView. Khi đó MapView sẽ yêu cầu delegate (chính là ViewController đã làm ở bước trên) thực thi function `viewForAnnotation`.

Và chỉ có như vậy thôi. Bạn build lại ứng dụng và xem kết quả nhoé.

### Custom Binder

Đây là thành phần không thể thiếu trong việc mở rộng thêm không gian Reactive của một UI Control. Phần này chúng ta đã có đề cập tới trong việc thực thiện tạo thêm các properties cho một UI Control để đưa dữ liệu trực tiếp lên UI mà không cần phải `subscribe` hoặc biển đổi gì.

#### Sử dụng Data từ API

Ở trên, chúng ta đang sử dụng dữ liệu thôi lấy được để thêm một PIN vào bản đồ. Tuy nhiên, bài toán của chúng ta sẽ như sau:

* Bạn đã có nhiều cách gọi API để lấy dữ liệu
* Mỗi khi có dữ liệu thì bạn sẽ thêm một PIN lên bản đồ
* Với thông tin thời tiết trong call out của PIN đó

Về việc lấy API thì bạn có theo dõi ở các bài trước. Chúng ta đã có được 1 Observable của API và lắng nghe đc kết quả trả về. Nên công việc của bạn bây giờ chỉ đơn giản là biến đổi

> Khi nghe đến biến đổi thì bạn chỉ cần nhớ tới `map` huyền thoại của chúng ta.

#### Biến đổi

Bạn mở lại file **WeatherViewController** kia, và tại hàm `viewDidLoad` bạn thêm đoạn code sau vào.

```swift
search.map { weather -> MKPointAnnotation in
            // coding here ...
        }
```

Trong đó

* Observable `search` thì chúng ta đã tạo ra ở các bài trước. Bạn có thể xem lại nếu quên
* `map` dùng để biến đổi về mặt kiểu dữ liệu cho phần tử được phát đi từ Observable
* Đưa kiểu Weather thành MKPointAnnotation. Đây chính là kiểu hiển thị PIN (tức MKPointAnnotationView ở phần trên)

Thêm ít code nha

```swift
search.map { weather -> MKPointAnnotation in
            let pin = MKPointAnnotation()
            pin.title = weather.cityName
            pin.subtitle = "\(weather.temperature) °C - \(weather.humidity) % - \(weather.icon)"
            pin.coordinate = weather.coordinate
            
            return pin
        }
```

Phần này chắc mình không cần giải thích. Nó quá là EZ! Nhưng vẫn còn thiếu cái gì đó.

> subscribe

#### New Binder

Dữ liệu đã có và nguồn phát đã sẵn sàn. Ở phần trên thì chúng ta dùng `subscribe` , nhưng nó xưa rồi. Chúng ta phải dùng trên RxCocoa và các trait của nó. 

Nên việc tiếp theo là bạn tạo ra một Binder của riêng class MKMapView trong không gian Reactive. Bạn mở file `MKMapView+Rx.swift` thêm đoạn code sau vào `Extension Reactive`

```swift
var pin: Binder<MKPointAnnotation> {
        return Binder(self.base) { mapView, pin in
            mapView.addAnnotation(pin)
        }
    }
```

Trong đó:

* `pin` là một thuộc tính trong không gian `.rx`
* `Binder` với kiểu là `MKPointAnnotation` , nó sẽ nhận dữ liệu với chính kiểu kia. Lên đối tượng `base` là MapView
* Công việc là dùng pin đó và add lên map

Đơn giản phải không nào. Tiếp tục sang việc hoàn thiện nó nào!

#### Binding

Bạn về lại file WeatherViewController, tại đoạn code cuối cùng bạn thêm vào ở bước trên. Bạn tiếp tục thêm tiếp đoạn code sau

````swift
        search.map { weather -> MKPointAnnotation in
            let pin = MKPointAnnotation()
            pin.title = weather.cityName
            pin.subtitle = "\(weather.temperature) °C - \(weather.humidity) % - \(weather.icon)"
            pin.coordinate = weather.coordinate
            
            return pin
        }
        .drive(mapView.rx.pin)
        .disposed(by: bag)
````

Dùng `drive` để sử dụng RxCocoa Trait (nó đã được biết đổi trên rồi), đưa trực tiếp lên `pin` trong không gian `rx` của mapView. Chúng nó tương thích với nhau vì Binder là kiểu `ObserverType` và `Driver` hoạt động ở MainThread nên không gây ra crash chương trình khi cập nhật UI.

Cuối cùng, bạn đường quên túi rác quốc dân nha. Xong rồi hãy build lại Project và tận hưởng kết quả nào.

### Proxy Delegate

Khi bạn mở rộng một UI Control trong không gian Reactive mà không có các phương thức Proxy Delegate quả thật là một thiếu sót quá lớn rồi. 

Về việc tạo các file & class cho Proxy Delegate thì các bạn cứ làm theo 2 bước ở phần `Create Extension`. Giờ chuyển sang bạn muốn lấy gì từ các Delegate của UI Control mà sẽ triển khai các bước tiếp theo.

> Đối tượng ta vẫn là MKMapView & MKMapViewDelegate

#### Bài toán

Chúng ta có một yêu cầu đơn giản là mỗi khi di chuyển MapView của chúng ta, thì...

* Bắt được sư kiện di chuyển đó
* Lấy được toạ độ của điểm chính giữa của bản đồ
* Tiến hành request API bằng với toạ độ kia
* Kết quả sẽ update lên bản đồ với 1 pin (được làm ở phần trên)

Bài toán của chúng ta khác là rõ ràng rồi. Chúng ta sẽ phân tính và triển khai nó trong không gian của `.rx`. Tuy nhiên, các bài trước + phần trên thì chúng ta đã có năng lực `rx` hoá hết rồi. Chỉ còn sót mỗi việc bắt sự kiện di chuyển của MapView mà thôi.

> Giải quyết chúng bằng việc cho Proxy Delegate bắt chúng và chuyển đổi thành Observable.

#### Method Invoked

Đối tượng cần xác định để uỷ thác là function sau trong MKMapViewDelegate

```swift
 func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
```

Khi bạn cài đặt phương thức đó vào ViewController. Thì mỗi lần MapView bị di chuyển (tức `drag`) thì function kia sẽ được gọi. Giờ chúng ta sẽ đưa nó vào không giản `.rx`. Bạn hãy mở file `MKMapView+Rx.swift` và thêm đoạn code sau vào.

```swift
var regionDidChangeAnimated: ControlEvent<Bool> {
    let source = delegate
        .methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
        .map { parameters -> Bool in
            return (parameters[1] as? Bool) ?? false
        }
    return ControlEvent(events: source)
}
```

Việc báo cho ViewController biết sự thay đổi trong MapView thì nó cũng xem là một sự kiện từ MKMapView. Do đó, ta lựa chọn kiểu `ControlEvent` cho thuộc tính được Proxy Delegate nhận uỷ thác từ MKMapViewDelegate.

Xác định function chính là `regionDidChangeAnimated` để thực hiện việc `invoked`. Tuy nhiên, nó có 2 tham số và tham số `mapView` thì không cần lấy, nên sẽ lấy tham số `animated` với kiểu là Bool. Vì vậy, bạn chỉ cần thực hiện biến đổi với `map` và return `parameters[1]` về.

Cuối cùng, bạn tạo ra 1 Trait `ControlEvent` với event chính là `source`. 

#### React with Region changed

Tư tưởng của RxSwift và Reactive Programming là lập trình phản ứng. Từ một sự kiện được phát ra. Chúng sẽ kéo theo một loạt các thay đổi và giao diện sẽ tự động thay đổi. Về demo của chúng ta tại file **WeatherViewController** thì là kết hợp nhiều nguồn phát ra sự kiện. Rồi từ đó sẽ gọi API và xử lý dữ liệu. Do đó, việc còn lại của chúng ta chen vào thêm 1 nguồn phát ra sự kiện cho Observable `search` kia hoạt động. 

> Chúng ta bắt đầu tiếp nào!

**Bước 1:** Tạo input cho MapView với sự thay đổi của Region

Nó cũng giống như việc gõ chữ hay sự thay đổi về location của người dùng. Thì đây là một sự kiện của MapView, chúng ta sẽ biến nó thành một Observable. Bạn thêm một đoạn code vào function `viewDidLoad` của file **WeatherViewController**. Nhớ là trên các đoạn code tạo các search cho các sự kiện.

```swift
let mapInput = mapView.rx.regionDidChangeAnimated
    .map { [unowned self] _ in self.mapView.centerCoordinate }
```

Trong không gian `.rx` thì đã cài đặt thêm `regionDidChangeAnimated`. Nó sẽ biến đổi sự kiện thành Observable. Bạn thêm một xí nữa là biến đổi kiểu dữ liệu. Chúng ta cần toạ độ chính giữa bản đồ của mapView. Nên dùng toán tử `map` và return về `centerCoordinate`.

> Điều này thực thi được khi bạn `không` cần có setDelegate cho MapView là ViewController. Đó là ưu việt của Rx

Tuy nhiên, chúng sẽ là các pin mặc định. Muốn đẹp thì bạn phải cần có `delegate` và custom lại các pin theo ý đồ của mình.

**Bước 2:** Tạo search API với sự kiện của MapView

Bạn đã có sự kiện biến đổi thành Observable rồi. Tiếp theo, ta cần phải gọi API. Bạn thêm đoạn code sau vào:

```swift
let mapSearch = mapInput.flatMap { coordinate in
    return WeatherAPI.shared.currentWeather(at: coordinate)
            .catchErrorJustReturn(.dummy)
}
```

Chúng ta dùng chính `mapInput` ở trên. Tuy nhiên, lần này bạn phải biến đổi từ Observable này thành Observable khác. Do đó, toán tử cần sử dụng là `flatMap` và để đảm bảo nó thực hiện bất đồng bộ.

**Bước 3:* Merge Search API

Kết thúc bước 2, chúng ta lại có thêm một Observable Search nữa. Công việc giờ đơn giản hơn. Chỉ bao gồm là merge tất cả chúng nó lại với nhau. Bạn edit lại đoạn code tạo Observable `search`.

```swift
let search = Observable
    .merge(locationSearch, textSearch, mapSearch)
    .asDriver(onErrorJustReturn: .dummy)
```

Khá là EZ, khi chỉ cần thêm `mapSearch` vào cùng các anh chị em trước đó. Vẫn còn sót một cái nữa, đó là `loading`. Bạn tiếp tục edit lại đoạn code của `loading` như sau:

```swift
let loading = Observable.merge(
        searchInput.map { _ in true },
        locationInput.map { _ in true }, // update with search at Location
        mapInput.map { _ in true }, // update with search at MapView
        search.map { _ in false }.asObservable()
    )
    .startWith(true)
    .asDriver(onErrorJustReturn: false)
```

Chỉ cần thêm 1 dòng nữa là khi `mapInput` hoạt động thì sẽ phong ra 1 giá trị là `true`. Lúc đó loading view sẽ hiện ra. 

Tới đây thì mọi thứ xem như đã hoàn hảo rồi. Bạn hãy build lai project và thực hiện việc di chuyển map và xem kết quả. Với 2 điều kiện:

* Có setDelegate + custom PIN
* Không setDelegate & dùng PIN mặc định

---

Tới đây mình xin kết thúc bài viết dài này. Cũng là kết thúc chương `RxCocoa cơ bản`. Cảm ơn bạn đã đọc bài viết này!
