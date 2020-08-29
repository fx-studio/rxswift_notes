# 08.6 Networking

Chúng ta lại tiếp nối việc sử dụng RxSwift trong UIKit với các xử lý liên quan tới API và tương tác từ phía app. Phần này sẽ là phần nâng cao của phần `Fetching Data from API`. Vì đơn giản, tất cả mọi người hầu hết 100% đều không code chay một code xử lý trong 1 file ViewController rồi.

Nên công việc của chúng ta khác là vất vả, bao gồm:

* Thiết kế cấu trúc dữ liệu cho các Model
* Thiết kế Model tương tác với API (tạm gọi là Networking)
* Xử lý việc `request` cơ bản
* Update giao diện với dữ liệu từ API
* Gọi nhiều API cùng một lúc
* Xử lý dữ liệu của các API trả về

Và để cho bài viết dễ đi vào lòng người thì cũng yêu cầu bạn phải đọc qua về **Fetching Data from API** trước. Cũng như có kiến thức cơ bản về RxSwift. Tất nhiên bài viết này vẫn ở phạm tru là `siêu cơ bản` mà thôi.

Nếu không còn gì vướng bận cuộc đời này nữa thì ...

> Bắt đầu thôi!

### Chuẩn bị

Vẫn là project trước đây để bạn sử dụng làm demo, tiết kiệm việc cài đặt thư viện RxSwift. Link và thư mục checkout cho bạn nếu quên.

* **Link:** [checkout](../Examples/BasicRxSwift)
* **Thư mục:** `/Examples/BasicRxSwift`

