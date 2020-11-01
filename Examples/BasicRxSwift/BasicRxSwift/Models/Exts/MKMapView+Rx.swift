//
//  MKMapView+Rx.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 10/30/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import RxCocoa
import RxSwift

extension MKMapView: HasDelegate {
    public typealias Delegate = MKMapViewDelegate
}

class RxMKMapViewDelegateProxy: DelegateProxy<MKMapView, MKMapViewDelegate>, DelegateProxyType, MKMapViewDelegate {
    weak public private(set) var mapView: MKMapView?
    
    public init(mapView: ParentObject) {
        self.mapView = mapView
        super.init(parentObject: mapView, delegateProxy: RxMKMapViewDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { RxMKMapViewDelegateProxy(mapView: $0) }
    }
}

public extension Reactive where Base: MKMapView {
    var delegate: DelegateProxy<MKMapView, MKMapViewDelegate> {
        return RxMKMapViewDelegateProxy.proxy(for: base)
    }
    
    func setDelegate(_ delegate: MKMapViewDelegate) -> Disposable {
        return RxMKMapViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }
    
    var pin: Binder<MKPointAnnotation> {
        return Binder(self.base) { mapView, pin in
            mapView.addAnnotation(pin)
        }
    }
    
    var regionDidChangeAnimated: ControlEvent<Bool> {
        let source = delegate
            .methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
            .map { parameters -> Bool in
                return (parameters[1] as? Bool) ?? false
            }
        return ControlEvent(events: source)
    }
}
