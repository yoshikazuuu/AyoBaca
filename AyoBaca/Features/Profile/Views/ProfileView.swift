//
//  ProfileView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 07/04/25.
//


// ProfileView.swift
import SwiftUI
import SwiftData

struct ProfileView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // State for showing confirmation dialogs
    @State private var showOnboardingResetAlert = false
    @State private var showProgressResetAlert = false
    @State private var showUserDataResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color("AppOrange").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        profileHeader
                        
                        // Settings Sections
                        generalSettingsSection
                        
                        // Debug Controls (only in DEBUG mode)
                        #if DEBUG
                        debugControlsSection
                        #endif
                        
                        // App Info
                        appInfoSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation {
                            // Go back to main app view
                            appStateManager.currentScreen = .mainApp
                        }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Kembali")
                        }
                        .foregroundColor(Color("AppOrange"))
                    }
                }
            }
            // Alerts for confirmations
            .alert("Reset Onboarding?", isPresented: $showOnboardingResetAlert) {
                Button("Batal", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    appStateManager.resetOnboarding()
                }
            } message: {
                Text("Ini akan mengembalikan aplikasi ke pengalaman pertama kali. Kamu perlu memasukkan data anak lagi.")
            }
            .alert("Reset Progres Karakter?", isPresented: $showProgressResetAlert) {
                Button("Batal", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    appStateManager.characterProgress.resetProgress()
                }
            } message: {
                Text("Ini akan menghapus semua huruf yang telah terbuka dan hanya menyisakan huruf A.")
            }
            .alert("Hapus Semua Data?", isPresented: $showUserDataResetAlert) {
                Button("Batal", role: .cancel) {}
                Button("Hapus", role: .destructive) {
                    Task {
                        await clearAllUserData()
                        appStateManager.resetOnboarding()
                    }
                }
            } message: {
                Text("Ini akan menghapus semua data pengguna dan kemajuan belajar. Tindakan ini tidak dapat dibatalkan.")
            }
        }
    }
    
    // MARK: - UI Components
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile image
            ZStack {
                Circle()
                    .fill(Color("AppOrange").opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image("mascot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
            }
            
            // User info
            VStack(spacing: 4) {
                Text(appStateManager.userProfile?.childName ?? "Anak")
                    .font(.appFont(.dylexicBold, size: 24))
                    .foregroundColor(Color("AppOrange"))
                
                Text("\(appStateManager.userProfile?.childAge ?? 0) tahun")
                    .font(.appFont(.rethinkRegular, size: 16))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    private var generalSettingsSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Pengaturan Umum")
                .font(.appFont(.rethinkBold, size: 18))
                .padding(.leading, 8)
                .foregroundColor(Color("AppOrange"))
            
            VStack(spacing: 0) {
                settingRow(icon: "bell.fill", title: "Notifikasi", action: {
                    print("Notifications tapped")
                })
                
                Divider().padding(.leading, 56)
                
                settingRow(icon: "speaker.wave.2.fill", title: "Suara", action: {
                    print("Sound settings tapped")
                })
                
                Divider().padding(.leading, 56)
                
                settingRow(icon: "textformat.size", title: "Ukuran Font", action: {
                    print("Font size tapped")
                })
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
    }
    
    private var debugControlsSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Pengaturan Developer")
                .font(.appFont(.rethinkBold, size: 18))
                .padding(.leading, 8)
                .foregroundColor(.red)
            
            VStack(spacing: 0) {
                settingRow(
                    icon: "arrow.counterclockwise", 
                    title: "Reset Onboarding", 
                    iconColor: .red,
                    action: {
                        showOnboardingResetAlert = true
                    }
                )
                
                Divider().padding(.leading, 56)
                
                settingRow(
                    icon: "character", 
                    title: "Reset Kemajuan Karakter", 
                    iconColor: .red,
                    action: {
                        showProgressResetAlert = true
                    }
                )
                
                Divider().padding(.leading, 56)
                
                settingRow(
                    icon: "trash.fill", 
                    title: "Hapus Semua Data", 
                    iconColor: .red,
                    action: {
                        showUserDataResetAlert = true
                    }
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
    }
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Tentang Aplikasi")
                .font(.appFont(.rethinkBold, size: 18))
                .padding(.leading, 8)
                .foregroundColor(Color("AppOrange"))
            
            VStack(spacing: 0) {
                settingRow(icon: "info.circle.fill", title: "Versi 1.0.0", action: {})
                
                Divider().padding(.leading, 56)
                
                settingRow(icon: "doc.text.fill", title: "Ketentuan Penggunaan", action: {
                    print("Terms tapped")
                })
                
                Divider().padding(.leading, 56)
                
                settingRow(icon: "hand.raised.fill", title: "Kebijakan Privasi", action: {
                    print("Privacy tapped")
                })
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
    }
    
    // Helper for creating consistent setting rows
    private func settingRow(
        icon: String, 
        title: String, 
        iconColor: Color = Color("AppOrange"),
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .frame(width: 36, height: 36)
                    .padding(.leading, 10)
                
                Text(title)
                    .font(.appFont(.rethinkRegular, size: 16))
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Data Management Functions
    
    @MainActor
    private func clearAllUserData() async {
        do {
            // Delete UserProfile data
            try modelContext.delete(model: UserProfile.self)
            
            // Delete ReadingActivity data
            try modelContext.delete(model: ReadingActivity.self)
            
            // Reset character progress
            appStateManager.characterProgress.resetProgress()
            
            print("All user data cleared successfully")
        } catch {
            print("Error clearing user data: \(error)")
        }
    }
}

// Extension for SwiftData convenience
extension ModelContext {
    func delete<T: PersistentModel>(model: T.Type) throws {
        let descriptor = FetchDescriptor<T>()
        let items = try fetch(descriptor)
        for item in items {
            delete(item)
        }
        try save()
    }
}

// Preview
#Preview {
    // Create dummy data for preview
    let previewStateManager = AppStateManager()
    previewStateManager.userProfile = UserProfile(childName: "Budi", childAge: 7)
    
    return ProfileView()
        .environmentObject(previewStateManager)
        .modelContainer(AppModelContainer.preview)
}