Về API, sử dụng các API đơn giản của trang [The Cocktail DB](https://www.thecocktaildb.com/api.php). Tạm thời chúng ta sử dụng 2 api sau:

* Cocktail Categories: https://www.thecocktaildb.com/api/json/v1/1/list.php?c=list
* Drinks List: https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Cocktail

Về Project, thì bạn thêm 2 màn hình với 2 file ViewController cho 2 danh sách trên. Chúng ta chỉ cần sử dụng UITableView cơ bản là được. Không cần màu mè quá.

### 1. Create Entities models

Dựa vào 2 API trên với cấu trúc JSON trả về thì bạn cần tạo các file Model để mô tả cấu trúc dữ liệu cho chúng. 

Với **Cocktail Categories** thì tạo một file `CocktailCategory.swift` , bạn tham khảo cấu trúc sau

```swift
struct CocktailCategory: Codable {
    var strCategory: String
    var items = [Drink]()
    
    private enum CodingKeys: String, CodingKey {
      case strCategory
    }
}
```

Giải thích:

* `Codable` để cho phải có thể chuyển đổi kiểu dữ liệu một cách nhanh chóng. Nhưng bắc buộc tất cả các properties trong đó cũng phải là `Codable` 
* `items` là một property mình thêm vào, không có trong JSON nên khi `decode` thì sẽ bị lỗi, vì vậy bạn cần có thêm `CodingKeys`
* Với `CodingKeys` thì các `case` sẽ chỉ định việc `map` dữ liệu từ JSON sáng `CocktailCategory`

> Đây là cấu trúc dữ liệu đại diện cho 1 item trong JSON lấy được từ API. Nó không phải là toàn bộ cấu trúc JSON

Để chuẩn bị cho tương lai, vì ngoài Cocktail thì bạn có thể có rất nhiều loại khác nên chúng ta sẽ chuẩn bị tiếp cấu trúc cho toàn bộ JSON của api này

```swift
struct CategoryResult<T: Codable> : Codable {
    var drinks: [T]
}
```

Sử dụng `Generic` cho khoẻ, sau này chỉ cần ráp các kiểu khác vào thôi. Còn `drinks` là key của mãng items cần phải `decode`.

Với **Drink List**, thì ta cũng áp dụng tương tự. Bạn tạo một file là `Drink.swift` và thêm đoạn code sau vào

```swift
struct Drink: Codable {
    var strDrink: String
    var strDrinkThumb: String
    var idDrink: String
}

struct DrinkResult {
    var drinks: [Drink]
}
```

Cũng không có gì mới, nhưng mà `DrinkResult` thì mình sẽ không dùng tới trong demo lần này. Thêm vào cho có hoa lá cành .... cho đẹp mà thôi.

### 2. Create Networking model

Sang phần tiếp theo thì chúng ta cần tạo thêm các file cho Model này. Nó sẽ bao gồm 3 file chính hoặc có thể là 3 phần chính cũng được. Tuỳ thuộc bạn muốn dùng như thế nào là hợp lý với bạn mà thôi. Tham khảo như sau:

* **Networking** : chứa phần tương tác chính và xử lý tương tác API
* **Error** : định nghĩa các `error` trong cả quá trình tương tác API
* **Results** : tạo ra một xử lý biến đổi dữ liệu là `Data` từ API, thành các đối tượng như ta mong muốn. Thông qua `JSONDecoder`.

Bắt đầu với Error nào, vì nó dễ nhất. Bạn tạo 1 file `NetworkingError.swift` và thêm đoạn code sau vào

```swift
enum NetworkingError: Error {
  case invalidURL(String)
  case invalidParameter(String, Any)
  case invalidJSON(String)
  case invalidDecoderConfiguration
}
```

Đó là các `case` mình định nghĩa ra, bạn muốn thêm các case riêng thì vẫn oke. Ngoài ra, nếu muốn xử lý show các text cho từng lỗi thì vẫn được. EZ!

Tiếp tục, với Result. Bạn cũng tạo 1 file `NetworkingResult.swift` và thêm đoạn code khai báo này vào

```swift
extension CodingUserInfoKey {
  static let contentIdentifier = CodingUserInfoKey(rawValue: "contentIdentifier")!
}

struct NetworkingResult<Content: Decodable>: Decodable {
  
  let content: Content
  
  private struct CodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int? = nil
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = 0
    }
    
    init?(intValue: Int) {
      return nil
    }
  }
  
  init(from decoder: Decoder) throws {
    guard let ci = decoder.userInfo[CodingUserInfoKey.contentIdentifier],
          let contentIdentifier = ci as? String,
          let key = CodingKeys(stringValue: contentIdentifier) else {
      throw NetworkingError.invalidDecoderConfiguration
    }
    
    do {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        content = try container.decode(Content.self, forKey: key)
        print(content)
    } catch {
        print(error.localizedDescription)
        throw error
    }
  }
}
```

Nó bao gồm 2 phần chính

* Extension của `CodingUserInfoKey`, nó sẽ dùng là `userInfor` khi bạn `decode`. Để việc decode chính xác hơn.
* `NetworkingResult` với một Generic là `Content`. Chính là kiểu dữ liệu bạn muốn chuyển đổi về.

Struct còn có việc kế thừa và thêm hàm `init` từ Decoder. Trong đó vẫn quan trong nhất là việc lấy `contentIdentifier` từ đối tượng `decoder`. Nó sẽ dùng là nội dung cho `CodingKeys`. Sau đó, việc map dữ liệu sẽ duyệt theo key đó và lấy đúng các dữ liệu mà mình mong muốn.

Phần này hơi khó hiểu, nếu hiểu được thì okay. Còn không thì bạn có thể skip hoặc tưởng tượng như thế này. Ta có JSON như sau

```json
{
		"đây là key nè" : [
				{
					// JSON cho item với kiểu là A
				},
				{
					// JSON cho item với kiểu là A
				},
				{
					// JSON cho item với kiểu là A
				},
				{
					// JSON cho item với kiểu là A
				},
				....
		]
}
```

Bạn sẽ thấy là `đây là key nè` chính là key cho 1 mãng items với kiểu là `Array A`. Khi đó

* Content là `[A]`
* contentIdentifier là `đây là key nè`

Cuối cùng, trong phần này là cấu trúc cho Model quan trọng nhất. Bạn tạo một file là `Networking.swift` với cấu trúc như sau:

```swift
import Foundation
import RxSwift

final class Networking {
    
    // MARK: - Endpoint
    enum EndPoint {
        static let baseURL: URL? = URL(string: "https://www.thecocktaildb.com/api/json/v1/1/")
        
        case categories
        case drinks
        
        var url: URL? {
            switch self {
            case .categories:
                return EndPoint.baseURL?.appendingPathComponent("list.php")
                
            case .drinks:
                return EndPoint.baseURL?.appendingPathComponent("filter.php")
            }
        }
    }
    
    // MARK: - Singleton
    private static var sharedNetworking: Networking = {
        let networking = Networking()
        return networking
    }()
    
    class func shared() -> Networking {
        return sharedNetworking
    }
    
    private init() { }
    
    // MARK: - Properties
    
    // MARK: - Process methods
    static func jsonDecoder(contentIdentifier: String) -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.userInfo[.contentIdentifier] = contentIdentifier
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    // MARK: - Request
    
    
    // MARK: - Business
}

```

Nó chia ra các thành phần chính như sau:

* `Endpoint` dùng để define các link url mà bạn sử dụng. Trong demo thì chúng ta dùng 2 link nên sẽ có 2 case. Và một biến `url` để tiện biến đổi String thành URL nhanh hơn và tập trung hơn
* `Singleton` dùng để gọi API nhanh, giúp cho các thanh niên lười code pro hơn
* Các phần `Properties` và `Process methods` thì khai báo các đối tượng cần thiết và biến đổi dữ liệu cũng như xử lý logic
* `Request` là xử lý việc kết nối. Nó là chung nhất, không theo bất kì API nào.
* `Business` là phần bọc các request lại. Tại đây các tham số và enpoint sẽ phù hợp với từng API.

OKAY! phần chuẩn bị xem như là hoàn tất. Tiếp theo là phần xử lý request.

### 3. Request

Tại phần `Request` trong Networking. Bạn thêm function sau vào

```swift
func request<T: Codable>(url: URL?, query: [String: Any] = [:], contentIdentifier: String = "") -> Observable<T> {
	// ....
}
```

Các tham số cho hàm là cơ bản. Chú ý tới 2 điểm sau:

* `T` là kiểu Generic bất kì và yêu cầu là `Codable` dùng để parse data thành nó
* Return về là 1 Observable với kiểu dữ liệu cho phần tử là `T`
* `contentIdentifier` có thể dùng hoặc không, tuỳ theo ý bạn

Bạn tiếp tục vào trong function `request` và thêm đoạn code sau vào

```swift
    do {
     
            // code ở đây nha
      
            } catch {
                print(error.localizedDescription)
                return Observable.empty()
            }
        }
```

Bắt đầu với đoạn `do ... catch`. Nó dùng để để bắt lỗi trong quán trình xử lý. Vì rất nhiều chỗ có thể sinh ra lỗi. Trong, phạm vi bài viết thì t không handle error (để dành phần sau). Nếu có lỗi thì return là `empty()`. Tức không có gì.

Giờ vào trong phần `do` thêm đoạn code sau vào

```swift
            guard let URL = url,
                var components = URLComponents(url: URL, resolvingAgainstBaseURL: true) else {
                    throw NetworkingError.invalidURL(url?.absoluteString ?? "n/a")
            }
```

Nó sẽ kiểm tra các tham số `url` oke không. Và tạo thêm biến `components` để tiện xử lý thêm các param. Nếu thất bại thì sẽ `throw` error. Bạn có thể tuỳ ý với việc handle riêng theo ý bạn. Tiếp tục nào!

```swift
          components.queryItems = try query.compactMap { (key, value) in
                guard let v = value as? CustomStringConvertible else {
                    throw NetworkingError.invalidParameter(key, value)
                }
                return URLQueryItem(name: key, value: v.description)
            }
```

Sử dụng `components` để thêm các tham số lấy từ `query` vào `link url`. Thành kiểu `...?key1=value1&key2=value2`. Nó cũng giúp bạn hạn chế việc nhầm lẫn khi thêm hoặc nối bằng tay. 

> Cái này là cho xử lý API với method là `GET` nha. Nó liên quan nhiều tới query string của url link.

Tiếp tục, với việc lấy ra cái url cuối cùng sau khi thêm các param vào.

```swift
           guard let finalURL = components.url else {
                throw NetworkingError.invalidURL(url?.absoluteString ?? "n/a")
            }
```

Việc tiếp theo là bạn tạo `URLRequest` với `finalURL` trên.

```swift
            let request = URLRequest(url: finalURL)
```

> Muốn thêm header hay body request thì bạn có thể tử thêm vào. Trong các link api demo thì không cần thiết.

Giờ là phần cuối cùng. Dùng RxSwift để connect và nhận response trả về. Bạn thêm đoạn code này vào tiếp nha.

```swift
            return URLSession.shared.rx.response(request: request)
                .map { (result: (response: HTTPURLResponse, data: Data)) -> T in
                    
                    let decoder = JSONDecoder()
                    return try! decoder.decode(T.self, from: result.data)
            }
```

Về `URLSession.shared.rx.response` thì mình đã giải thích ở bài trước rồi. Còn về parse dữ liệu thì khá đơn giản. Dùng `JSONDecoder` để biến đổi `Data` về kiểu `T` thôi.

> `contentIdentifier` chúng ta sẽ bàn luận sau.

Tới đây là bạn đã có 1 file Model xịn xò với RxSwift để tương tác với API rồi. Sang phần Connect nào.

### 4. Connect API

Ta đã có phần xử rồi. Giờ với từng API thì chúng ta sẽ có các phần xử lý khác nhau. Bắt đầu với API lấy Cocktail Category nào. Tại file `Networing` phần `Business` bạn thêm 1 function sau

```swift
func getCategories(kind: String) -> Observable<[CocktailCategory]> {
    let query: [String: Any] = [kind : "list"]
    let url = EndPoint.categories.url
    
    let rq: Observable<CategoryResult<CocktailCategory>> = request(url: url, query: query)
    
    return rq
        .map { $0.drinks }
        .catchErrorJustReturn([])
        .share(replay: 1, scope: .forever)

}
```

Giải thích:

* `Observable<[CocktailCategory]>` là kiểu giá trị trả về của hàm. Bạn nên nhớ element của Observable này là 1 mãng `CocktailCategory` chứ không phải từng Category riêng lẻ.
* `query` và `url` theo đúng link của API
* `rq` là một Observable có được do gọi hàm `request` vừa viết ở trên. Ta có kiểu Generic cung cấp cho hàm `request` là `CategoryResult<CocktailCategory>`. Phần này, bạn cần phải cực kì cẩn thận. Chỉ nhầm kiểu dữ liệu một phát là sẽ không `decode` được
* Vì mãng Cocktail Category nó nằm trong thuộc tính `drink` của CategoryResult. Dó đó để lấy được chính xác thì bạn cần phải dùng toán tử `map`
* `.catchErrorJustReturn([])` tạm thời không quan tâm tới error. Và nếu có error thì trả về mãng rỗng
* `.share(replay: 1, scope: .forever)` phần này mình đã đề cập trong phần `Cache`. Nó giúp lưu trữ lại dữ liệu đã được xử lý qua kết nối. Các subscription tiếp theo chỉ cần trỏ tới và lấy, chứ không gọi request lại từ đầu

> Bạn yên tâm là việc kết nối API sẽ thực hiện khi có subscription tới mà thôi. Còn không thì mọi thứ vẫn nào chờ đó đợi bạn.

### 5. Update UI

OKAY, phần này khá là vất vả nhĩ. Nếu ổn rồi bạn sang phần giao thôi. Bạn mở file `CocktailViewController.swift`, nó có 1 UITableView đơn giản với các cell mặc định.

Thêm 2 thư viện `RxSwift` & `RxCocoa` vào file và khai báo thêm 2 properties sau

```swift
private let bag = DisposeBag()

private let categories = BehaviorRelay<[CocktailCategory]>(value: [])
```

Trong đó:

* `bag` là túi rác quốc dân, lưu trữ các subscription lại, sẽ tự giải phóng mình và các subscription khi ViewController giải phóng
* `categories` là một `Relay`. Nó sẽ được khởi tạo bằng 1 giá trị là mãng rỗng. Và khi có bất cứ dữ liệu nào thì nó sẽ phát lại cho các subscriber tới nó. Đảm bảo các kết nối đều có dữ liệu. Quan trọng là nó dùng vừa như là 1 biến, vừa như là 1 Observable.

> `BehaviorRelay` là thay thế cho `Variable` trong version trước của RxSwift

Sử dụng như thế nào trong ViewController, bạn tham khảo qua cách dùng `Relay` đó cho các protocol của TableView sau:

```swift
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    categories.value.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    
    let item = categories.value[indexPath.row]
    cell.textLabel?.text = "\(item.strCategory) - \(item.items.count) items"
    
    return cell
}
```

Quan tâm tới `.value` của `Relay` là oke hết thôi. Và ta viết thêm một hàm cho ViewController với tên là `loadAPI` như sau:

```swift
private func loadAPI() {
    let newCategories = Networking.shared().getCategories(kind: "c")
    
    newCategories
        .bind(to: categories)
        .disposed(by: bag)
}
```

Bạn chưa cần hiểu về `bind` là gì. Đơn giản là nó đưa dữ liệu trực tiếp lên biến `Relay` ta vừa khai báo. Kết nối chung với nhau. Công việc chỉ hoàn thành khi bạn thực hiện `subscribe` mà thôi. Lúc đó việc kết nối tới API sẽ thực thi. Bạn quay lại function `viewDidLoad` của ViewController nào. Thêm đoạn code sau:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    configUI()
    
    categories
        .asObservable()
        .subscribe(onNext: { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        })
        .disposed(by: bag)
    
    loadAPI()
}
```

Trong đó:

*  tiền hành `subscribe` tới biến `categories`. Khi nhận được dữ liệu là `onNext` thì gọi Tableview reloadData nhằm hiển thị kết quả mới nhất. Chú ý việc tiến hành xử lý chúng ở `Main Thread` vì gọi API được thực thi ở Thread khác, nên update UI sẽ bị crash nên ko về Main Thread.
* `loadAPI` để gọi việc kết nối và nhận dữ liệu từ API

Tới đây, là xong phần cơ bản rồi. Bạn tiến hành build và cảm nhận kết quản nào. Nếu không có gì lỗi lầm nữa thì bạn sẽ tiếp qua phần tiếp theo.

### 6. Using `contentIdentifier`

Giờ chúng ta sẽ lấy các Drinks của từng Category nha. Phần này sẽ dùng tới `contentIdentifier` cho nó thêm thi vị cuộc sống. Đầu tiên, bạn edit lại đoạn gọi request của `URLSession.rx` trong file Networking.

```swift
return URLSession.shared.rx.response(request: request)
    .map { (result: (response: HTTPURLResponse, data: Data)) -> T in
        
        if contentIdentifier != "" {
            let decoder = Networking.jsonDecoder(contentIdentifier: contentIdentifier)
            let envelope = try decoder.decode(NetworkingResult<T>.self, from: result.data)
            return envelope.content

        } else {
            let decoder = JSONDecoder()
            return try! decoder.decode(T.self, from: result.data)
        }
}
```

Nếu `contentIdentifier` khác rỗng thì chúng ta sẽ parse dữ liệu bằng `JSONDecoder` với `userInfor` được thêm vào. Nó sẽ sử dụng trong toàn bộ quán trình `decode`. Bạn hãy xem chúng như là một bí thuật vậy.

Việc còn lại của parse là dùng tới `NetworkingResult` với Generic `T` truyền nào. (nó sẽ khác cách trên).

Bạn tạo tiếp function để lấy danh sách Drink nào

```swift
func getDrinks(kind: String, value: String) -> Observable<[Drink]> {
    let query: [String: Any] = [kind : value]
    let url = EndPoint.drinks.url
    
    let rq: Observable<[Drink]> = request(url: url, query: query, contentIdentifier: "drinks")
    
    return rq.catchErrorJustReturn([])
}
```

Bạn hãy chú ý tới `Observable<[Drink]>`. Nó sẽ dễ hiểu hơn cách trên và nó tương minh hơn nhiều. Bạn không cần phải bọc lại nó bằng một class/struct nào nữa. Và vì key root trong API get Drinks List là `drinks` nên nó cũng là giá trị cho `contentIdentifier`.

Và cuối cùng, khi xác định và lấy đúng kiểu dữ liệu thì bạn chỉ cần return thôi, không cần biến đổi chúng.

> Quan tâm tới việc lấy chính xác cái cần lấy và không bọc qua nhiều lớp. Tránh việc khai báo lèn nhèn thì  `contentIdentifier` sẽ phát huy hiệu quả tốt nhất cho bạn.

Update lên UI của `DrinksViewController` thì cũng tương tự như màn hình kia. Bạn tham khảo qua code sau

```swift
// load api
func loadAPI() {
    Networking.shared().getDrinks(kind: "c", value: categoryName)
        .bind(to: drinks)
        .disposed(by: bag)
}

