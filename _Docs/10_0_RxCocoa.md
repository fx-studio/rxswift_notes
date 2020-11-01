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

2. [Binding Observables](10_2_BindingObservables.md)

   Cách để liên kết 2 thực thể với nhau bằng dữ liệu.

3. [RxCocoa Traits](10_3_RxCocoaTraits.md)

   Tìm hiểu về các Traits đặc trưng của RxCocoa và đặc điểm từng loại.

4. [Multi Control](10_4_MultiControl.md)

   Tương tác với nhiều UI trong một màn hình. Kết hợp với việc handle các Observables để đảm bảo hiển thị và dữ liệu với nhiều UI Control một lúc.

5. [Extending CCLocationManager](10_5_ExtendingCCLocationManager.md)

   Mở rộng class CLLocationManager trong không gian Rx. Học cách Rx hoá các protocol delegate & delegate proxy.

6. [Merge Observables Input](10_6_MegerObservablesInput.md)

   Hợp nhất các sự kiện cùng chung một nhiệm vụ trong project. Từ đó hạn chế đi các lỗi ngớ ngẫn hay thiếu sót việc xử lý các sự kiện.
   
7. [Extend UIKit](10_7_ExtendUIKit.md)

    Triển khai mở rộng toàn diện một UI Control trong không gian Reactive ( tức `.rx`). Với các thành phần cần mở rộng là Proxy Delegate, Forward Delegate & Binder
