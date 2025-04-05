//
//  LoginView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 04/04/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var isPasswordVisible = false

    // Animation states
    @State private var animateForm = false
    @State private var animateFields = false
    @State private var animateButtons = false

    // Focus state to handle keyboard
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case email, password
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color("AppOrange").ignoresSafeArea()
                FloatingAlphabetBackground(
                    count: 25, fontStyle: .dylexicRegular)

                ScrollView {
                    VStack(spacing: 0) {
                        // White Form Container with drop shadow and curved corners
                        VStack(spacing: 22) {
                            // Sign Up Link
                            HStack {
                                Text("Don't have an account?")
                                    .font(.appFont(.rethinkRegular, size: 14))
                                    .foregroundColor(.gray)
                                Button("Sign Up") {
                                    print("Sign Up Tapped")
                                }
                                .font(.appFont(.rethinkBold, size: 14))
                                .foregroundColor(Color("AppOrange"))
                            }

                            // Email Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Email")
                                    .font(.appFont(.rethinkRegular, size: 12))
                                    .foregroundColor(.gray)
                                    .padding(.leading, 2)
                                TextField("parent@gmail.com", text: $email)
                                    .font(.appFont(.rethinkRegular, size: 16))
                                    .foregroundColor(.black)
                                    .padding(12)
                                    .background(Color.gray.opacity(0.08))
                                    .cornerRadius(12)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .focused($focusedField, equals: .email)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .password
                                    }
                            }
                            .opacity(animateFields ? 1 : 0)
                            .offset(y: animateFields ? 0 : 10)

                            // Password Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Password")
                                    .font(.appFont(.rethinkRegular, size: 12))
                                    .foregroundColor(.gray)
                                    .padding(.leading, 2)
                                HStack {
                                    Group {
                                        if isPasswordVisible {
                                            TextField(
                                                "Password", text: $password)
                                        } else {
                                            SecureField(
                                                "Password", text: $password)
                                        }
                                    }
                                    .font(.appFont(.rethinkRegular, size: 16))
                                    .focused($focusedField, equals: .password)
                                    .foregroundColor(.black)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        focusedField = nil  // Dismiss keyboard
                                    }

                                    Button {
                                        isPasswordVisible.toggle()
                                    } label: {
                                        Image(
                                            systemName: isPasswordVisible
                                                ? "eye.slash.fill" : "eye.fill"
                                        )
                                        .foregroundColor(.gray)
                                        .frame(width: 24, height: 24)
                                    }
                                }
                                .padding(12)
                                .background(Color.gray.opacity(0.08))
                                .cornerRadius(12)
                            }
                            .opacity(animateFields ? 1 : 0)
                            .offset(y: animateFields ? 0 : 10)

                            // Remember Me & Forgot Password
                            HStack {
                                Button {
                                    rememberMe.toggle()
                                    // Dismiss keyboard on interaction
                                    focusedField = nil
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(
                                            systemName: rememberMe
                                                ? "checkmark.square.fill"
                                                : "square"
                                        )
                                        .foregroundColor(
                                            rememberMe
                                                ? Color("AppOrange") : .gray
                                        )
                                        .font(.system(size: 16))

                                        Text("Remember me")
                                            .font(
                                                .appFont(
                                                    .rethinkRegular, size: 13)
                                            )
                                            .foregroundColor(.gray)
                                    }
                                }

                                Spacer()

                                Button {
                                    print("Forgot Password Tapped")
                                    // Dismiss keyboard
                                    focusedField = nil
                                } label: {
                                    Text("Forgot Password?")
                                        .font(.appFont(.rethinkBold, size: 13))
                                        .foregroundColor(Color("AppOrange"))
                                }
                            }
                            .opacity(animateFields ? 1 : 0)

                            // Log In Button
                            Button {
                                // Dismiss keyboard
                                focusedField = nil
                                print("Log In Tapped: \(email), \(password)")

                                // Add simple validation
                                if !email.isEmpty && !password.isEmpty {
                                    withAnimation(
                                        .spring(
                                            response: 0.6, dampingFraction: 0.7)
                                    ) {
                                        appStateManager.currentScreen = .welcome
                                    }
                                }
                            } label: {
                                Text("Log In")
                                    .font(.appFont(.rethinkBold, size: 16))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 14)
                                    .frame(maxWidth: .infinity)
                                    .background(Color("AppOrange"))
                                    .cornerRadius(12)
                                    .shadow(
                                        color: Color("AppOrange").opacity(0.3),
                                        radius: 5, x: 0, y: 3)
                            }
                            .padding(.top, 5)
                            .opacity(animateButtons ? 1 : 0)
                            .scaleEffect(animateButtons ? 1 : 0.95)

                            // Divider
                            HStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)

                                Text("Or")
                                    .font(.appFont(.rethinkRegular, size: 14))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 10)

                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 5)
                            .opacity(animateButtons ? 1 : 0)

                            // Social Logins
                            VStack(spacing: 12) {
                                // Google login
                                Button {
                                    print("Continue with Google")
                                } label: {
                                    HStack {
                                        Image("google_logo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                        Text("Continue with Google")
                                            .font(
                                                .appFont(
                                                    .rethinkRegular,
                                                    size: 15
                                                )
                                            )
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.black.opacity(0.7))
                                    .padding(.vertical, 14)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                Color.gray.opacity(0.3),
                                                lineWidth: 1)
                                    )
                                }

                                // Facebook login
                                Button {
                                    print("Continue with Facebook")
                                } label: {
                                    HStack {
                                        Image("facebook_logo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                        Text("Continue with Facebook")
                                            .font(
                                                .appFont(
                                                    .rethinkRegular,
                                                    size: 15
                                                )
                                            )
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.vertical, 14)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        Color(red: 0.25, green: 0.4, blue: 0.7)
                                    )
                                    .cornerRadius(12)
                                }
                            }
                            .opacity(animateButtons ? 1 : 0)
                            .offset(y: animateButtons ? 0 : 10)
                        }
                        .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .shadow(
                                    color: Color.black.opacity(0.08),
                                    radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        .offset(y: animateForm ? 0 : 30)
                        .opacity(animateForm ? 1 : 0)
                    }
                    .frame(minHeight: geometry.size.height)
                }
                .onTapGesture {
                    // Dismiss keyboard when tapping outside input fields
                    focusedField = nil
                }
            }
        }
        .onAppear {
            // Sequence animations
            withAnimation(.easeOut(duration: 0.6)) {
                animateForm = true
            }

            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animateFields = true
            }

            withAnimation(
                .spring(response: 0.6, dampingFraction: 0.7).delay(0.4)
            ) {
                animateButtons = true
            }

            // Auto-focus email field after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                focusedField = .email
            }
        }
    }
}

#Preview {
    LoginView()
}
