import UIKit
import RxSwift

struct User {
    let message: BehaviorSubject<String>
}

example(of: "toArray") {
    let bag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6)
        .toArray()
        .subscribe(onSuccess: { value in
            print(value)
        })
        .disposed(by: bag)
}

example(of: "map") {
    let bag = DisposeBag()
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    Observable<Int>.of(1, 2, 3, 4, 5, 10, 999, 9999, 1000000)
        .map { formatter.string(for: $0) ?? "" }
        .subscribe(onNext: { string in
            print(string)
        })
        .disposed(by: bag)
}

example(of: "enumerated and map") {
  let disposeBag = DisposeBag()
    Observable.of(1, 2, 3, 4, 5, 6)
        .enumerated()
        .map { index, integer in
            index > 2 ? integer * 2 : integer
        }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

example(of: "flatMap") {
    let bag = DisposeBag()
    
    let cuTy = User(message: BehaviorSubject(value: "Cu Tý chào bạn!"))
    let cuTeo = User(message: BehaviorSubject(value: "Cu Tèo chào bạn!"))
    
    let subject = PublishSubject<User>()
    
    subject
        .flatMap { $0.message }
        .subscribe(onNext: { msg in
            print(msg)
        })
        .disposed(by: bag)
    
    // subject
    subject.onNext(cuTy)
    
    // cuTy
    cuTy.message.onNext("Có ai ở đây không?")
    cuTy.message.onNext("Có một mình mình thôi à!")
    cuTy.message.onNext("Buồn vậy!")
    cuTy.message.onNext("....")
    
    // subject
    subject.onNext(cuTeo)
    
    // cuTy
    cuTy.message.onNext("Chào Tèo, bạn có khoẻ không?")
    
    // cuTeo
    cuTeo.message.onNext("Chào Tý, mình khoẻ. Còn bạn thì sao?")
    
    // cuTy
    cuTy.message.onNext("Mình cũng khoẻ luôn")
    cuTy.message.onNext("Mình đứng đây từ chiều nè")
    
    // cuTeo
    cuTeo.message.onNext("Kệ Tý. Ahihi")

}

example(of: "flatMapLatest") {
    let bag = DisposeBag()
    
    let cuTy = User(message: BehaviorSubject(value: "Tý: Cu Tý chào bạn!"))
    let cuTeo = User(message: BehaviorSubject(value: "Tèo: Cu Tèo chào bạn!"))
    
    let subject = PublishSubject<User>()
    
    subject
        .flatMapLatest { $0.message }
        .subscribe(onNext: { msg in
            print(msg)
        })
        .disposed(by: bag)
    
    // subject
    subject.onNext(cuTy)
    
    // cuTy
    cuTy.message.onNext("Tý: Có ai ở đây không?")
    cuTy.message.onNext("Tý: Có một mình mình thôi à!")
    cuTy.message.onNext("Tý: Buồn vậy!")
    cuTy.message.onNext("Tý: ....")
    
    // subject
    subject.onNext(cuTeo)
    
    // cuTy
    cuTy.message.onNext("Tý: Chào Tèo, bạn có khoẻ không?")
    
    // cuTeo
    cuTeo.message.onNext("Tèo: Chào Tý, mình khoẻ. Còn bạn thì sao?")
    
    // cuTy
    cuTy.message.onNext("Tý: Mình cũng khoẻ luôn")
    cuTy.message.onNext("Tý: Mình đứng đây từ chiều nè")
    
    // cuTeo
    cuTeo.message.onNext("Tèo: Kệ Tý. Ahihi")

}

example(of: "materialize & dematerialize") {
    enum MyError: Error {
      case anError
    }
    
    let bag = DisposeBag()
    
    let cuTy = User(message: BehaviorSubject(value: "Tý: Cu Tý chào bạn!"))
    let cuTeo = User(message: BehaviorSubject(value: "Tèo: Cu Tèo chào bạn!"))
    
    let subject = PublishSubject<User>()
    
    let roomChat = subject
        .flatMapLatest {
            $0.message.materialize()
        }
        
     roomChat
        .filter{
            guard $0.error == nil else {
                print("Lỗi phát sinh: \($0.error!)")
                return false
            }
            
            return true
        }
        .dematerialize()
        .subscribe(onNext: { msg in
            print(msg)
        })
        .disposed(by: bag)
    
    subject.onNext(cuTy)
    
    cuTy.message.onNext("Tý: A")
    cuTy.message.onNext("Tý: B")
    cuTy.message.onNext("Tý: C")
    
    cuTy.message.onError(MyError.anError)
    cuTy.message.onNext("Tý: D")
    cuTy.message.onNext("Tý: E")
    
    subject.onNext(cuTeo)
       
    cuTeo.message.onNext("Tèo: 1")
    cuTeo.message.onNext("Tèo: 2")
}
