# 08.4 Fetching Data from API

Vâng, làm việc với API là một trong những yêu cầu mà hầu như là bạn phải làm được. Có rất nhiều phần cần làm trong việc này. Mình sẽ lần lượt đi qua từng cái một.

Và bạn hoàn thành nó thì có thể tự tin làm app với RxSwift rồi. Nhưng trước tiên hãy chuẩn bị lần project nào. Tiếp tục sử dụng lại project trước đây. Dành cho bạn đã quên nó ở đâu rồi.

* **Link:** [checkout](../Examples/BasicRxSwift)
* **Thư mục:** `/Examples/BasicRxSwift`

### 1. Chuẩn bị

Màn hình của chúng ta đơn giản có 1 TableView với các cell để hiển thị item lấy được từ API. Tuỳ thuộc bạn sử dụng API nào, còn mình sẽ sử dụng API của itunes để lấy các bài hát mới nhất.

> Link: https://rss.itunes.apple.com/api/v1/us/itunes-music/new-music/all/100/explicit.json

Về thư viện

- URLSession
- RxSwift & RxCocoa

Và kiến thức cũng không cần quá nhiều với RxSwift. Chủ yếu là sự biến đổi qua lại giữa các dữ liệu nhận được. Cũng không đưa ra một giải pháp hoàn hảo cho bạn với việc tương tác API. 

Đâu tiên, bạn hay mở file `MusicListViewController`. Trong này mình có config cơ bản cho 1 UITableView. Bạn hãy chú ý tới function `loadAPI` , thì tại đó ta sẽ thực hiện công việc chính của mình. Còn về code của ViewController bắt đầu thì sẽ như thế này.

```swift
import UIKit
import RxSwift
import RxCocoa

class MusicListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
  
  	// MARK: - Properties
    private let urlMusic = "https://rss.itunes.apple.com/api/v1/us/itunes-music/new-music/all/100/explicit.json"
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        loadAPI()
    }
    
    // MARK: - Private Methods
    private func configUI() {
        title = "New Music"
        
        let nib = UINib(nibName: "MusicCell", bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func loadAPI() {
        
    }
    
}

extension MusicListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
```

Thực chất để cho bạn dễ hình dùng khi chúng ta dùng code demo để mô tả về lý thuyết và giải thích kiến thức mới này. 

Bên cạnh đó chúng ta cần define thêm dữ liệu của các item cho tableview cell. Ta đặt tên là `Music.swift` và dựa vào dữ liệu json của link trên ta khai báo các thuộc tính như sau

```swift
final class Music: Codable {
    var artistName: String
    var id: String
    var releaseDate: String
    var name: String
    var copyright: String
    var artworkUrl100: String
}
```

Chắc không có vấn đề gì khó ở đây nhĩ. Chúng ta qua phần tiếp theo nào

### 2. Create Request

Để lấy được dữ liệu thì bạn phải tạo được request tới server. Nhưng hiện tại bạn đang có là 1 link url để truy cập tới. Và bạn cũng biết được là chúng ta cần tạo ra được đối tượng `URLRequest`. Như vậy, công việc đầu tiên của chúng ta như sau:

> URL String > URL > URLRequest

Okay, bắt đầu thôi. Tại hàm `loadAPI()` chúng ta bắt đầu thêm dòng code đầu tiên như sau:

```swift
let observable = Observable<String>.of(urlMusic)
```

Bạn chỉ cần tạo ra 1 Observable với kiểu là `String` với toán tử `of` thì dữ liệu cung cấp chính là `urlMusic` ở trên.

```swift
let observable = Observable<String>.of(urlMusic)
            .map { urlString -> URL in
                return URL(string: urlString)!
            }
```

Bước biến đổi thứ 1 là thành `URL` với việc dùng toán tử `map`. Cái này được handle bằng 1 closure và chỉ cần return đúng về kiểu dữ liệu mà mình mong muốn là URL.

```swift
let observable = Observable<String>.of(urlMusic)
            .map { urlString -> URL in
                return URL(string: urlString)!
            }
            .map { url -> URLRequest in
                return URLRequest(url: url)
            }
```

Áp dụng tiếp `map` thì bạn biến đổi lần 2, lúc này sẽ thành là `URLRequest`. Quá EZ phải không nào, từ 2 dòng lệnh chúng ta đã có được đối tượng cần thiết rồi.

