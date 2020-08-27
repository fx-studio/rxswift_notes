# 08.5 Working with Cache Data

À, phần này chúng ta giả lập việc lưu trữ dữ liệu nhận được (ở phần trước) vào một bộ nhớ đệm. Ngoài ra, chúng ta còn phải xử lý nhiều vấn đề kéo theo nữa liên quan tới các Observable và update UI.

> Lưu ý: bộ nhớ đệm ở đây là file `*.plist` thôi. Nhưng về bản chất thì cũng như các CoreData, Realm ... Trong phạm vi bài thì chúng ta chỉ giải quyết ý tưởng bằng các công cụ đơn giản nhất.

Để vào bài này thì bạn cần nắm được bài trước đó, vì đây là 2 phần liên tiếp với nhau. Nếu bạn đã đọc qua phần tương tác với API rồi thì ...

> Bắt đầu thôi!

### 1. Chuẩn bị

Tiếp tục với project ở phần trước. Sau đây là link và checkout cho các bạn lỡ quên

* **Link:** [checkout](../Examples/BasicRxSwift)
* **Thư mục:** `/Examples/BasicRxSwift`

Đơn giản như vậy thôi, ta tiến vào phần chính của bài nào

### 2. Save to Disk

Lưu trữ dữ liệu là việc đầu tiên cần làm. Trước khi vào phần code demo, việc này có ý nghĩa gì?

* Khi bạn request API và nhận được dữ liệu mới nhất
* Sau đó tiến hành update lên UI của ứng dụng
* Bên cạnh đó sẽ lưu lại các dữ liệu đó vào bộ nhớ local trong máy

Để khi mở lại ứng dụng hay vào lại màn hình đó. Trước khi việc request API thì giao diện chúng ta là trắng xoá. Và lúc này thì người dùng phải chờ cho tới lúc nhận được dữ liệu về.

> Nếu trường hợp mạng chậm thì coi như tèo. Ahuhu

Để đảm bảo tính liên tục trong ứng dụng thì trước khi request API chúng ta sẽ lấy dữ liệu lưu mới nhất từ bộ đệm và hiển thị chúng lên UI. Sau đó, có sự update nào từ response thì UI sẽ cập nhật lại lần nữa.

Quay về ứng dụng demo, vì dữ liệu chúng ta vẫn còn đơn giản lắm. Nên sử dụng `*.plist` để lưu trữ là OKE rồi. Các phần sau bạn sẽ học về `RxRealm`, khi đó tha hô mà sáng tạo.

#### Tạo đường dẫn để lưu trữ dữ liệu vào file

Bạn thêm function lấy đường dẫn tới 1 file trong Documents của app.

```swift
    static func cachedFileURL(_ fileName: String) -> URL {
        return FileManager.default
            .urls(for: .cachesDirectory, in: .allDomainsMask)
            .first!
            .appendingPathComponent(fileName)
    }
```

Nhìn qua là thấy khá đơn giản nhĩ. Phần này bạn tự tìm hiểu thêm nhé, Rx nó có quán nhiều extension mà chúng ta không biết. Chúng ta thêm một biến cho class nữa.

```swift
    private let musicsFileURL = cachedFileURL("musics.json")
```

Bạn chọn tên tuỳ ý nha. Chúng ta tiến sang function `loadAPI()` và tách phần handle `subcribe` ra riêng 1 function để dễ xử lý. Đặt tên là `processMusics`

```swift
    private func processMusics(newMusics: [Music]) {
        // update UI
        DispatchQueue.main.async {
            self.musics = newMusics
            self.tableView.reloadData()
        }
        
        
    }
```

Edit lại một tí ở subcribe

```swift
            .subscribe(onNext: { musics in
                self.processMusics(newMusics: musics)
            })
```

#### Lưu array items

Để lưu 1 Array Musics vào file thì công việc của bạn là biến đổi kiểu dữ liệu. Nếu bạn còn nhớ tới `Codable` thì trong đó còn 1 phần là `Encoder`. Nó ngược lại với `Decoder` . Và kiểu mong muốn biến đổi thành là JSON, nên sẽ dùng đối tượng `JSONEncoder`. 

Ta thêm đoạn code này vào function `processMusics`

* `encoder` là đối tượng dùng để chuyển đội dữ liệu thành JSON
* biến đổi array Music thành `Data` với đối tượng là `musicsData`
* `.write` dùng để lưu thành file với URL ở trên chúng ta đã tạo

```swift
        // save to file
        let encoder = JSONEncoder()
        if let musicsData = try? encoder.encode(newMusics) {
            try? musicsData.write(to: musicsFileURL, options: .atomicWrite)
        }
```

### 3. Read file 

Làm sao biết được dữ liệu chúng ta lưu có thành công hay không. Bạn quay về `viewDidLoad` và thử load lại dữ liệu đã lưu xem như thế nào nha. À, để cho chắc ăn thì bạn hãy build ứng dụng và chạy trước một lần.

```swift
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        //loadAPI()
        
        // read file
        let decoder = JSONDecoder()
        if let musicsData = try? Data(contentsOf: musicsFileURL),
           let preMusics = try? decoder.decode([Music].self, from: musicsData) {
            self.musics = preMusics
        }
    }
```

Tạm thời comment việc gọi API lại, thêm đoạn code đọc file vào

* Lần này chúng ta biến đổi ngược lại từ `Data` thành Array Music
* Data được đọc lên từ file với url đã cài đặt
* `preMusics` là biến cho dữ liệu biến đổi bằng JSONDecoder, vì ta biết kiểu dữ liệu chính của nó là JSON.
* Nếu mọi biến đều oke, thì ta xét giá trị cho `music` và reload Tableview

Build lên và cảm nhận kết quả!

### 4. Sử dụng Subject

Để cho OKE code của bạn hơn nữa và dùng vào các bài tập sau thì ta chuyển đổi thuộc tính `musics` từ Array Music thành một Subject

```swift
private var musics = BehaviorRelay<[Music]>(value: [])
```

Thay dòng code cũ bằng dòng mới ở trên. Còn cách dùng thì như thế nào

```swift
// add dữ liệu mới
self.musics.accept(newMusics)

// lấy item ra
let item = musics.value[indexPath.row]

// đếm số lượng item
musics.value.count
```

Quá EZ!

---

Tới đây thì mình xin kết thúc bài viết này. Hẹn bạn ở phần tiếp theo. Cảm ơn vì đã đọc!