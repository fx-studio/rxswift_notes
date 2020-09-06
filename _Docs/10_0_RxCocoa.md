# 10 - RxCocoa

Giờ chúng ta đã đi được 1 nữa con đường rồi. Đây là phần liên quan tới core `Cocoa` và các extension được Rx hoá. Sẽ có nhiều kiến thức lý thuyết mới. Và quan trọng hơn hết là cách tối ưu việc sử dụng RxSwift trong iOS Project

### Giới thiệu

Bạn cũng biết `Rx` là multi-platform framework. Trong đó thì về mặt:

* **Ngôn ngữ** thì các API sẽ tương đồng với nhau. Bạn biết đc RxSwift thì khi chuyển sang các ngôn ngữ khác như RxPython, RxRuby, RxJS ... sẽ tiếp cận một cách nhanh chóng hơn và có nét quen thuộc cực kỳ.
* **Nền tảng** thì đó là những xử lý riêng biệt và sẽ không giống nhau ở các nên tảng khác. Với `iOS` & `macOS` thì được build trên nền tảng `Cocoa`. Vì vậy, phần `RxCocoa` là các tính năng mở rộng thêm theo Rx cho Cocoa.

RxCocoa sẽ cung cấp cho bạn các lớp học sẵn có để thực hiện mạng phản ứng, phản ứng với các tương tác của người dùng, liên kết các mô hình dữ liệu với các điều khiển giao diện người dùng và hơn thế nữa.

Về các bài được trình bày trong phần này chủ yếu tập trung các vấn đề bạn sẽ gặp.

### Danh sách

1. [Display Data](10_1_DisplayData.md)

   Hiển thị dữ liệu luôn là việc đầu tiên cần phải làm. Bên cạnh đó cũng là sự update lại dữ liệu lên giao diện.

2. 