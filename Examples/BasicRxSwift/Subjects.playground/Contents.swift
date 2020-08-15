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

example(of: "Publish Subject") {
    let disposeBag = DisposeBag()
    let subject = PublishSubject<String>()
    
    subject.onNext("1")
    
    let subscription1 = subject
        .subscribe(onNext: { value in
            print("Sub 1: ", value)
        }, onCompleted: {
            print("sub 1: completed")
        })
        
    subject.onNext("2")
    
    let subscription2 = subject
        .subscribe(onNext: { value in
            print("Sub 2: ", value)
        }, onCompleted: {
            print("sub 2: completed")
        })
    
    subject.onNext("3")
    subject.onNext("4")
    subject.onNext("5")
    
    subscription2.dispose()
    subject.onNext("6")
    subject.onNext("7")
    
    subject.on(.completed)
    subject.onNext("8")
    
    subject .subscribe {
        print("sub 3: ", $0.element ?? $0)
    }
    .disposed(by: disposeBag)
}

example(of: "Behavior Subject") {
    let disposeBag = DisposeBag()
    
    enum MyError: Error {
      case anError
    }
    
    let subject = BehaviorSubject(value: "0")
    
    //Subscribe 1
    subject .subscribe {
        print("🔵 ", $0)
      }
    .disposed(by: disposeBag)
    
    // emit
    subject.onNext("1")
    
    //Subscribe 2
    subject .subscribe {
        print("🔴 ", $0)
      }
    .disposed(by: disposeBag)
    
    // error
    subject.onError(MyError.anError)
    
    //Subscribe 3
    subject .subscribe {
        print("🟠 ", $0)
      }
    .disposed(by: disposeBag)
}