### 3. Wait for Response

Đã có request rồi thì việc tiếp theo nữa là nhận response. Bạn tiếp tục với đoạn code trên và thêm toán tử `flatMap` này vào

```swift
.flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }
```

Với `flatMap`

* Không những giúp cho việc biến đổi dữ liệu mà còn biến đổi luôn của Observable này thành Observable khác
* Nó phù hợp với các tương tác bất đồng bộ (vì 2 bước biến đổi trên vẫn toàn là đồng bộ)
* Nó sẽ chờ phản hồi đầy đủ từ server trả về. Sau đó sẽ thực thi các đoạn code tiếp theo

Với `URLSession`

* Bạn đang dùng các thuộc tính mới được thêm vào từ `RxCocoa`
* `share.rx` sẽ gọi toán tử `response` với tham số là `request` từ trên
* Kết quả trả về là 1Observable với kiểu giá trị của phần tử bao gồm `HTTPURLResponse` và `Data` cho body

Cuối cùng bạn thêm dòng code này vào

```swift
.share(replay: 1)
```

Để cho phép có nhiều subscription tới Observable đó và kết quả sẽ được lưu lại ở bộ đệm. Khi đó đảm bảo sẽ có được dữ liệu cho các Subcriber.

### 4. `share()` vs. `share(replay1)`

Update thêm kiến thức mới nha. À nó cũng hữu ý trong phạm vi bài này đó.

Đầu tiên thì khi bạn sử dụng `URLSession.rx.response(request:)`, tức là bạn gởi yêu cầu tới máy chủ. Khi nhận được phản hồi trở lại. Thì Observable sẽ `emit` ra duy nhất một phần tử và kết thúc.

Mọi thứ sẽ không có vấn đề gì, nếu bạn tiếp tục `subscribe` lần thứ 2, lần 2 ... lần n. Thì mọi công việc sẽ bắt đầu chạy lại từ đầu.

Để tránh việc làm tốn tài nguyên và công sức như thế này thì sử dụng toán tử `share(replay:scope)`. Toán tử sẽ giữ lại phần tử cuối cùng trong bộ đệm. Cứ như vậy, các subscriber tiếp theo khi đăng kí tới thì sẽ nhận được dữ liệu ngay lập tức và không cần phải thực hiện lại đám lệnh ở trên.

Về `scopes` thì bạn có 2 lựa chọn

* `.forever` bộ đệm sẽ lưu lại mãi mãi. Chờ người đăng ký mới
* `.whileConnected` bộ đệm sẽ giữ lại cho đến khi không còn người nào đăng kí tới và loại bỏ sau đó. Các đăng ký tiếp theo thì sẽ load lại từ đầu

Tuỳ thuộc vào ý độ bạn muốn sử dụng việc load API đó ra sao mà có cách dùng phù hợp. OKE, hết thời gian phụ đạo.

### 5. Parse Data

Giờ tới phần phân tích dữ liệu nhận được từ server. Bạn cũng biết response không phải lúc nào cũng thành công. Do đó, trước tiên chúng ta phải lọc đi các trường hợp không thành công khi tương tác với API

```swift
observable
            .filter { response, _ -> Bool in
                return 200..<300 ~= response.statusCode
            }
```

Bạn hãy enter một dòng code mới và bắt bâuf bằng toán tử `filter`. Các `statusCode` từ 200~299 là thành công. Về các trường hợp lỗi thì chúng ta hãy phân tích tại một bài khác.

Tiếp tục, là phần parse data chính. Ta có đoạn code tiếp tục như sau với toán tử `map`

```swift
.map { _, data -> [Music] in
                
            }
```

`map` là toán tử huyền thoại dùng để biến đổi kiểu dữ liệu. Trong bài toán này, chúng ta biến đổi `(HTTPURLResponse, Data)` thành `Array Music`. Để trước khi biến đổi thì bạn hãy xem lại cấu trúc JSON của API là như thế nào. Từ đó chúng ta sẽ đưa ra cấu trúc dữ liệu phù hợp.

Bạn mở file `Music.swift` và thêm khai báo này vào

