import UIKit
import RxSwift

example(of: "ignoreElements") {
    let subject = PublishSubject<String>()
    let bag = DisposeBag()
    
    subject
    .ignoreElements()
        .subscribe { event in
              print(event)
            }
        .disposed(by: bag)
    
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    subject.onCompleted()
}

example(of: "elementAt") {
    let subject = PublishSubject<String>()
    let bag = DisposeBag()
    
    subject
    .elementAt(2)
        .subscribe { event in
              print(event)
            }
        .disposed(by: bag)
    
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    //subject.onCompleted()
}

example(of: "Filter") {
    let bag = DisposeBag()
    let array = Array(0...10)
    
    Observable.from(array)
        .filter { $0 % 2 == 0 }
        .subscribe(onNext: {
            print($0) })
        .disposed(by: bag)
}

example(of: "skip") {
    let disposeBag = DisposeBag()
    
    Observable.of("A", "B", "C", "D", "E", "F")
        .skip(3)
        .subscribe(onNext: {
            print($0) })
        .disposed(by: disposeBag)
    
}

example(of: "skipWhile") {
    let bag = DisposeBag()
    
    Observable.of(2, 4, 8, 9, 2, 4, 5, 7, 0, 10)
        .skipWhile { $0 % 2 == 0 }
        .subscribe(onNext: {
            print($0) })
        .disposed(by: bag)
}

example(of: "SkipUntil") {
    let bag = DisposeBag()
    
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    subject
        .skipUntil(trigger)
        .subscribe(onNext: { value in
            print(value)
        })
        .disposed(by: bag)
    
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    subject.onNext("4")
    subject.onNext("5")
    
    trigger.onNext("XXX")
    
    subject.onNext("6")
    subject.onNext("7")
    
}

example(of: "take") {
    let bag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9)
        .take(4)
        .subscribe(onNext: { (value) in
            print(value)
        })
        .disposed(by: bag)
}

example(of: "takeWhile") {
    let bag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9)
        .takeWhile { $0 < 4 }
        .subscribe(onNext: { (value) in
            print(value)
        })
        .disposed(by: bag)
}

example(of: "takeWhile + enumerated") {
    let bag = DisposeBag()
    
    Observable.of(2, 4, 6, 8, 0, 12, 1, 3, 4, 6, 2)
        .enumerated()
        .takeWhile { index, value in
            value%2 == 0 && index < 3
        }
        .subscribe(onNext: { (value) in
            print(value)
        })
        .disposed(by: bag)
}

example(of: "takeUntil") {
    let bag = DisposeBag()
    
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    subject
        .takeUntil(trigger)
        .subscribe(onNext: { value in
            print(value)
        })
        .disposed(by: bag)
    
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    subject.onNext("4")
    subject.onNext("5")
    
    trigger.onNext("XXX")
    
    subject.onNext("6")
    subject.onNext("7")
    
}

example(of: "distinctUntilChanged") {
    let disposeBag = DisposeBag()
    
    Observable.of("A", "A", "B", "B", "A", "A", "A", "C", "A")
        .distinctUntilChanged()
        .subscribe(onNext: {
            print($0)
            
        })
        .disposed(by: disposeBag)
}

example(of: "custom type") {
    
    struct Point {
        var x: Int
        var y: Int
    }
    
    let disposeBag = DisposeBag()
    
    let array = [ Point(x: 0, y: 1),
                  Point(x: 0, y: 2),
                  Point(x: 1, y: 0),
                  Point(x: 1, y: 1),
                  Point(x: 1, y: 3),
                  Point(x: 2, y: 1),
                  Point(x: 2, y: 2),
                  Point(x: 0, y: 0),
                  Point(x: 3, y: 3),
                  Point(x: 0, y: 1)]
    
    Observable.from(array)
        .distinctUntilChanged { (p1, p2) -> Bool in
            p1.x == p2.x
        }
        .subscribe(onNext: { point in
            print("Point (\(point.x), \(point.y))")
        })
        .disposed(by: disposeBag)
}
