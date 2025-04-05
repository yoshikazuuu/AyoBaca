//
//  MainAppView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//


import SwiftUI
import SwiftData

struct MainAppView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    @Environment(\.modelContext) private var modelContext
    @Query private var readingActivities: [ReadingActivity]
    
    // State for test data creation
    @State private var showingAddBookSheet = false
    @State private var newBookTitle = ""
    @State private var readingDuration = 10
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppOrange").opacity(0.1).ignoresSafeArea()
                
                if let profile = appStateManager.userProfile {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Welcome header
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text("Selamat Datang,")
                                        .font(.appFont(.rethinkRegular, size: 18))
                                    
                                    Text(profile.childName)
                                        .font(.appFont(.dylexicBold, size: 28))
                                }
                                .foregroundColor(Color("AppOrange"))
                                
                                Spacer()
                                
                                // Child age badge
                                Text("\(profile.childAge) tahun")
                                    .font(.appFont(.rethinkBold, size: 14))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color("AppOrange").opacity(0.2))
                                    .foregroundColor(Color("AppOrange"))
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            // Mascot with speech bubble
                            HStack {
                                Spacer()
                                
                                ZStack(alignment: .top) {
                                    Text("Mau baca apa hari ini?")
                                        .font(.appFont(.rethinkRegular, size: 16))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.white)
                                        .cornerRadius(15)
                                        .offset(y: -30)
                                    
                                    Image("mascot-hi")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 120)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            
                            // Reading activity section
                            VStack(alignment: .leading) {
                                Text("Aktivitas Membaca")
                                    .font(.appFont(.rethinkBold, size: 20))
                                    .foregroundColor(Color("AppOrange"))
                                    .padding(.horizontal)
                                
                                if readingActivities.isEmpty {
                                    HStack {
                                        Spacer()
                                        Text("Belum ada aktivitas membaca")
                                            .font(.appFont(.rethinkRegular, size: 16))
                                            .foregroundColor(.gray)
                                            .padding()
                                        Spacer()
                                    }
                                } else {
                                    ForEach(readingActivities) { activity in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(activity.bookTitle)
                                                    .font(.appFont(.rethinkBold, size: 16))
                                                Text("\(activity.durationMinutes) menit")
                                                    .font(.appFont(.rethinkRegular, size: 14))
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            Text(activity.dateCompleted.formatted(date: .abbreviated, time: .omitted))
                                                .font(.appFont(.rethinkRegular, size: 14))
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            // Demo buttons
                            VStack {
                                Button {
                                    showingAddBookSheet = true
                                } label: {
                                    HStack {
                                        Image(systemName: "book.fill")
                                        Text("Tambah Aktivitas Membaca")
                                    }
                                    .font(.appFont(.rethinkBold, size: 16))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color("AppOrange"))
                                    .cornerRadius(10)
                                }
                                
                                Button {
                                    appStateManager.resetOnboarding()
                                } label: {
                                    Text("Reset Onboarding (Testing)")
                                        .font(.appFont(.rethinkRegular, size: 14))
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                            }
                            .padding()
                        }
                    }
                } else {
                    // Error or loading state
                    VStack {
                        ProgressView()
                        Text("Loading profile...")
                            .font(.appFont(.rethinkRegular, size: 16))
                            .padding()
                    }
                }
            }
            .navigationTitle("AyoBaca")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddBookSheet) {
                // Add reading activity form
                VStack(spacing: 20) {
                    Text("Tambah Aktivitas Membaca")
                        .font(.appFont(.rethinkBold, size: 20))
                        .padding()
                    
                    TextField("Judul Buku", text: $newBookTitle)
                        .font(.appFont(.rethinkRegular, size: 16))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    Stepper("Durasi: \(readingDuration) menit", value: $readingDuration, in: 5...60, step: 5)
                        .font(.appFont(.rethinkRegular, size: 16))
                        .padding()
                    
                    Button {
                        addReadingActivity()
                        showingAddBookSheet = false
                    } label: {
                        Text("Simpan")
                            .font(.appFont(.rethinkBold, size: 16))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("AppOrange"))
                            .cornerRadius(10)
                    }
                    .disabled(newBookTitle.isEmpty)
                    .opacity(newBookTitle.isEmpty ? 0.5 : 1)
                }
                .padding()
                .presentationDetents([.height(300)])
            }
        }
    }
    
    private func addReadingActivity() {
        guard !newBookTitle.isEmpty, let profile = appStateManager.userProfile else { return }
        
        let newActivity = ReadingActivity(
            bookTitle: newBookTitle,
            durationMinutes: readingDuration,
            profile: profile
        )
        
        modelContext.insert(newActivity)
        
        // Reset form
        newBookTitle = ""
        readingDuration = 10
    }
}