```swift
final class Music: Codable {
    var artistName: String
    var id: String
    var releaseDate: String
    var name: String
    var copyright: String
    var artworkUrl100: String
}

struct MusicResults: Codable {
  var results: [Music]
}

struct FeedResults: Codable {
  var feed: MusicResults
}
```

Ta có:

* `FeedResults` là đại diện cho cấu trúc lớn nhất, nó có 1 key là `feed`
* `MusicResults` là kiểu dữ liệu cho key `results` , nó nằm trong `feed`. Nếu bạn muốn parse gì thêm trong cấu trúc này thì thêm vào
* `Music` là đại diện kiểu dữ liệu cho từng item của mãng `results`

Tất cả để kế thừa protocol `Codable`, nếu bạn chưa biết chúng là gì thì nó đơn giản giúp cho bạn chuyển đổi kiểu dữ liệu một cách dễ dàng, thông qua các đối tượng Encoder hay Decoder

> Codable = Encoder + Decoder

Quay lại file `MusicListViewController`, chúng ta hoàn thành công việc phân tích dữ liệu từ server trả về

```swift
.map { _, data -> [Music] in
                let decoder = JSONDecoder()
                let results = try? decoder.decode(FeedResults.self, from: data)
                return results?.feed.results ?? []
            }
```

Ta đã biết dữ liệu nhận được từ server là JSON, nên sẽ dùng `JSONDecoder` để biến đổi `data` thành `FeedResults`. Từ đó chúng ta sẽ return về Array Music là dữ liệu của Tableview.

Cuối cùng, nếu trường hợp bị lỗi thì chúng ta sẽ lọc tiếp.

```swift
.filter { objects in
                return !objects.isEmpty
            }
```

### 6. Subscribe & Update UI

Công việc cuối cùng chính `subscribe` tới Observable. Vì khi có kết nối thì chúng mới hoạt động và sẽ nhận được dữ liệu từ server. Ta tiếp tục với việc subcriber nào

```swift
.subscribe(onNext: { musics in
                DispatchQueue.main.async {
                    self.musics = musics
                    self.tableView.reloadData()
                }
            })
            .disposed(by: bag)
```

Trong closure `onNext` là phần code bạn handle. Với dữ liệu nhận được là một mãng Music và `reload` Tableview nên cần phải thực hiện chúng ở Main Thread. Do công việc gọi API luôn chạy ở thread khác. Nếu không update UI tại Main Thread thì sẽ crash chương trình.

Nhớ khai báo thêm túi rác quốc dân và array dữ liệu cho tableview nha

```swift
    private let bag = DisposeBag()

    private var musics: [Music] = []
```

Cập nhật lại dữ liệu cho các protocol của TableView nào

```swift
extension MusicListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        musics.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MusicCell
        
        let item = musics[indexPath.row]
        cell.nameLabel.text = item.name
        cell.artistNameLabel.text = item.artistName
        cell.thumbnailImageView.kf.setImage(with: URL(string: item.artworkUrl100)!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
```

Bạn hãy build lại ứng dụng và tận hưởng kết quả nào! Còn lại tới đây mình xin hết thúc bài viết này.

---

### Tóm tắt

Với RxSwift thì chúng ta có thể tương tác với API một cách đơn giản nhất. Rất nhanh và hiệu quả. Bạn có thể xem lại toàn bộ code như sau

```swift
    private func loadAPI() {
    		// create Observable
        let response = Observable<String>.of(urlMusic)
            .map { urlString -> URL in
                return URL(string: urlString)!
            }
            .map { url -> URLRequest in
                return URLRequest(url: url)
            }
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }
            .share(replay: 1)
        
        // parse data
        response
            .filter { response, _ -> Bool in
                return 200..<300 ~= response.statusCode
            }
            .map { _, data -> [Music] in
                let decoder = JSONDecoder()
                let results = try? decoder.decode(FeedResults.self, from: data)
                return results?.feed.results ?? []
            }
            .filter { objects in
                return !objects.isEmpty
            }
            // update UI
            .subscribe(onNext: { musics in
                DispatchQueue.main.async {
                    self.musics = musics
                    self.tableView.reloadData()
                }
            })
            .disposed(by: bag)
        
    }
```

Cảm ơn bạn đã đọc bài viết này & hẹn gặp lại ở bài tiếp theo!