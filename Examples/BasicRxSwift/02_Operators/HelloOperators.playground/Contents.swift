import UIKit
import RxSwift

example(of: "Hello 1") {
    let bag = DisposeBag()
    
    let hello = Observable.from(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"])
    
    hello
        //.reduce("", accumulator: +)
        .scan("", accumulator: +)
        .subscribe(onNext: { value in
            print(value)
        }, onError: { error in
            print(error)
        }, onCompleted: {
            print("Completed")
        }) {
            print("Disposed")
        }
        .disposed(by: bag)
}

example(of: "Hello 2") {
    let bag = DisposeBag()
    
    let hello = Observable.from(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"])
    
    hello
        .map { Int($0) }
        .subscribe(onNext: { value in
            print(value!)
        }, onError: { error in
            print(error)
        }, onCompleted: {
            print("Completed")
        }) {
            print("Disposed")
        }
        .disposed(by: bag)
}


example(of: "Hello 3") {
    let bag = DisposeBag()
    
    let hello = Observable.from(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"])
    
    hello
        .map { string -> Int in
            Int(string) ?? 0
        }
        .filter { $0 % 2 == 0 }
        .subscribe(onNext: { value in
            print(value)
        }, onError: { error in
            print(error)
        }, onCompleted: {
            print("Completed")
        }) {
            print("Disposed")
        }
        .disposed(by: bag)
}
