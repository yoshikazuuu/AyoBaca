//
//  LoginView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 04/04/25.
//


import SwiftUI

struct LoginView: View {
    @Binding var currentScreen: AppScreen
    @State private var email = "" // Example prefill: "parent@gmail.com"
    @State private var password = "" // Example prefill: "********"
    @State private var rememberMe = false
    @State private var isPasswordVisible = false // To toggle visibility

    var body: some View {
        ZStack {
            // Background with faded letters (complex, omitted for simplicity)
            Color("AppOrange").ignoresSafeArea()

            VStack {
                Spacer() // Push form down

                // White Form Container
                VStack(spacing: 15) {
                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                        Button("Sign Up") {
                            // TODO: Navigate to Sign Up Screen
                            print("Sign Up Tapped")
                        }
                        .foregroundColor(Color("AppOrange"))
                        .fontWeight(.bold)
                    }
                    .padding(.bottom, 20)

                    // Email Field
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Email").foregroundColor(.gray).font(.caption)
                        TextField("parent@gmail.com", text: $email)
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }

                    // Password Field
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Password").foregroundColor(.gray).font(.caption)
                        HStack {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(
                                    systemName: isPasswordVisible
                                        ? "eye.slash.fill" : "eye.fill"
                                )
                                .foregroundColor(.gray)
                            }
                        }
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }

                    // Remember Me & Forgot Password
                    HStack {
                        Button {
                            rememberMe.toggle()
                        } label: {
                            HStack {
                                Image(
                                    systemName: rememberMe
                                        ? "checkmark.square.fill"
                                        : "square"
                                )
                                .foregroundColor(
                                    rememberMe ? Color("AppOrange") : .gray
                                )
                                Text("Remember me")
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                            }
                        }
                        Spacer()
                        Button("Forgot Password?") {
                            // TODO: Handle Forgot Password
                            print("Forgot Password Tapped")
                        }
                        .foregroundColor(Color("AppOrange"))
                        .font(.footnote)
                        .fontWeight(.bold)
                    }

                    // Log In Button
                    Button {
                        // TODO: Implement Login Logic
                        print("Log In Tapped: \(email), \(password)")
                        // If login successful:
                        currentScreen = .welcome
                    } label: {
                        Text("Log In")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("AppOrange"))
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)

                    Text("Or")
                        .foregroundColor(.gray)
                        .font(.footnote)
                        .padding(.vertical, 10)

                    // Social Logins
                    Button {
                        // TODO: Implement Google Sign In
                        print("Continue with Google")
                    } label: {
                        HStack {
                            Image("google_logo") // Add a small google logo to Assets
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Continue with Google")
                        }
                        .fontWeight(.medium)
                        .foregroundColor(.black.opacity(0.7))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }

                    Button {
                        // TODO: Implement Facebook Sign In
                        print("Continue with Facebook")
                    } label: {
                        HStack {
                            Image("facebook_logo") // Add a small facebook logo to Assets
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Continue with Facebook")
                        }
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.25, green: 0.4, blue: 0.7)) // FB Blue
                        .cornerRadius(10)
                    }

                }
                .padding(30) // Padding inside the white box
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 5)
                .padding(.horizontal, 20) // Padding outside the white box

                Spacer() // Push form up
                Spacer() // Add more space at bottom if needed
            }
        }
        // Add dummy logos if you don't have real ones yet
        .onAppear {
            // Create dummy images if needed for preview/testing
            if UIImage(named: "google_logo") == nil {
                // Placeholder logic
                print(
                    "Add 'google_logo.png' and 'facebook_logo.png' to Assets"
                )
            }
        }
    }
}

#Preview {
    LoginView(currentScreen: .constant(.login))
}
