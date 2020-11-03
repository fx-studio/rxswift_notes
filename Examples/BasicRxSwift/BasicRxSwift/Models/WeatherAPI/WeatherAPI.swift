//
//  Weather.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 9/2/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

class WeatherAPI {
    
    // MARK: - Singleton
    static var shared = WeatherAPI()
    
    // MARK: - Properties
    /// API key
    private let apiKey = ""
    /// API base URL
    let baseURL = URL(string: "https://api.openweathermap.org/data/2.5")!
    
    // MARK: - init
    init() { }
    
    // MARK: - private methods
    private func request(method: String = "GET", pathComponent: String, params: [(String, String)]) -> Observable<Data> {
        let url = baseURL.appendingPathComponent(pathComponent)
        var request = URLRequest(url: url)
        let keyQueryItem = URLQueryItem(name: "appid", value: apiKey)
        let unitsQueryItem = URLQueryItem(name: "units", value: "metric")
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        if method == "GET" {
            var queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
            queryItems.append(keyQueryItem)
            queryItems.append(unitsQueryItem)
            urlComponents.queryItems = queryItems
        } else {
            urlComponents.queryItems = [keyQueryItem, unitsQueryItem]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request.httpBody = jsonData
        }
        
        print("🔴 URL: \(urlComponents.url!.absoluteString)")
        
        request.url = urlComponents.url!
        request.httpMethod = method
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        
        return session.rx.data(request: request)
    }
    
    // MARK: - public methods
    func currentWeather(city: String) -> Observable<Weather> {
        // Data with case Hardcode
//        return Observable<Weather>.just(
//                    Weather(cityName: "Fx Studio",
//                            temperature: 99,
//                            humidity: 99,
//                            icon: iconNameToChar(icon: "01d"),
//                            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
//                )
        
        // Data with City Name
        return Observable<Weather>.just(
            Weather(cityName: city,
                    temperature: 99,
                    humidity: 99,
                    icon: iconNameToChar(icon: "01d"),
                    coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        )
        
//        return request(pathComponent: "weather", params: [("q", city)])
//            .map { data in
//                let decoder = JSONDecoder()
//                return try decoder.decode(Weather.self, from: data)
//            }
    }
    
    func currentWeather(at coordinate: CLLocationCoordinate2D) -> Observable<Weather> {
      return request(pathComponent: "weather", params: [("lat", "\(coordinate.latitude)"),
                                                        ("lon", "\(coordinate.longitude)")])
        .map { data in
          let decoder = JSONDecoder()
          return try decoder.decode(Weather.self, from: data)
        }
    }
}

/**
 * Maps an icon information from the API to a local char
 * Source: http://openweathermap.org/weather-conditions
 */
public func iconNameToChar(icon: String) -> String {
  switch icon {
  case "01d":
    return  "☀️"
  case "01n":
    return "🌙"
  case "02d":
    return "🌤"
  case "02n":
    return "🌤"
  case "03d", "03n":
    return "☁️"
  case "04d", "04n":
    return "☁️"
  case "09d", "09n":
    return "🌧"
  case "10d", "10n":
    return "🌦"
  case "11d", "11n":
    return "⛈"
  case "13d", "13n":
    return "❄️"
  case "50d", "50n":
    return "💨"
  default:
    return "E"
  }
}
