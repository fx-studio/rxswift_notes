//
//  Music.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 8/26/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import Foundation

final class Music: Codable {
    var artistName: String
    var id: String
    var releaseDate: String
    var name: String
    var copyright: String
    var artworkUrl100: String
}

struct MusicResults: Codable {
  var results: [Music]
}

struct FeedResults: Codable {
  var feed: MusicResults
}
