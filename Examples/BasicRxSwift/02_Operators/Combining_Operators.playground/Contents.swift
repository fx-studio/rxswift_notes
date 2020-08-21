import UIKit
import RxSwift

example(of: "startWith") {
    let bag = DisposeBag()
    
    Observable.of("B", "C", "D", "E")
        .startWith("A")
        .subscribe(onNext: { value in
            print(value)
        })
        .disposed(by: bag)
}

example(of: "Observable.concat") {
    let bag = DisposeBag()
    
    let first = Observable.of(1, 2, 3)
    let second = Observable.of(4, 5, 6)

    let observable = Observable.concat([first, second])

    observable
        .subscribe(onNext: { value in
            print(value)
        })
        .disposed(by: bag)
    
}

example(of: "concat") {
    let bag = DisposeBag()
    
    let first = Observable.of("A", "B", "C")
    let second = Observable.of("D", "E", "F")
    
    let observable = first.concat(second)
    
    observable
        .subscribe(onNext: { value in
            print(value)
        })
        .disposed(by: bag)
}

example(of: "concatMap") {
    let bag = DisposeBag()
    
    let cities = [ "Mien Bac" : Observable.of("Ha Noi", "Hai Phong"),
                   "Mien Trung" : Observable.of("Hue", "Da Nang"),
                   "Mien Nam" : Observable.of("Ho Chi Minh", "Can Tho")]
    
    let observable = Observable.of("Mien Bac", "Mien Trung", "Mien Nam")
        .concatMap { name in
            cities[name] ?? .empty()
        }
    
    observable
        .subscribe(onNext: { (value) in
            print(value)
        })
        .disposed(by: bag)

}

example(of: "merge") {
    let bag = DisposeBag()
    
    let chu = PublishSubject<String>()
    let so = PublishSubject<String>()
    
    let source = Observable.of(chu.asObserver(), so.asObserver())
    
    let observable = source.merge()
    
    observable
        .subscribe(onNext: { (value) in
            print(value)
        })
        .disposed(by: bag)
    
    chu.onNext("Một")
    so.onNext("1")
    chu.onNext("Hai")
    so.onNext("2")
    chu.onNext("Ba")
    so.onCompleted()
    so.onNext("3")
    chu.onNext("Bốn")
    chu.onCompleted()
}

example(of: "combinedLatest") {
    let bag = DisposeBag()
    
    let chu = PublishSubject<String>()
    let so = PublishSubject<String>()
    
    let observable = Observable.combineLatest(chu, so) { chu, so in
        "\(chu) : \(so)"
    }
    
    observable
        .subscribe(onNext: { (value) in
            print(value)
        })
    .disposed(by: bag)
    
    chu.onNext("Một")
    chu.onNext("Hai")
    so.onNext("1")
    so.onNext("2")
    
    chu.onNext("Ba")
    so.onNext("3")
    chu.onCompleted()
    chu.onNext("Bốn")
    
    so.onNext("4")
    so.onNext("5")
    so.onNext("6")
    
    
    so.onCompleted()
}

example(of: "combine user choice and value") {
    let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)

    let dates = Observable.of(Date())

    let observable = Observable.combineLatest(choice, dates) { format, when -> String in
        let formatter = DateFormatter()
        formatter.dateStyle = format
        return formatter.string(from: when)
    }
    
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
}

example(of: "zip") {
    let bag = DisposeBag()
    
    let chu = PublishSubject<String>()
    let so = PublishSubject<String>()
    
    let observable = Observable.zip(chu, so) { chu, so in
        "\(chu) : \(so)"
    }
    
    observable
        .subscribe(onNext: { (value) in
            print(value)
        })
    .disposed(by: bag)
    
    chu.onNext("Một")
    chu.onNext("Hai")
    so.onNext("1")
    so.onNext("2")
    
    chu.onNext("Ba")
    so.onNext("3")
    chu.onCompleted()
    chu.onNext("Bốn")
    
    so.onNext("4")
    so.onNext("5")
    so.onNext("6")
    
    so.onCompleted()
}

example(of: "withLatestFrom") {
  
  let button = PublishSubject<Void>()
  let textField = PublishSubject<String>()

    let observable = button.withLatestFrom(textField)
    
    _ = observable
        .subscribe(onNext: { value in
            print(value)
        })

    textField.onNext("Đa")
    textField.onNext("Đà Na")
    textField.onNext("Đà Nẵng")
    
    button.onNext(())
    button.onNext(())
}

example(of: "sample") {
  
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()

    let observable = textField.sample(button)
    
    _ = observable
        .subscribe(onNext: { value in
            print(value)
        })

    textField.onNext("Đa")
    textField.onNext("Đà Na")
    textField.onNext("Đà Nẵng")
    
    button.onNext(())
    button.onNext(())
}

example(of: "amb") {
    let bag = DisposeBag()
    
    let chu = PublishSubject<String>()
    let so = PublishSubject<String>()
    
    let observable = chu.amb(so)
    
    observable
        .subscribe(onNext: { (value) in
            print(value)
        })
    .disposed(by: bag)
    
    so.onNext("1")
    so.onNext("2")
    so.onNext("3")
    
    chu.onNext("Một")
    chu.onNext("Hai")
    chu.onNext("Ba")
    
    so.onNext("4")
    so.onNext("5")
    so.onNext("6")
       
    chu.onNext("Bốn")
    chu.onNext("Năm")
    chu.onNext("Sáu")
}

example(of: "sưitchLatest") {
    let bag = DisposeBag()
    
    let chu = PublishSubject<String>()
    let so = PublishSubject<String>()
    let dau = PublishSubject<String>()
    
    let observable = PublishSubject<Observable<String>>()
    
    let subscription = observable
        .switchLatest()
        .subscribe(onNext: { (value) in
            print(value)
        }, onCompleted: {
            print("completed")
        }, onDisposed: {
            print("disposed")
        })
    
    observable.onNext(so)
    
    so.onNext("1")
    so.onNext("2")
    so.onNext("3")
    
    observable.onNext(chu)
    
    chu.onNext("Một")
    chu.onNext("Hai")
    chu.onNext("Ba")
    
    so.onNext("4")
    so.onNext("5")
    so.onNext("6")
    
    observable.onNext(dau)
    
    dau.onNext("+")
    dau.onNext("-")
    
    observable.onNext(chu)
    chu.onNext("Bốn")
    chu.onNext("Năm")
    chu.onNext("Sáu")

    subscription.dispose()
}

example(of: "reduce") {
    let source = Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9)

    //let observable = source.reduce(0, accumulator: +)
    
    //let observable = source.reduce(0) { $0 + $1 }
    
    let observable = source.reduce(0) { summary, newValue in
      return summary + newValue
    }
    
    _ = observable
        .subscribe(onNext: { value in
            print(value)
        })
}

example(of: "scan") {
    let source = Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9)

    //let observable = source.scan(0, accumulator: +)
    
    //let observable = source.scan(0) { $0 + $1 }
    
    let observable = source.scan(0) { summary, newValue in
      return summary + newValue
    }
    
    _ = observable
        .subscribe(onNext: { value in
            print(value)
        })
}

