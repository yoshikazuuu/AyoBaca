//
//  ProfileView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//


import SwiftUI
import SwiftData // Only if ModelContext is directly used by View, otherwise remove

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    // @Environment(\.dismiss) private var dismiss // Not used if AppStateManager handles nav

    var body: some View {
        // NavigationView is appropriate here if this view is presented independently
        // or needs its own navigation bar for title and toolbar items.
        // If ContentView handles all navigation, then NavigationView might not be needed here.
        // For this structure, let's assume it manages its own bar.
        NavigationView {
            ZStack {
                Color("AppOrange").ignoresSafeArea() // Background

                ScrollView {
                    VStack(spacing: 24) {
                        profileHeader
                        generalSettingsSection
                        #if DEBUG
                        debugControlsSection
                        #endif
                        appInfoSection
                    }
                    .padding() // Padding for ScrollView content
                }
            }
            .navigationTitle("Profil & Pengaturan")
            .navigationBarTitleDisplayMode(.inline) // Or .automatic
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.navigateBackToDashboard()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Kembali")
                        }
                        .foregroundColor(Color("AppOrange")) // Or .white if bar is colored
                    }
                }
            }
            // Confirmation Alerts
            .alert("Reset Onboarding?", isPresented: $viewModel.showOnboardingResetAlert) {
                Button("Batal", role: .cancel) {}
                Button("Reset", role: .destructive) { viewModel.performResetOnboarding() }
            } message: {
                Text("Ini akan mengembalikan aplikasi ke pengalaman pertama kali dan menghapus data profil. Kamu perlu memasukkan data anak lagi.")
            }
            .alert("Reset Progres Karakter?", isPresented: $viewModel.showProgressResetAlert) {
                Button("Batal", role: .cancel) {}
                Button("Reset", role: .destructive) { viewModel.performResetCharacterProgress() }
            } message: {
                Text("Ini akan menghapus semua huruf yang telah terbuka dan hanya menyisakan huruf A.")
            }
            .alert("Hapus Semua Data Pengguna?", isPresented: $viewModel.showUserDataResetAlert) {
                Button("Batal", role: .cancel) {}
                Button("Hapus Semua", role: .destructive) { viewModel.performClearAllUserData() }
            } message: {
                Text("PERHATIAN: Ini akan menghapus SEMUA data pengguna termasuk profil, kemajuan belajar, dan progres karakter. Tindakan ini tidak dapat dibatalkan.")
            }
        }
        .navigationViewStyle(.stack) // Recommended for iOS 16+ if using NavigationView
    }

    // MARK: - UI Components (Subviews)

    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color("AppOrange").opacity(0.2))
                    .frame(width: 100, height: 100)
                Image("mascot") // Ensure asset exists
                    .resizable().scaledToFit()
                    .frame(width: 90, height: 90).clipShape(Circle())
            }
            VStack(spacing: 4) {
                Text(viewModel.childName)
                    .font(.appFont(.dylexicBold, size: 24))
                    .foregroundColor(Color("AppOrange"))
                Text("\(viewModel.childAge) tahun")
                    .font(.appFont(.rethinkRegular, size: 16))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16).fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }

    private var generalSettingsSection: some View {
        SectionView(title: "Pengaturan Umum") {
            settingRow(icon: "bell.fill", title: "Notifikasi", action: viewModel.notificationsTapped)
            Divider().padding(.leading, 56)
            settingRow(icon: "speaker.wave.2.fill", title: "Suara", action: viewModel.soundSettingsTapped)
            Divider().padding(.leading, 56)
            settingRow(icon: "textformat.size", title: "Ukuran Font", action: viewModel.fontSizeTapped)
        }
    }

    #if DEBUG
    private var debugControlsSection: some View {
        SectionView(title: "Pengaturan Developer") {
            settingRow(icon: "arrow.counterclockwise.circle.fill", title: "Reset Onboarding", iconColor: .orange, action: viewModel.confirmResetOnboarding)
            Divider().padding(.leading, 56)
            settingRow(icon: "character.book.closed.fill", title: "Reset Kemajuan Karakter", iconColor: .orange, action: viewModel.confirmResetCharacterProgress)
            Divider().padding(.leading, 56)
            settingRow(icon: "trash.circle.fill", title: "Hapus Semua Data Pengguna", iconColor: .red, action: viewModel.confirmClearAllUserData)
        }
    }
    #endif

    private var appInfoSection: some View {
        SectionView(title: "Tentang Aplikasi") {
            settingRow(icon: "info.circle.fill", title: viewModel.appVersion, isStatic: true, action: {})
            Divider().padding(.leading, 56)
            settingRow(icon: "doc.text.fill", title: "Ketentuan Penggunaan", action: viewModel.termsTapped)
            Divider().padding(.leading, 56)
            settingRow(icon: "hand.raised.fill", title: "Kebijakan Privasi", action: viewModel.privacyPolicyTapped)
        }
    }

    // Helper for creating consistent setting rows
    private func settingRow(
        icon: String, title: String,
        iconColor: Color = Color("AppOrange"),
        isStatic: Bool = false, // For rows that don't navigate or perform actions
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .frame(width: 36, alignment: .center) // Centered icon
                    .padding(.leading, 10)

                Text(title)
                    .font(.appFont(.rethinkRegular, size: 16))
                    .foregroundColor(.black.opacity(0.8)) // Slightly less stark black

                Spacer()

                if !isStatic { // Only show chevron if it's an actionable row
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray.opacity(0.7))
                        .padding(.trailing)
                }
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle for list-like rows
        .disabled(isStatic) // Disable button interaction for static rows
    }
    
    // Helper for section container
    private struct SectionView<Content: View>: View {
        let title: String
        @ViewBuilder let content: Content

        var body: some View {
            VStack(alignment: .leading, spacing: 8) { // Increased spacing
                Text(title)
                    .font(.appFont(.rethinkBold, size: 18))
                    .padding(.leading, 12) // Align with content
                    .foregroundColor(Color("AppOrange"))
                
                VStack(spacing: 0) { // No spacing between rows within the card
                    content
                }
                .background(
                    RoundedRectangle(cornerRadius: 12) // Slightly less rounded for inner card
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
                )
            }
        }
    }
}