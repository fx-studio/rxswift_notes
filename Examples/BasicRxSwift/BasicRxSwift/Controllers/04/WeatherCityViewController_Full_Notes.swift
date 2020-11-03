//
//  WeatherCityViewController.swift
//  
//
//  Created by Le Phuong Tien on 9/2/20.
//

import UIKit
import RxCocoa
import RxSwift
import CoreLocation
import MapKit

class WeatherCityViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private var searchCityName: UITextField!
    @IBOutlet private var tempLabel: UILabel!
    @IBOutlet private var humidityLabel: UILabel!
    @IBOutlet private var iconLabel: UILabel!
    @IBOutlet private var cityNameLabel: UILabel!
    @IBOutlet weak var containerView: UIStackView!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var mapButton: UIButton!
    
    // MARK: - Properties
    let bag = DisposeBag()
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        
        // ------------------------------------------------------------------------------------------//
        // MARK: - Display Data from API
        // Check TextField
        /*
        searchCityName.rx.text.orEmpty
            .filter { !$0.isEmpty }
            .flatMap { text in
                return WeatherAPI.shared.currentWeather(city: text).catchErrorJustReturn(Weather.empty)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { weather in
                self.cityNameLabel.text = weather.cityName
                self.tempLabel.text = "\(weather.temperature) °C"
                self.humidityLabel.text = "\(weather.humidity) %"
                self.iconLabel.text = weather.icon
            })
            .disposed(by: bag)
         */
        
        
        // ------------------------------------------------------------------------------------------//
        // MARK: - Binding Observables
        // Creat search with textfield
        /*
        let search = searchCityName.rx.text.orEmpty
            .filter { !$0.isEmpty }
            .flatMap { text in
                return WeatherAPI.shared.currentWeather(city: text).catchErrorJustReturn(Weather.empty)
            }
            .share(replay: 1)
            .observeOn(MainScheduler.instance)
        
        // Binding to UI
        search.map { "\($0.temperature) °C" }
            .bind(to: tempLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.cityName }
            .bind(to: cityNameLabel.rx.text)
            .disposed(by: bag)
        
        search.map { "\($0.humidity) %" }
            .bind(to: humidityLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.icon }
            .bind(to: iconLabel.rx.text)
            .disposed(by: bag)
        
        // custom Binder
        search.map { $0.cityName }
            .bind(to: self.rx.title)
            .disposed(by: bag)
        */
        
        
        // ------------------------------------------------------------------------------------------//
        //MARK: - RxCocoa Traits
        // Create Drive
        /*
        let search = searchCityName.rx.text.orEmpty
            .filter { !$0.isEmpty }
            .flatMap { text in
                return WeatherAPI.shared.currentWeather(city: text).catchErrorJustReturn(Weather.empty)
            }
            .asDriver(onErrorJustReturn: Weather.empty)
        */
        
        // Control Event
        /*
        let search = searchCityName.rx.controlEvent(.editingDidEndOnExit)
            .map { self.searchCityName.text ?? "" }
            .filter { !$0.isEmpty }
            .flatMap { text in
                return WeatherAPI.shared
                    .currentWeather(city: text)
                    .catchErrorJustReturn(Weather.empty)
            }
            .asDriver(onErrorJustReturn: Weather.empty)
         */
        
        // ------------------------------------------------------------------------------------------//
        //MARK: - Working with multi Control
        // Tách Observables
        let searchInput = searchCityName.rx.controlEvent(.editingDidEndOnExit)
            .map { self.searchCityName.text ?? "" }
            .filter { !$0.isEmpty }
        
        /* --> replay with merge
        let search = searchInput
            .flatMapLatest { text  in
                return WeatherAPI.shared.currentWeather(city: text)
                    .catchErrorJustReturn(Weather.empty)
            }
            .asDriver(onErrorJustReturn: Weather.empty)
        */
        
        // ------------------------------------------------------------------------------------------//
        //MARK: - Extension CLLocationManager
        
        // request user authen
        /*
        locationButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.startUpdatingLocation()
            })
            .disposed(by: bag)
        */
        
        // get & filter location
        let currentLocation = locationManager.rx.didUpdateLocation
            .map { locations in locations[0] }
            .filter { location in
                return location.horizontalAccuracy < kCLLocationAccuracyHundredMeters
            }
        
        // subscribe updateLocation
        locationManager.rx.didUpdateLocation
            .subscribe(onNext: { locations in
                print("🔴 ", locations)
            })
            .disposed(by: bag)
        
        // when tap button
        let locationInput = locationButton.rx.tap.asObservable()
            .do(onNext: {
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.startUpdatingLocation()
                
            })
    
        let locationObs = locationInput
            .flatMap { return currentLocation.take(1) }
        
        // ------------------------------------------------------------------------------------------//
        //MARK: MAPVIEW SEARCHS INPUT
        let mapInput = mapView.rx.regionDidChangeAnimated
            .map { [unowned self] _ in self.mapView.centerCoordinate }
        
        // ------------------------------------------------------------------------------------------//
        //MARK: - MERGE SEARCHS
        
        // search with UITextField
        let textSearch = searchInput.flatMap { text in
            return WeatherAPI.shared.currentWeather(city: text)
                .catchErrorJustReturn(.dummy)
        }
        
        
        // search with Location
        let locationSearch = locationObs.flatMap { location  in
            return WeatherAPI.shared.currentWeather(at: location.coordinate)
                    .catchErrorJustReturn(.dummy)
        }
        
        // search with MapView
        let mapSearch = mapInput.flatMap { coordinate in
            return WeatherAPI.shared.currentWeather(at: coordinate)
                    .catchErrorJustReturn(.dummy)
        }
        
        // merge search
        let search = Observable
            .merge(locationSearch, textSearch, mapSearch)
            .asDriver(onErrorJustReturn: .dummy)
        
        // ------------------------------------------------------------------------------------------//
        //MARK: - DRIVER to UI
        // drive UI
        search.map { "\($0.temperature) °C" }
            .drive(tempLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.cityName }
            .drive(cityNameLabel.rx.text)
            .disposed(by: bag)
        
        search.map { "\($0.humidity) %" }
            .drive(humidityLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.icon }
            .drive(iconLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.cityName }
            .drive(self.rx.title)
            .disposed(by: bag)
        
        // loading view
        let loading = Observable.merge(
                searchInput.map { _ in true },
                locationInput.map { _ in true }, // update with search at Location
                mapInput.map { _ in true }, // update with search at MapView
                search.map { _ in false }.asObservable()
            )
            .startWith(true)
            .asDriver(onErrorJustReturn: false)
        
        loading
            .skip(1)
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: bag)
        
        loading
            .drive(containerView.rx.isHidden)
            .disposed(by: bag)
        
        loading
            .drive(tempLabel.rx.isHidden)
            .disposed(by: bag)
        
        loading
            .drive(iconLabel.rx.isHidden)
            .disposed(by: bag)
        
        loading
            .drive(humidityLabel.rx.isHidden)
            .disposed(by: bag)
        
        loading
            .drive(cityNameLabel.rx.isHidden)
            .disposed(by: bag)

        
        // ------------------------------------------------------------------------------------------//
        //MARK: - First Subcribe Observable
        WeatherAPI.shared.currentWeather(city: "Hanoi")
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { weather in
                self.cityNameLabel.text = weather.cityName
                self.tempLabel.text = "\(weather.temperature) °C"
                self.humidityLabel.text = "\(weather.humidity) %"
                self.iconLabel.text = weather.icon
            })
            .disposed(by: bag)
        
        // ------------------------------------------------------------------------------------------//
        //MARK: - Extend MKMapView
        
        // show/hide mapview
        mapButton.rx.tap
            .subscribe(onNext: {
                self.mapView.isHidden.toggle()
            })
            .disposed(by: bag)
        
        // set delegate
        mapView.rx.setDelegate(self)
            .disposed(by: bag)
        
        // add pin
        locationManager.rx.didUpdateLocation
            .subscribe(onNext: { locations in
                for location in locations {
                    let pin = MKPointAnnotation()
                    pin.coordinate = location.coordinate
                    pin.title = "Pin nè"
                    
                    self.mapView.addAnnotation(pin)
                }
            })
            .disposed(by: bag)
        
        // add with API
        search.map { weather -> MKPointAnnotation in
            let pin = MKPointAnnotation()
            pin.title = weather.cityName
            pin.subtitle = "\(weather.temperature) °C - \(weather.humidity) % - \(weather.icon)"
            pin.coordinate = weather.coordinate
            
            return pin
        }
        .drive(mapView.rx.pin)
        .disposed(by: bag)

    }
    
    // MARK: - private methods
    private func configUI() {
        title = "Weather City"
    }

}

extension Reactive where Base: WeatherCityViewController {
    var title: Binder<String> {
        return Binder(self.base) { (vc, value) in
            vc.title = value
        }
    }
}

extension WeatherCityViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pin.animatesDrop = true
        pin.pinTintColor = .red
        pin.canShowCallout = true
        return pin
    }
}
