# 01 Giới thiệu
## Asynchronous Programming

Đây quả thật là cả một bầu trời kiến thức. Trước đây, khi tìm hiểu về RxSwift thì bạn sẽ nghe tới khái niệm **Reactive Programming** là nhiều hơn. Nhưng với sự ra đời của Combine thì đang lại thêm một sắc thái mới cho họ hàng nhà Rx. Nó không còn chỉ là React đơn thuần nữa. Mà đã tiến hoá thành **Lập trình bất đồng bộ.**

> Nó là gì?

Câu hỏi này quá khó để sử dụng ngôn ngữ tự nhiên mà giải đáp. Vì có thể mình là một dev chứ không phải một nhà văn nhà thơ. Nhưng có thể tóm gọn qua vài ý sau đây:

* Tất cả các phần trong chương trình của bạn hoạt động độc lập với nhau
* Module này không chờ modele kia
* Dữ liệu nhận được sẽ quyết định trạng thái của các thành phần
* Không thể biết trước được dữ liệu nhận được như thế nào và thời điểm nào
* ...

Ví dụ: dễ hiểu là chương trình của bạn phát một bài hát từ Internet. Bài hoá sẽ được truyền tải từ internet về điện thoại của bạn. lúc đó bạn vẫn điều khiển được UI của bạn cho các tác vụ khác (next, back, pause ....)

Nếu bạn là một lập trình viên iOS thì có khi bạn đã sử dụng chúng nó quá nhiều mà không hết hay biết gì. Tất cả đều là thuyết âm mưu mà Apple đã dày công xây dựng lâu nay.

###Cocoa and UIKit asynchronous APIs

* **Notification Center** : Dùng để lắng nghe một sự kiện xảy ra, dù đang ở bất kì đâu. Hay dùng như ẩn hiện bàn phím
* **The delegate pattern** : Uỷ quyền cho một đối tượng nhằm để thực hiện một hoặc nhiều hành động khác lên một đối tượng khác
* **Grand Central Dispatch** : Cách đơn giản nhất để thực hiện multi-threading hoặc lập lịch cho các task
* **Closures** : Giúp cho các đoạn mã có thể bay nhảy xa hơn, thoát ra khỏi luân hồi

Và đó cũng chính là những thứ mà bạn phải nắm được trước khi bước vào thế giới của **RxSwift**. Quan trọng cực kì luôn đó!

Và tất cả những thứ trên khi bạn viết vào chương trình của mình. Thì mới hoàn thành được 1/2 công việc. Chính chỉ mang tính chất là thiết kế sẵn, là khung xương của ứng dụng. Tuy nhiên, linh hồn của ứng dụng sẽ được quyết định bằng **luồng dữ liệu**. Nếu luồng dữ liệu là đồng bộ thì sẽ là đồng bộ, ngược lại là bất đồng bộ thì là bất đồng bộ.

Ví dụ: in 100 số lên màn hình với 2 cách

* Đồng bộ với việc duyệt mãng từ 1~100 và print ra

  ```swift
  var array = [1, 2, 3 ... 100]
  for number in array {
    print(number)
  }
  ```

* Bất đồng bộ với việc không xác định thời điểm số tiếp theo được in ra

  ```swift
  var array = [1, 2, 3 ... 100]
  var currentIndex = 0
  @IBAction func printNext(_ sender: Any) { 
  print(array[currentIndex])
  if currentIndex < array.count {
      currentIndex += 1
    }
  }
  ```



### Các thuật ngữ cần nắm

* **State**
  * Đây chính là biểu hiện dữ liệu trong ứng dụng của bạn. Từ đó tạo ra các trạng thái cho ứng dụng hay từng thành phần nhỏ hơn như là ViewController, ViewModel ...
  * Dựa vào mỗi trạng thái mà giao diện ứng dụng sẽ thay đổi theo. Quyết định View sẽ hiển thị gì
  * Chúng có thể truyền đi và có thể sửa đổi được
* **Imperative programming**
  * Cũng khá là quen thuộc với các bạn. Chính là việc điều kiển hoặc thay đổi các trạng thái trong chương trình
  * Ví dụ
    * Load API -> Config Data > Config UI > Update UI 
    * Chúng sẽ được thực hiện tuần tự
  * Điểm hạn chế lớn nhất là bạn cần phải quan tâm tới thứ tự thực hiện các lệnh này. Nếu không thì với sự thay đổi vị trí thì dẫn đến chương trình bạn hoạt động không theo ý muốn
