import UIKit
import RxSwift

example(of: "Hello RxSwift") {
    let just = Observable.just("Hello RxSwift")
    just.subscribe { (value) in
        print(value)
    }
}
