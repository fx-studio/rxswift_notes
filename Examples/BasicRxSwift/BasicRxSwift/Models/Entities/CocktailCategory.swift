//
//  CocktailCategory.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 8/28/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import Foundation

struct CocktailCategory: Codable {
    var strCategory: String
    var items = [Drink]()
    
    private enum CodingKeys: String, CodingKey {
      case strCategory
    }
}

struct CategoryResult<T: Codable> : Codable {
    var drinks: [T]
}
