import UIKit
import RxSwift

example(of: "Subjects") {
    let subject = PublishSubject<String>()
    
    subject.onNext("Chào bạn")
    
    let subscription1 = subject
        .subscribe(onNext: { value in
            print(value)
        })

    subject.onNext("Chào bạn lần nữa")
    subject.onNext("Chào bạn lần thứ 3")
    subject.onNext("Mình đứng đây từ chiều")
}
