//
//  WeatherCityViewController.swift
//  
//
//  Created by Le Phuong Tien on 9/2/20.
//

import UIKit
import RxCocoa
import RxSwift

class WeatherCityViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private var searchCityName: UITextField!
    @IBOutlet private var tempLabel: UILabel!
    @IBOutlet private var humidityLabel: UILabel!
    @IBOutlet private var iconLabel: UILabel!
    @IBOutlet private var cityNameLabel: UILabel!
    
    // MARK: - Properties
    let bag = DisposeBag()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        
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
        
        // Creat search with textfield
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
        
        // Subcribe
        WeatherAPI.shared.currentWeather(city: "Hanoi")
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

extension Reactive where Base: WeatherCityViewController {
    var title: Binder<String> {
        return Binder(self.base) { (vc, value) in
            vc.title = value
        }
    }
}