// subscribe
drinks
    .asObservable()
    .subscribe(onNext: { [weak self] drinks in
        DispatchQueue.main.async {
            self?.tableView.reloadData()
            self?.title = "\(self!.categoryName) (\(drinks.count))"
        }
    })
    .disposed(by: bag)
```

Bạn thêm function cho TableViewDelegate ở `CocktailViewController` để có thể push sang  `DrinksViewController`.

```swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let item = categories.value[indexPath.row]
    print("\(item.strCategory) - \(item.items.count) items")
    
    let vc = DrinksViewController()
    vc.categoryName = item.strCategory
    self.navigationController?.pushViewController(vc, animated: true)
}
```

Build chúng và cảm nhận kết quả nào!

### 7. Connect multi APIs

Bài toán mới, cũng là khó hơn và cũng hay gặp nhiều trong thực tế cuộc sống.

* Bạn có 1 danh sách Categories được lấy từ API. Nhưng dữ liệu trong mỗi Category đó chưa đủ với yêu cầu của project
* Bạn sẽ phải request từng Categories một và ráp dữ liệu lại với nhau
* Cuối cùng là kết thúc việc gọi một lúc nhiều API đó. 
* Update dữ liệu lên UI

Giải quyết bài toán này thì gần như 100% dev sẽ nghĩ tới

> `For` thần thánh hay cái gì đó mà `loop` cũng đc.

Đó không phải là giải pháp tồi. Nhưng chúng ta lại phải quan tâm tới nhiều điều còn kinh khủng hơn việc lặp request đó.

* Bất đồng bộ
* Tài nguyên của máy
* Error

Nếu như việc lặp chỉ khoản vài lần (dưới 5) thì mọi thứ vẫn oke hoặc iphone của bạn quá trâu bò. Thì bạn sẽ không nhận ra điều bất thường.  Nhưng khi số lượng quá nhiều thì gây áp lực lên vi xử lý, dễ gây treo máy và crash app.

Ngoài mong đợi là `error`. Nếu xử lý không gọn thì chỉ cần 1 request error là cả đám còn lại sẽ tèo theo. Còn nếu xử lý đc thì lại `if ... else` loạn thêm. 

Cú chốt cuối là khi nào chúng sẽ hoàn thành hết tất cả. Đây mới là cái quan trong nhất.

OKAY, khó khăn là thế. Tất nhiên đã có nhiều cách sử dụng để giải quyết. Trong bài này chúng ta sẽ dùng với RxSwift nào.

> Tư tưởng chính là biến các request riêng lẻ đó thành các sequence observables.

Tư tưởng sẽ như thế này

```
List:
    - item 1 --> request --> Observavle 1
    - item 2 --> request --> Observavle 1
    - item 3 --> request --> Observavle 3
    - item 4 --> request --> Observavle 4
    - item 5 --> request --> Observavle 5
    ....
    
    Observable final = Observavle 1 + Observavle 2 + Observavle 3 + ....
