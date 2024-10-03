//
//  AlertModel.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 06.06.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
    var secondButtonText: String? = nil
    var secondCompletion: (() -> Void)? = {}
}
