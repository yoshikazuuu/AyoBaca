//
//  LevelDefinition.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import Foundation
import SwiftUI

struct LevelDefinition: Equatable, Hashable {
    let id: Int
    let position: CGPoint
    let range: ClosedRange<String>
    let name: String
}
