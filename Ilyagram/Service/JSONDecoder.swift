//
//  JSONDecoder.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 16.05.2024.
//

import Foundation

class JSONDecoderSnakeCase: JSONDecoder {
    override init() {
        super .init()
        keyDecodingStrategy = .convertFromSnakeCase
    }
}
