import UIKit
import RxSwift

example(of: "Single") {
    
    enum FileError: Error {
        case pathError
    }
    
    let bag = DisposeBag()
    
    func readFile(path: String?) -> Single<String> {
        return Single.create { single -> Disposable in
            if let path = path  {
                single(.success("Success!"))
            } else {
                single(.error(FileError.pathError))
            }
            
            return Disposables.create()
        }
    }
    
    readFile(path: nil)
        .subscribe { event in
            switch event {
            case .success(let value):
                print(value)
            case .error(let error):
                print(error)
            }
    }
    .disposed(by: bag)
}

example(of: "Completable") {
    let bag = DisposeBag()
    
    enum FileError: Error {
        case pathError
        case failedCaching
    }
    
    func cacheLocally() -> Completable {
        return Completable.create { completable in
            // Store some data locally
            //...
            //...
            
            let success = true
            
            guard success else {
                completable(.error(FileError.failedCaching))
                return Disposables.create {}
            }
            
            completable(.completed)
            return Disposables.create {}
        }
    }
    
    cacheLocally()
        .subscribe { completable in
            switch completable {
            case .completed:
                print("Completed with no error")
            case .error(let error):
                print("Completed with an error: \(error)")
            }
    }
    .disposed(by: bag)
    
    cacheLocally()
        .subscribe(onCompleted: {
            print("Completed with no error")
        },
                   onError: { error in
                    print("Completed with an error: \(error)")
        })
        .disposed(by: bag)
}

example(of: "Maybe") {
    
    let bag = DisposeBag()
    
    enum MyError: Error {
        case anError
    }
    
    func generateString() -> Maybe<String> {
        return Maybe<String>.create { maybe in
            maybe(.success("RxSwift"))
            
            // OR
            
            maybe(.completed)
            
            // OR
            
            maybe(.error(MyError.anError))
            
            return Disposables.create {}
        }
    }
    
    generateString()
        .subscribe { maybe in
            switch maybe {
            case .success(let element):
                print("Completed with element \(element)")
            case .completed:
                print("Completed with no element")
            case .error(let error):
                print("Completed with an error \(error.localizedDescription)")
            }
    }
    .disposed(by: bag)
    
    generateString()
        .subscribe(onSuccess: { element in
            print("Completed with element \(element)")
        }, onError: { error in
            print("Completed with an error \(error.localizedDescription)")
        }, onCompleted: {
            print("Completed with no element")
        })
        .disposed(by: bag)
}
