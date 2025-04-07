//
//  AppTips.swift
//  AyoBaca
//
//  Created by Jerry Febriano on [Your Current Date]
//

import TipKit
import SwiftUI

// Tip for the Profile Card (First Tip)
struct ProfileTip: Tip {
    var title: Text { Text("Profil Kamu") }
    var message: Text? { Text("Disini kamu bisa melihat nama, umur, dan level membacamu.") }
    var image: Image? { Image(systemName: "person.crop.rectangle") }
    var options: [Option] { MaxDisplayCount(1) }
    // NO rules needed for sequence when using TipGroup
}

// Tip for the Streak Counter (Second Tip)
struct StreakTip: Tip {
    var title: Text { Text("Streak Belajar") }
    var message: Text? { Text("Lihat berapa hari berturut-turut kamu sudah rajin berlatih membaca!") }
    var image: Image? { Image(systemName: "flame.fill") }
    var options: [Option] { MaxDisplayCount(1) }
    // REMOVE rules: var rules: [Rule] { ... }
}

// Tip for the Mascot Card (Third Tip)
struct MascotTip: Tip {
    var title: Text { Text("Teman Belajarmu") }
    var message: Text? { Text("Maskot ini akan menemanimu dalam petualangan belajar membaca.") }
    var image: Image? { Image(systemName: "figure.stand") }
    var options: [Option] { MaxDisplayCount(1) }
    // REMOVE rules: var rules: [Rule] { ... }
}

// Tip for the Start Practice Button (Fourth Tip)
struct PracticeButtonTip: Tip {
    var title: Text { Text("Mulai Latihan") }
    var message: Text? { Text("Tekan tombol ini untuk memulai sesi latihan membaca hari ini.") }
    var image: Image? { Image(systemName: "play.circle.fill") }
    var options: [Option] { MaxDisplayCount(1) }
    // REMOVE rules: var rules: [Rule] { ... }
}
