//
//  WeatherAPI.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 9/2/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import Foundation
import CoreLocation

struct Weather: Decodable {
    let cityName: String
    let temperature: Int
    let humidity: Int
    let icon: String
    let coordinate: CLLocationCoordinate2D
    
    static let empty = Weather(
        cityName: "Unknown",
        temperature: -1000,
        humidity: 0,
        icon: iconNameToChar(icon: "e"),
        coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
    )
    
    static let dummy = Weather(
        cityName: "Fx Studio",
        temperature: 20,
        humidity: 90,
        icon: iconNameToChar(icon: "01d"),
        coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
    )
    
    init(cityName: String,
         temperature: Int,
         humidity: Int,
         icon: String,
         coordinate: CLLocationCoordinate2D) {
        self.cityName = cityName
        self.temperature = temperature
        self.humidity = humidity
        self.icon = icon
        self.coordinate = coordinate
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cityName = try values.decode(String.self, forKey: .cityName)
        let info = try values.decode([AdditionalInfo].self, forKey: .weather)
        icon = iconNameToChar(icon: info.first?.icon ?? "")
        
        let mainInfo = try values.nestedContainer(keyedBy: MainKeys.self, forKey: .main)
        temperature = Int(try mainInfo.decode(Double.self, forKey: .temp))
        humidity = try mainInfo.decode(Int.self, forKey: .humidity)
        let coordinate = try values.decode(Coordinate.self, forKey: .coordinate)
        self.coordinate = CLLocationCoordinate2D(latitude: coordinate.lat, longitude: coordinate.lon)
    }
    
    enum CodingKeys: String, CodingKey {
        case cityName = "name"
        case main
        case weather
        case coordinate = "coord"
    }
    
    enum MainKeys: String, CodingKey {
        case temp
        case humidity
    }
    
    private struct AdditionalInfo: Decodable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    private struct Coordinate: Decodable {
      let lat: CLLocationDegrees
      let lon: CLLocationDegrees
    }

}
