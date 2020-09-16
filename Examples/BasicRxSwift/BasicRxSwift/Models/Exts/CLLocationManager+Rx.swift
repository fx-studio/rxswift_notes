//
//  CLLocationManager+Rx.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 9/16/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import CoreLocation

//MARK: CLLocationManager
extension CLLocationManager: HasDelegate {
    public typealias Delegate = CLLocationManagerDelegate
}

//MARK: Delegate Proxy
class  RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {
    
    // properties --> Cocoa class
    weak public private(set) var locationManager: CLLocationManager?
    
    // init
    public init(locationManager: ParentObject) {
        self.locationManager = locationManager
        super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }
    
    // required
    static func registerKnownImplementations() {
        self.register { RxCLLocationManagerDelegateProxy(locationManager: $0) }
    }
    
    
}

//MARK: Extension Rx cho CLLocationManager
public extension Reactive where Base: CLLocationManager {
    // delegate proxy
    var delegate : DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
    }
    
    // didUpdateLocation
    var didUpdateLocation: Observable<[CLLocation]> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
            .map { parameters in
                return parameters[1] as! [CLLocation]
            }
    }
}
