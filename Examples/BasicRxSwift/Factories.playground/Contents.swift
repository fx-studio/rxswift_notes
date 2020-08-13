import UIKit
import RxSwift

example(of: "Factory") {
    let bag = DisposeBag()
    
    var flip = true
    
    let factory = Observable<Int>.deferred {
        flip.toggle()
        
        if flip {
            return Observable.of(1)
        } else {
            return Observable.of(0)
        }
    }
    
    for _ in 0...10 {
        factory.subscribe(
            onNext: { print($0, terminator: "") })
            .disposed(by: bag)
    
        print()
    }
}
