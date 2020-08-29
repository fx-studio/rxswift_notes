//
//  Cocktail.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 8/28/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import Foundation

struct Drink: Codable {
    var strDrink: String
    var strDrinkThumb: String
    var idDrink: String
}

struct DrinkResult {
    var drinks: [Drink]
}
