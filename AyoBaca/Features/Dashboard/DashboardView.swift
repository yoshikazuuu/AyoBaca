//
//  DashboardView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI
import TipKit

struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            // Background extends edge-to-edge
            Image("home")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Content stays within safe area
            VStack(spacing: 12) {
                topNavigation
                
                VStack(spacing: 10) {
                    profileCard
                        .popoverTip(
                            viewModel.mainTips.currentTip as? ProfileTip,
                            arrowEdge: .top
                        )
                    
                    mascotStreakCard
                        .popoverTip(
                            viewModel.mainTips.currentTip as? StreakTip,
                            arrowEdge: .top
                        )
                }
                
                Spacer()
                
                startPracticeButton
                    .popoverTip(
                        viewModel.mainTips.currentTip as? PracticeButtonTip,
                        arrowEdge: .top
                    )
                    .padding(.bottom, 20)
            }
            .padding(.horizontal)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 80) }
            .safeAreaInset(edge: .top) { Color.clear.frame(height: 40) }
        }
    }

    private var profileCard: some View {
        HStack(alignment: .center, spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.5))
                    .frame(width: 100, height: 100)

                Image("mascot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            }
            .frame(width: 100, height: 100)

            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.childName)
                    .font(.appFont(.dylexicBold, size: 20))
                    .foregroundColor(Color("AppOrange"))

                Text("\(viewModel.childAge) tahun")
                    .font(.appFont(.dylexicBold, size: 16))
                    .foregroundColor(Color(red: 0.67, green: 0.21, blue: 0.06))
            }
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 25)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        .padding(.horizontal)
    }

    private var mascotStreakCard: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .foregroundColor(
                    viewModel.currentStreak > 0
                        ? .orange
                        : (Color(red: 0.47, green: 0.31, blue: 0.25))
                            .opacity(0.7)
                )
            Text("\(viewModel.currentStreak) Streak")
        }
        .font(.appFont(.dylexicBold, size: 14))
        .foregroundColor(
            (Color(red: 0.47, green: 0.31, blue: 0.25)).opacity(0.7)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.white)
                .shadow(
                    color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2
                )
        )
    }

    private var startPracticeButton: some View {
        Button {
            viewModel.mapButtonTapped()
        } label: {
            Text("Mulai Latihan")
                .font(.appFont(.dylexicBold, size: 18))
                .foregroundColor(Color(red: 0.47, green: 0.31, blue: 0.25))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color("AppYellow"))
                .cornerRadius(30)
                .shadow(
                    color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4
                )
        }
        .padding(.horizontal, 80)
    }

    private var topNavigation: some View {
        HStack {
            Spacer()
            navigationButton(
                systemImage: "person.fill",
                accessibilityLabel: "Profil Pengguna",
                tip: viewModel.mainTips.currentTip as? ProfileButtonTip,
                action: viewModel.profileButtonTapped
            )
        }
        .padding(.horizontal, 20)
    }

    private func navigationButton<T: Tip>(
        systemImage: String,
        accessibilityLabel: String,
        tip: T?,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color("AppOrange"))
                .frame(width: 55, height: 55)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(
                            color: Color.black.opacity(0.15),
                            radius: 4, x: 0, y: 2
                        )
                )
        }
        .accessibilityLabel(Text(accessibilityLabel))
        .popoverTip(tip, arrowEdge: .top)
    }
}

#Preview {
    DashboardView(
        viewModel: DashboardViewModel(appStateManager: AppStateManager())
    )
}
