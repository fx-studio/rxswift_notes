//
//  Animal.swift
//  TableViewWithRxSwift
//
//  Created by Tien Le P. VN.Danang on 2/18/22.
//

import Foundation
import RxDataSources

// Item
struct Animal {
    var name: String
}

// Header
struct AnimalSection {
    var header: String
    var items: [Item]
}

extension AnimalSection: SectionModelType {
    typealias Item = Animal
    
    init(original: AnimalSection, items: [Item]) {
        self = original
        self.items = items
    }
}