```

Chúng ta sẽ có nhiều `stream` cho nhiều request api. Chúng sẽ đọc lập với nhau. Sau đó chúng ta sẽ tiến hành gom chúng lại thành 1 `steam` duy nhất. Với mỗi element được `emit` ra chính là response của một request api sau khi thành công.

Công việc sẽ diễn ra một cách bất đồng bộ. Khi có 1 request xong thì sẽ xử lý dữ liệu từ chúng. Khi tất cả xong thì kết thúc cả quá trình. Và điều quan trọng, thì mọi thứ sẽ thực hiện khi có `subsrciption` tới Observable kìa thôi.

> Chắc đọc qua cũng muốn nổ não rồi. Thôi sang phần code cho nó nhẹ đầu nào.

Bạn mở file `CocktailViewController.swift` và tới function `loadAPI`. Tại đây chúng ta sẽ làm các công việc sau:

* Gọi API để lấy danh sách Cocktail Categories
* Gọi các API để lấy danh sách Drinks của từng loại Catergory trên
* Ráp dữ liệu của mỗi list Drinks của từng Category vào thuộc tính `items` của nó
* Cập nhật lại dữ liệu lên UI với việc `count` số lượng của tất cả các Drinks trong mỗi loại Category

Công việc cũng không vất vả phải không nào. Gời bạn thêm 1 đoạn code sau đoạn code để get các Cocktail Categories nào.

```swift
private func loadAPI() {
    let newCategories = Networking.shared().getCategories(kind: "c")
    
    let downloadItems = newCategories
        .flatMap { categories in
            return Observable.from(categories.map { category in
                Networking.shared().getDrinks(kind: "c", value: category.strCategory)
            })
        }
        .merge(maxConcurrent: 2)
   
   // .....
}
```

Bóc trần nó một chút nha:

* `downloadItems` là một Observable với kiểu dữ liệu là `[Drink]`
* Sử dụng chính Observable lấy Cocktail Categories là `newCategories` và biến đổi bằng toán tử `flatmap`
* Biến đổi từ kiểu kiểu `Observable<[CocktailCategory]>` thành `Observable<[Drink]>`
* Quá trình biến đổi như sau
    * Sử dụng toán tử `Observable.from`, bạn cũng biết tham số này cần 1 `array`
    * `categories.map` duyệt qua lần lượt các phần tử trong `categories`. Tai nỗi lần lặp thì gọi `getDrinks`
    * 1 Observable sẽ được trả về với kiểu  `Observable<[Drink]>`
    * Cứ như thế, lặp hết mãng `categories` thì ta có 1 mãng mới `[Observable<[Drink]>]`
* Như vậy, ta có 1 Observable mà các phần tử của nó có kiểu dữ liệu là 1 Observable.
* Để gọp chúng tại thì ta sử dụng toán tử `merge`. Như vậy thì các Observable con đó, phát ra dữ liệu thì chúng sẽ được gom về 1 Observable duy nhất.
* Đảm bảo tài nguyên của máy thì cho ta tối đa là 2 stream chạy đồng thời

> Observable này sẽ `emit` ra 1 mãng `Drink` và nó phát ra nhiều lần. Số lần phát chính là số lượng item trong `categories`. Như vậy nó sẽ là mãng 2 chiều.

Cứ như vậy, bạn có 1 Observable bá đạo, nó sẽ giúp bạn thực thi toàn bộ các request con mà yên tâm về mặt xử lý và hiệu năng.

> Tiếp tục hack não nào!

Bạn thêm đoạn code sau vào dưới đoạn code vừa rồi.

```swift
    let updateCategories = newCategories.flatMap { categories  in
        downloadItems
            .enumerated()
            .scan([]) { (updated, element:(index: Int, drinks: [Drink])) -> [CocktailCategory] in
                
                var new: [CocktailCategory] = updated
                new.append(CocktailCategory(strCategory: categories[element.index].strCategory, items: element.drinks))
                
                return new
        }
    }
