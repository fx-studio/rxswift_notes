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
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        
        // MARK: - SEARCH
        let search = searchCityName.rx.text.orEmpty
                    .filter { !$0.isEmpty }
                    .flatMap { text in
                        return WeatherAPI.shared.currentWeather(city: text).catchErrorJustReturn(Weather.empty)
                    }
                    .share(replay: 1)
                    .observeOn(MainScheduler.instance)
        
        // MARK: - BINDING
        search.map { $0.cityName }
                    .bind(to: cityNameLabel.rx.text)
                    .disposed(by: bag)
        
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
        
        search.map { $0.cityName }
                    .bind(to: self.rx.title)
                    .disposed(by: bag)

    }
    
    // MARK: - private methods
    private func configUI() {
        title = "Weather City"
    }

}


// MARK: - Custom Binder
extension Reactive where Base: WeatherCityViewController {
    var title: Binder<String> {
        return Binder(self.base) { (vc, value) in
            vc.title = value
        }
    }
}
