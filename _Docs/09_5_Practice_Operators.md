# 09.5 Practice Operators

Phần này đơn giả là luyện tập với các Operators đã được học mà thôi. Không có gì căng thẳng hết. Các phần được trình bày dưới dạng liệt kê.

### 1. Share Subscription

Khi có 1 Observable thì bạn có thể đăng kí tới `subscribe` từ bất kì đâu. Điều này là tạo ra nhiều `subscription`. Và bạn có dám chắc chắn là Observable của bạn đồng nhất việc `emit` data tới tất cả các subscriber. Hoặc các subcriber có đảm bảo nhận được giống nhau về mặt dữ liệu hay không?

Trường hợp này rất có khả năng xảy ra, khi chúng ta có làm gì đó biến đổi nguồn phát (Observable). Và để đảm bảo tính đồng nhất này đối với Observable thì ta có 1 toán tử là `share`.

```swift
let newPhotos = photosViewController.selectedPhotos .share()
newPhotos
[ here the existing code continues: .subscribe(...) ]
```

Ví dụ cho cách dùng trên, với `share()` thì

* Các subscriber đăng ký tới thì sẽ tương tác cùng 1 Observble
* `share` không phát lại các phần tử trước đó cho các subscriber đăng ký sau (khác `replay`)
* Các event từ Observable thì share() đảm bảo nó truyền tải đúng như vậy tới các subscriber
* An toàn khi sử dụng

### 2. Các công việc liên quan tới filter

* Loại bỏ tất cả các phần tử, chỉ lấy `completed` hoặc `error`. Dùng cho các trường hợp lấy sự kiện mà thôi
  * `ignoreElements`
* Loại bỏ các phần tử không cần thiết
  * `filter(_:)`
* Sử dụng các yêu cầu lọc cơ bản
  * `filter(_:)`
* Sử dụng trong một điều kiện cụ thể
  * `takeWhile()`

### 3. Cách tạo các Observable riêng

Đi đâu thì cũng phải sài cách này, dùng trong các trường hợp cần custom lại hoặc handle các sự kiện của các class đã có.

Ví dụ cho việc lấy quyền truy cập của Photo

```swift
extension PHPhotoLibrary {
  	static var authorized: Observable<Bool> {
			return Observable.create { observer in
        // handle logic
				return Disposables.create() 
    		}
		}
}
```

Tuy nhiên có nhiều công việc liên quan tới Custom Observable riêng nữa, vì có nhiều trường hợp xãy ra, chứ không đơn thuần theo 1 chiều/

* Tạo Observable, xác định kiểu Observable và kiểu data
  * Có thể dùng `traits` nếu các trường hợp riêng lẻ
* Dùng toán tử `create` và return về một `Disposables`
* Handle logic cho `observer` trong đó
* `subcribe` thì chú ý các điều kiện lọc (ở trên kia)
* Chú ý tới thread hay queue mà hình đã `onNext` và `subcribe`. Nếu ko thì dễ crash ứng dụng khi có xử lý liên quan tới UI
* Loại bỏ những phần tử ở nhiều trường hợp mà có thể giống nhau
  * `skip(_:)`
  * các phần tử đặc biệt `take`, `takeLast` ....
* Nếu không cản nỗi lỗi thì hãy `handle error`

### 4. Xử lý về thời gian

* Lấy phần tử trong một khoản thời gian nào đó. Hoặc dùng để hẹn giờ cho 1 tác vụ nào đó
  * `take(_:scheduler:) `
* Nếu có nhiều sự kiện diễn ra liên tục và có nhiều dữ liệu cần xử lý thì nên bó nó lại bằng
  * `throttle(_:scheduler:) `



