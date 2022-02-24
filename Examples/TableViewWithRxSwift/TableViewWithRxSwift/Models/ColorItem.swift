//
//  ColorItem.swift
//  TableViewWithRxSwift
//
//  Created by Tien Le P. VN.Danang on 2/22/22.
//

import Foundation
import RxDataSources

// MARK: Item
struct ColorItem {
    let id = UUID()
    let color: UIColor
    
    init() {
        let red = Float.random(in: 0...1)
        let blue = Float.random(in: 0...1)
        let green = Float.random(in: 0...1)
        
        color = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }
}

extension ColorItem: IdentifiableType, Equatable {
    typealias Identity = UUID
    
    var identity: UUID {
        return id
    }
}

// MARK: Sections
struct ColorSection {
    var items: [Item]
}

extension ColorSection: AnimatableSectionModelType {
    typealias Item = ColorItem
    typealias Identity = Int
    
    init(original: ColorSection, items: [Item]) {
        self = original
        self.items = items
    }
    
    // Need to provide a unique id, only one section in our model
    var identity: Int {
        return 0
    }
    
}
