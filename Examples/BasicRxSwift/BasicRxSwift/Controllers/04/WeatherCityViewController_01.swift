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
        
        // MARK: - SUBSCRIBE
        // First subscribe
        WeatherAPI.shared.currentWeather(city: "")
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { weather in
                        self.cityNameLabel.text = weather.cityName
                        self.tempLabel.text = "\(weather.temperature) °C"
                        self.humidityLabel.text = "\(weather.humidity) %"
                        self.iconLabel.text = weather.icon
                    })
                    .disposed(by: bag)
        
        // MARK: - UITEXTFIELD
        // check TEXT property
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

    }
    
    // MARK: - private methods
    private func configUI() {
        title = "Weather City"
    }

}
