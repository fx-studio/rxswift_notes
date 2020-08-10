import UIKit
import RxSwift

example(of: "Hello RxSwift") {
    let helloRx = Observable.just("Hello RxSwift")
    helloRx.subscribe { (value) in
        print(value)
    }
}
