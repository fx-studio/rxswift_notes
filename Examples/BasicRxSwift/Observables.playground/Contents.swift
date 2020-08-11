import UIKit
import RxSwift

example(of: "Just, Of, From") {
    let iOS = 1
    let android = 2
    let flutter = 3
    
    // JUST
    let observable1 = Observable<Int>.just(iOS)
    
    // OF
    let observable2 = Observable.of(iOS, android, flutter)
    let observable3 = Observable.of([iOS, android, flutter])
    
    // FROM
    let observable4 = Observable.from([iOS, android, flutter])
    
    // SUBSCRIBE
    observable1.subscribe { event in
        print(event)
    }
    
    observable2.subscribe { event in
    if let element = event.element {
        print(element)
      }
    }
    
    observable3.subscribe(onNext: { element in
      print(element)
    })
    
    observable4.subscribe(onNext: { (value) in
        print(value)
    }, onError: { (error) in
        print(error.localizedDescription)
    }, onCompleted: {
        print("Completed")
    }) {
        print("Disposed")
    }
}

example(of: "empty") {
    let observable = Observable<Void>.empty()
    
    observable.subscribe(
      onNext: { element in
        print(element)
    },
      onCompleted: {
        print("Completed")
      }
    )
}

example(of: "never") {
    let observable = Observable<Any>.never()
    
    observable.subscribe(
        onNext: { element in
            print(element)
        },
        onCompleted: {
            print("Completed")
        }
    )
}

example(of: "range") {
    let observable = Observable<Int>.range(start: 1, count: 10)
    var sum = 0
    observable
        .subscribe(
            onNext: { i in
                sum += i
        } , onCompleted: {
            print("Sum = \(sum)")
        }
    )
    
    let ob2 = Observable<Int>.rang
}