* **Side effects**
  * Bạn nên biết rằng, khi bạn tác động làm thay đổi trạng thái của 1 thành phần thì không chỉ thành phần đó sẽ thay đổi. Mà có thể nó sẽ ảnh hưởng tới các thành phần khác
  * Quan trong ở đây là bạn phải kiểm soát chúng nó. Để giảm đi hoặc không cho phép các hiệu ứng khác xảy ra khi trạng thái của một thành phần nào đó thay đổi
* **Declarative code**
  * Đây chính là các đoạn code của bản nhằm để cân bằng việc
    * Thay đổi các trạng thái 
    * Giảm đi các hiệu ứng phụ xảy ra
  * Cũng chính là các mà bạn cần phải luyện tập để hướng tới.
  * Mọi thứ (biến, class, action ...) đều được khai báo và cài đặt sẵn các hành động nếu trạng thái của chúng bị thay đổi.
* **Reactive systems**
  * Để đảm bảo được hiệu xuất tối đa thì tất cả mọi thứ phải hoạt động nhịp nhàn. Từ đó khái niệm Reactive systems được ra đời. Đơn giản là để app iOS và web có thể giao tiếp với nhau một cách nhuần nhuyễn hơn
  * Các khái niệm nhỏ liên quan như sau:
    * Responsive
    * Resilient
    * Elastic
    * Message driven

---

## RxSwift

Mô tả qua vài dòng về lịch sử ra đời của nó như sau:

- Khái niệm Reactive Programming đã xuất hiện từ rất lâu rồi
- Chủ yếu trên các nền tảng web
- Giúp người lạp trình quản lý được tốt hơn khi xử lý giao diện và logic trở nên quá nhiều.
- Reactive Extensions cho .NET (Rx), Microsoft, solving the problems of asynchronous, scalable, real time
- Rx trở thành phần mở rộng cho .Net 3.5 và .Net 4.0 thì đc build sẵn trong core
- RxJS, RxKotlin, Rx.NET, RxScala, RxSwift …
- Tất cả đều tương đồng về API
- Xem thêm tại đây : http://reactivex.io

Có 3 thành phần quan trọng cấu hình lên RxSwift

### Observables

* Observable<T>  : là class do RxSwift cung cấp

* Cho phép tạo ra 1 chuổi các sự kiện không đồng bộ

* Observer lắng nghe Observable —> bất kì nắng mưa, bão tố …

* Phát ra 3 kiểu sự kiện:

  * next
  * completed
  * error

* Tuy nhiên trong quá trình thực tế thì có 2 trường hợp điển hình

  * Các sự kiện được diễn ra Theo 1 mạch logic nhất định

    ```swift
    API.download(file: "http://www...") .subscribe(onNext: { data in
        // Append data to temporary file
      },
      onError: { error in
        // Display error to user
      },
      onCompleted: {
        // Use downloaded file
    })
    ```

    Việc download sẽ hoạt động theo một trình tự được thiết kê ra sẵn.

  * Các sự kiện lặp đi lặp lại vô hạn

    ```swift
    UIDevice.rx.orientation .subscribe(onNext: { current in
    switch current { case .landscape:
    // Re-arrange UI for landscape
    case .portrait:
    // Re-arrange UI for portrait
    } })
    ```

    Ứng dụng của bạn có thể xoay bất cứ lúc nào. Nên việc xử lý này cũng lặp đi lặp lại miết



### Operators

* Là những toán tử mà bạn sẽ phải sử dụng rất nhiều
* Nó cũng là những thứ mà tạo nên tên tuổi cho RxSwift và họ hàng nhà React
* Đơn giản, để biến đổi A -> B thì bạn có thể áp dụng các toán tử cho A và kết quả nhận được là B
* Các toán tử có thể nối đuôi nhau, đầu ra của 1 toán tử này chính là đầu vào của một toán tử khác.
* Chúng được chia thành nhiều nhóm. Mình sẽ điều ở phần sau

### Schedulers

* Lập lịch hay còn có thể điều khiển việc xử lý hay tương tương tác ở các thread khác nhau
* Tối ưu việc đồng bộ và bất đồng bộ trong chương trình
* Nếu muốn hiểu sơ qua thì nó như là GCD vậy, tuy nhiên nó là phần khó và mình sẽ đề cập sau

---

## **App architecture**

- Với kiến trúc project thì RxSwift không gây ra ảnh hưởng nào
- Các mô hình MVC, MVP hay MVVM thì không bị thay đổi khi thêm RxSwift vào
- Kể cả bạn thay đổi 1 function hay viết mới lại chúng thì đều không ảnh hưởng tới các phần khác
- Với môi hình MVVM thì kết hợp với RxSwift thì tăng hiệu quả hơn rất nhiều.
- Cần nắm rõ cấu trúc app hiện tại của project mình rồi sẽ quyết định triển khai ntn thế nào là oke.
