# 08 Hello UIKit

Chào bạn đã tới được tới đây. Giờ chúng ta sẽ tạm gác lại lý thuyết chay với cái Playground khô khan kia đi. Chương này sẽ áp dụng những gì cơ bản của RxSwift vào trong iOS Project với UIKit là chủ đạo.

Danh sách các phần như sau:

1. [Hello ViewController](08_1_HelloViewController.md)

   Hướng dẫn cách `import` , cài đặt và tương tác trong 1 ViewController

2. [Talking to other ViewController](08_2_TalkingOtherVC.md)

   Giải quyết bài toán truyền dữ liệu giữa 2 ViewController

3. [Custom Observable](08_3_CustomObservable.md)

   Tạo nên các function với giá trị trả về là một Observable. Tiền đề tạo nên các Model hay các API sau này.
   
4. [Fetching Data from API](08_4_FetchingDataAPI.md)

   Tương tác với API để lấy dữ liệu và update chúng trên UI
   
5. [Working with cache data](08_5_WorkingCache.md)

   Phần này sẽ xử lý dữ liệu lấy được từ API và lưu chúng vào 1 bộ nhớ tạm nào đó. Và cập nhật dữ liệu lên UI từ các nguồn khác nhau (bộ đệm & API)
   
6. [Networking](08_6_Networking.md)

   Tương tác với nhiều API và tạo các Models phục vụ việc kết nối, quản lý và parse data. Giải quyết các bài toán cơ bản với API

Trong phần này chỉ mang tính chất áp dụng thư viện RxSwift và giải quyết các bài toán cơ bản khi làm việc với iOS Project bằng UIKit mà thôi. Không áp dụng các cách giải quyết cao cấp hay các mô hình hiện đại hơn.

> Mục tiêu cho bạn thấy RxSwift cũng là chỉ một thư viện mà thôi.