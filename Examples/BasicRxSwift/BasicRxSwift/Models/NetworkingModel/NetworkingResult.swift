//
//  NetworkingResult.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 8/28/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import Foundation

extension CodingUserInfoKey {
  static let contentIdentifier = CodingUserInfoKey(rawValue: "contentIdentifier")!
}

struct NetworkingResult<Content: Decodable>: Decodable {
  
  let content: Content
  
  private struct CodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int? = nil
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = 0
    }
    
    init?(intValue: Int) {
      return nil
    }
  }
  
  init(from decoder: Decoder) throws {
    guard let ci = decoder.userInfo[CodingUserInfoKey.contentIdentifier],
          let contentIdentifier = ci as? String,
          let key = CodingKeys(stringValue: contentIdentifier) else {
      throw NetworkingError.invalidDecoderConfiguration
    }
    
    do {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        content = try container.decode(Content.self, forKey: key)
        print(content)
    } catch {
        print(error.localizedDescription)
        throw error
    }
  }
}
