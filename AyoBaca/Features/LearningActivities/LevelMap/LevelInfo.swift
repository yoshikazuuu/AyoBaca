//
//  LevelInfo.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//


import SwiftUI

// Represents a single level marker on the map.
struct LevelInfo: Identifiable {
  let id: Int
  let position: CGPoint
  var status: LevelStatus
  let characterRange: ClosedRange<String>
  let name: String

  /// Designated initializer: if `name` is omitted or nil,
  /// it defaults to "Level <id>"
  init(
    id: Int,
    position: CGPoint,
    status: LevelStatus,
    characterRange: ClosedRange<String>,
    name: String? = nil
  ) {
    self.id = id
    self.position = position
    self.status = status
    self.characterRange = characterRange
    self.name = name ?? "Level \(id)"
  }
}
