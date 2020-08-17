# 08.2 Talking to other ViewController

Vâng, chúng ta đã sử dụng được rất rất là cơ bản RxSwift trong một UIViewController rồi. Với 2 vấn đề đã được giải quyết là:

- Update dữ liệu lên UI Control
- Xử lý sự kiện người dùng

Bài toán của chúng ta tiếp tục với việc tương tác với một ViewController khác. Giờ project chúng ta đã có 2 ViewController. Nhiệm vụ quan trọng trong bài này chính là:

> Truyền dữ liệu.

### Chuẩn bị

Vẫn tiếp tục với project lần trước. Dành cho bạn quên nó ở đâu thì truy cập vào đây:

* **Link:** [checkout](../Examples/BasicRxSwift)
* **Thư mục:** `/Examples/BasicRxSwift`

Nhưng lần này chúng ta có thêm 1 ViewController nữa để phục vụ cho việc lựa chọn Avatar của User lúc đăng kí. Nó có tên là `ChangeAvatarViewController`. Nó bao gồm:

* 1 CollectionView với cell hiển thị ảnh
* Select vào mỗi cell sẽ chọn ảnh

Ta edit lại một chút chỗ function `changeAvatar` ở **RegisterViewController** để hiển thị được **ChangeAvatartViewController** khi người dùng nhấn vào

```swift
    @objc func changeAvatar() {
        let vc = ChangeAvatarViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
```

Okay! xong phần dạo đầu. Chúng ta tiến vào phần chính

### Setup

Tất nhiên công việc đầu tiên là cài đặt cho `ChangeAvatarViewController` cũng có được khả năng RxSwift. Mở file VC đó lên và import vào:

```swift
import RxSwift
import RxCocoa
```

2 thư viện hàng đầu của chúng ta. Giờ thêm tiếp túi rác quốc dân vào nữa.

```swift
private let bag = DisposeBag()
```

Có thể chúng ta không sai, nhưng để cho chắc thì bạn hãy thêm nó vào, tập thành thói quen sau này. Tiếp tục với phần thêm các properties là các Observable nào.

```swift
    private let selectedPhotosSubject = PublishSubject<UIImage>()

    var selectedPhotos: Observable<UIImage> {
        return selectedPhotosSubject.asObservable()
    }
```

Ta thấy có tới 2 Observable

* `selectedPhotosSubject` là một Subject, nó sẽ `emit` dữ liệu và không cần thiết phải khai báo thêm giá trị ban đầu cho nó. Vì đơn giản, lúc hiển thị lên thì người dùng chưa có sự lựa chọn nào hết. Quan trọng nhất là nó `private`
* `selectedPhotos` đây là phát ngôn viên của VC. Để bên ngoài có thể `subscribe` tới. Thực chất là việc biến đổi `subject` kia thành 1 `observable` 

Và cả 2 đều có kiểu dữ liệu Output khi `emit` là `UIImage`.

### Emit data

Sau khi đã cài đặt các Observable thì công việc tiếp theo là `phát dữ liệu đi`. Lúc này, chúng ta không quan tâm là dữ liệu phát đi thì ai sẽ nhận được. 

Với **collectionview** thì tại delegate của nó chúng ta sẽ bắt được sự kiện người dùng chọn vào cell. Từ đó tiến hành `emit` dữ liệu

```swift
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectIndex = indexPath.row
        collectionView.reloadData()
        
        //emit UIImage
        if let image = UIImage(named: "avatar_\(indexPath.row + 1)") {
            selectedPhotosSubject.onNext(image)
        }
    }
```

Toán tử `.onNext` khi được subjecrt thực thi thì dữ liệu truyền vào đó sẽ được gởi đi. Chỉ có vậy thôi, coi như chúng ta đã xong phần của **ChangeAvatarViewController** rồi.

### Observing Observavles

Đã có bên phát đi thì đối nghịch nó là bên nhận. Chúng ta lại quay về RegisterViewController để làm công việc này.

> Nhận dữ liệu từ ViewController khác.

Tại function `changeAvatar`, tiến hành `subscribe` tới các Observable của ChangeAvatarViewController. Ta thêm đoạn code này vào

```swift
    @objc func changeAvatar() {
        let vc = ChangeAvatarViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
        //subscribe
        vc.selectedPhotos
            .subscribe(onNext: { img in
                self.image.accept(img)
            }, onDisposed: {
                print("Complete changed Avatar")
            })
        .disposed(by: bag)
    }
```

Trong đó

* `.selectedPhotos` là đối tượng Observable mà chúng ta đã tạo bên VC kia, là phát ngôn viên của nó
* `subscribe` để nhận dữ liệu từ VC kia phát ra
* `.onNext` handle việc nhận dữ liệu. Từ đó, chúng ta dùng `BehaviorRelay` để `accept` dữ liệu mới lên UI của VC bên này
* `.onDispose` để xem việc đăng kí này có kết thúc hay là không. Điều này rất quan trọng

Giờ bạn có thể build app và test lại mọi thứ đã hoạt động nhịp nhàn hay chưa.

### Disposing subscriptions

Nếu bạn để ý kĩ thì đoạn code này tại function `changeAvatar` ở **RegisterViewController** thì không bao giờ chạy.

```swift
onDisposed: {
                print("Complete changed Avatar")
            }
```

> Đây thực sự là rất nguy hiểm.

Nguyên nhân vì sao

* Khi bạn đăng ký tới 1 observable và nén nó 1 `disposeBag` , khi đó subscription đó sẽ được lưu giữ lại tại `disposeBag`
* Subscription sẽ giải phóng khi nào `disposeBag` giải phóng
* Tuy nhiên, **RegisterViewController** là rootView của ứng dụng lúc này. Có nghĩa là nó tồn tại vĩnh viễn với thời gian

--> Các subscription khi chúng ta đăng ký tới vẫn còn. Bộ nhớ vẫn bị chiếm giữ. Mà chúng ta không làm gì được hết ở đây.

Cách giải quyết sẽ là

> Nếu `disposeBag` không tự kết liễu thì sẽ cho kết thúc `observable`.

Vâng, quay lại **ChangeAvatarViewController**, thêm function này vào

```swift
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        selectedPhotosSubject.onCompleted()
    }
```

Với toán tử `.onCompleted()` thì subject sẽ kết thúc. Và không bao giờ phát ra nữa. Đồng nghĩa với các đăng ký từ các subscriber tới nó cũng bị huỷ.

Test lại app thì chúng ta đã thấy xuất hiện dòng `print` ở onDispose rồi. Và tới đây thì cũng kết thúc bày này. 

Chúc bạn vui vẻ!

---

### Tóm tắt

* Mục đích bài này là truyền dữ liệu qua lại giữa 2 ViewController
* Dễ hiểu hơn là viết lại `delegate` bằng RxSwift một cách đơn giản hơn và không cần quan tâm việc tạo các protocol và implement các function đó.