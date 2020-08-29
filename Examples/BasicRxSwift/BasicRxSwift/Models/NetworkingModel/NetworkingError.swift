//
//  NetworkingError.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 8/28/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import Foundation

enum NetworkingError: Error {
  case invalidURL(String)
  case invalidParameter(String, Any)
  case invalidJSON(String)
  case invalidDecoderConfiguration
}