```

Giải thích nào tiếp:

* Lại tao ra một Observable với tên là `updateCategories`, nó có kiểu dữ liệu cho các element của nó là `[CocktailCategory]`. Sau khi một hồi thì quay về kiểu ban đầu. Cần phải vậy để update lên UI của bạn (đã setup trước đó rồi)
* Công việc chính này là ráp dữ liệu của `downloadItems` vào `newCategories`. Tách các phần tử từ mãng 2 chiều `[[Drink]]` và gán cho thuộc tính `.items` của từng item trong mãng Category.

Giải quyết bằng toán tử như thế nào?

*  Đầu tiên là dùng chính Observable `newCategories` bằng toán tử `flatMap`
* Trong closure handle đó bạn lại sử dụng Observable `downloadItems` và biến đổi lần lượt như sau
    * Vì dữ liệu rất thô sơ, không có gì để phân biệt nên công việc chúng ta rất vất vả. Và sử dụng toán tử `.enumerated()`
    * Kiểu dữ liệu mới của  Observable `downloadItems` là 1 Tuple `(index: Int, drinks: [Drink])`
    * `.scan` để làm giảm các phần tử được `emit` . Ta có n phần tử thì còn 1 phần tử mà thôi. Quan trọng nhất là thay đổi lại kiểu dữ liệu return từ `[Drink]` thành `[CocktailCategory]`
    * Lợi dụng `element.index` để tạo 1 đối tượng `CocktailCategory` đầy đủ thông tin. Sau đó thêm vào mãng `updated`
    * Làm cho tới hết thì chúng ta có đầy đủ dữ liệu, sau đó array mới đó được return về cho toán từ `flatmap` đầu tiên.

> Như vậy đã xong việc ráp dữ liệu.

Phần cuối, `bind` Observable `updateCategories` tới thuộc tính `categories` của ViewController.

```swift
    updateCategories
        .bind(to: categories)
        .disposed(by: bag)
```

Như vậy là hoàn thành. Bạn tiến hành build lại project và cảm nhận kết quả nào. Nếu có lỗi thì cần chú ý 2 việc:

* Bình tĩnh hết sức
* Mở code demo của mình lên đối chiếu

Nếu vẫn không hết thì tắt máy và đi ra ngoài hít thở cho thư giản đầu óc. Rồi tiếp tục lại. Đùa vậy thôi, còn phần này là phần nâng cao. Khó ở chỗ ráp dữ liệu và nó tuỳ thuộc vào đặc điểm JSON trả về của mỗi loại API. Chứ không phải 100% phải xử lý như trên.

---

Mình xin kết thúc bài viết này tại đây. Bài khá dài, hi vọng nó sẽ giúp được cho bạn một chút. Cảm ơn vì đã đọc!
