import UIKit
import RxSwift

let bag = DisposeBag()

// With timer
func observableWithTimer() {
    let elementsPerSecond = 1
    let maxElements = 5
    let replayedElements = 1
    let replayDelay: TimeInterval = 3
    
    let observable = Observable<Int>.create { observer -> Disposable in
        
        var value = 1
        
        let source = DispatchSource.makeTimerSource(queue: .main)
        source.setEventHandler {
            if value <= maxElements {
                observer.onNext(value)
                value += 1
            }
        }

        source.schedule(deadline: .now(), repeating: 1.0 / Double(elementsPerSecond), leeway: .nanoseconds(0))
        source.resume()
        
        return Disposables.create {
            source.suspend()
        }
    }
    
    let replaySource = observable.replayAll() //replay(1)

    DispatchQueue.main.asyncAfter(deadline: .now()) {
        
        observable
        .subscribe(onNext: { value in
            printValue("🔴 : \(value)")
        }, onCompleted: {
            print("🔴 Completed")
        }, onDisposed: {
            print("🔴 Disposed")
        })
        .disposed(by: bag)
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
        replaySource
            .subscribe(onNext: { value in
                printValue("🔵 : \(value)")
            }, onCompleted: {
                print("🔵 Completed")
            }, onDisposed: {
                print("🔵 Disposed")
            })
            .disposed(by: bag)
    }
    
    replaySource.connect()

}

//observableWithTimer()
// ----------------------------- //

// Buffer
func bufferSample() {
    let bufferTimeSpan = RxTimeInterval.milliseconds(4000)
    let bufferMaxCount = 2

    let source = PublishSubject<String>()

    source
        .subscribe(onNext: { value in
            printValue("🔴 : \(value)")
        })
        .disposed(by: bag)

    source
        .buffer(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
        .map { $0.count }
        .subscribe(onNext: { (value) in
            printValue("🔵 \(value)")
        })
        .disposed(by: bag)

    //DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
    //    source.onNext("A")
    //    source.onNext("B")
    //    source.onNext("C")
    //    source.onNext("D")
    //}

    let dispatchSource = DispatchSource.makeTimerSource(queue: .main)
    dispatchSource.setEventHandler {
        source.onNext("X")
    }

    dispatchSource.schedule(deadline: .now(), repeating: 1.0, leeway: .nanoseconds(0))
    dispatchSource.resume()
}


// ----------------------------- //

// window //
func windowSample() {
    let bufferTimeSpan = RxTimeInterval.milliseconds(4000)
    let bufferMaxCount = 2

    let source = PublishSubject<String>()

    source
        .subscribe(onNext: { value in
            printValue("🔴 : \(value)")
        })
        .disposed(by: bag)

    source
        .window(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
        .flatMap({ obs -> Observable<[String]> in
            obs.scan(into: []) { $0.append($1) }
        })
        .subscribe(onNext: { (value) in
            printValue("🔵 \(value)")
        })
        .disposed(by: bag)

    let dispatchSource = DispatchSource.makeTimerSource(queue: .main)
    var count = 1
    dispatchSource.setEventHandler {
        source.onNext("\(count)")
        count += 1
    }

    dispatchSource.schedule(deadline: .now(), repeating: 1.0, leeway: .nanoseconds(0))
    dispatchSource.resume()
}

// ----------------------------- //

// Delay //

func delaySample() {
    let source = PublishSubject<String>()

    source
        // delaySubcription
        .delay(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
        .subscribe(onNext: { value in
            printValue("🔴 : \(value)")
        })
        .disposed(by: bag)

    var count = 1
    var timer = DispatchSource.timer(interval: 1.0, queue: .main) {
        printValue("emit: \(count)")
        source.onNext("\(count)")
        count += 1
    }
}

// ----------------------------- //

// intervals //

func tintervalsSample() {
    let source = Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
    let replay = source.replay(2)


    DispatchQueue.main.asyncAfter(deadline: .now()) {
        
        source
        .subscribe(onNext: { value in
            printValue("🔴 : \(value)")
        }, onCompleted: {
            print("🔴 Completed")
        }, onDisposed: {
            print("🔴 Disposed")
        })
        .disposed(by: bag)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        replay
            .subscribe(onNext: { value in
                printValue("🔵 : \(value)")
            }, onCompleted: {
                print("🔵 Completed")
            }, onDisposed: {
                print("🔵 Disposed")
            })
            .disposed(by: bag)
    }

    replay.connect()
}

// timer
func timerSample() {

    let source = Observable<Int>.timer(RxTimeInterval.seconds(3), scheduler: MainScheduler.instance)

    DispatchQueue.main.asyncAfter(deadline: .now()) {
        
        source
        .flatMap { _ in
            source.delay(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
        }
        .subscribe(onNext: { value in
            printValue("🔴 : \(value)")
        }, onCompleted: {
            print("🔴 Completed")
        }, onDisposed: {
            print("🔴 Disposed")
        })
        .disposed(by: bag)
    }
}

let source = PublishSubject<Int>()
    
source
    .timeout(RxTimeInterval.seconds(5), scheduler: MainScheduler.instance)
    .subscribe(onNext: { value in
        printValue("🔴 : \(value)")
    }, onCompleted: {
        print("🔴 Completed")
    }, onDisposed: {
        print("🔴 Disposed")
    })
    .disposed(by: bag)


DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    source.onNext(1)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    source.onNext(2)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
    source.onNext(3)
}
