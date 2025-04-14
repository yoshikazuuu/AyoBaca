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
    var message: Text? { Text("Kamu bisa lihat nama, foto profil, umur dan level kamu dalam latihan membaca di sini!") }
    var image: Image? { Image(systemName: "person.crop.rectangle") }
    var options: [Option] { MaxDisplayCount(1) }
}

// Tip for the Streak Counter (Second Tip)
struct MascotAndStreakTip: Tip {
    var title: Text { Text("Teman dan Streak Belajar") }
    var message: Text? { Text("Nah! kamu akan bertemu Ado di halaman ini, kamu bisa lihat juga streak yang kamu dapat saat latihan!") }
    var image: Image? { Image(systemName: "flame.fill") }
    var options: [Option] { MaxDisplayCount(1) }
}

// Tip for the Start Practice Button (Fourth Tip)
struct PracticeButtonTip: Tip {
    var title: Text { Text("Mulai Latihan") }
    var message: Text? { Text("Kamu bisa mulai petualangan kamu latihan di tombol ini!") }
    var image: Image? { Image(systemName: "play.circle.fill") }
    var options: [Option] { MaxDisplayCount(1) }
}

struct MapButtonTip: Tip {
    var title: Text { Text("Peta Baca") }
    var message: Text? { Text("Di tombol ini kamu bisa melihat peta petualangan belajar membaca kamu sudah sampai mana!") }
    var image: Image? { Image(systemName: "location.fill") }
    var options: [Option] { MaxDisplayCount(1) }
}

struct ProfileButtonTip: Tip {
    var title: Text { Text("Profil") }
    var message: Text? { Text("Disini tombol yang bisa diakses Papa Mama untuk melihat progress anak belajar membaca!") }
    var image: Image? { Image(systemName: "person.fill") }
    var options: [Option] { MaxDisplayCount(1) }
}
