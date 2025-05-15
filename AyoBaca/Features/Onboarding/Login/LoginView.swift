//
//  LoginView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 04/04/25.
//
import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case email, password
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppOrange").ignoresSafeArea()
                FloatingAlphabetBackground(
                    count: 25, fontStyle: .dylexicRegular)

                ScrollView {
                    VStack(spacing: 0) {
                        VStack(spacing: 22) {
                            HStack {
                                Text("Don't have an account?")
                                    .font(.appFont(.rethinkRegular, size: 14))
                                    .foregroundColor(.gray)
                                Button("Sign Up") { viewModel.signUpTapped() }
                                    .font(.appFont(.rethinkBold, size: 14))
                                    .foregroundColor(Color("AppOrange"))
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Email")
                                    .font(.appFont(.rethinkRegular, size: 12))
                                    .foregroundColor(.gray)
                                    .padding(.leading, 2)
                                TextField(
                                    "parent@gmail.com",
                                    text: $viewModel.email)
                                    .font(.appFont(.rethinkRegular, size: 16))
                                    .foregroundColor(.black)
                                    .padding(12)
                                    .background(Color.gray.opacity(0.08))
                                    .cornerRadius(12)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .focused($focusedField, equals: .email)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .password }
                            }
                            .opacity(viewModel.animateFields ? 1 : 0)
                            .offset(y: viewModel.animateFields ? 0 : 10)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Password")
                                    .font(.appFont(.rethinkRegular, size: 12))
                                    .foregroundColor(.gray)
                                    .padding(.leading, 2)
                                HStack {
                                    Group {
                                        if viewModel.isPasswordVisible {
                                            TextField(
                                                "Password",
                                                text: $viewModel.password)
                                        } else {
                                            SecureField(
                                                "Password",
                                                text: $viewModel.password)
                                        }
                                    }
                                    .font(.appFont(.rethinkRegular, size: 16))
                                    .focused($focusedField, equals: .password)
                                    .foregroundColor(.black)
                                    .submitLabel(.done)
                                    .onSubmit { focusedField = nil }

                                    Button {
                                        viewModel.isPasswordVisible.toggle()
                                    } label: {
                                        Image(
                                            systemName: viewModel
                                                .isPasswordVisible
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
                            .opacity(viewModel.animateFields ? 1 : 0)
                            .offset(y: viewModel.animateFields ? 0 : 10)

                            HStack {
                                Button {
                                    viewModel.rememberMe.toggle()
                                    focusedField = nil
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(
                                            systemName: viewModel.rememberMe
                                                ? "checkmark.square.fill"
                                                : "square")
                                            .foregroundColor(
                                                viewModel.rememberMe
                                                    ? Color("AppOrange")
                                                    : .gray)
                                            .font(.system(size: 16))
                                        Text("Remember me")
                                            .font(.appFont(
                                                .rethinkRegular, size: 13))
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                                Button {
                                    viewModel.forgotPasswordTapped()
                                    focusedField = nil
                                } label: {
                                    Text("Forgot Password?")
                                        .font(.appFont(.rethinkBold, size: 13))
                                        .foregroundColor(Color("AppOrange"))
                                }
                            }
                            .opacity(viewModel.animateFields ? 1 : 0)

                            Button {
                                focusedField = nil
                                viewModel.loginTapped()
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
                            .opacity(viewModel.animateButtons ? 1 : 0)
                            .scaleEffect(viewModel.animateButtons ? 1 : 0.95)

                            HStack {
                                Rectangle().fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                                Text("Or")
                                    .font(.appFont(.rethinkRegular, size: 14))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 10)
                                Rectangle().fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 5)
                            .opacity(viewModel.animateButtons ? 1 : 0)

                            VStack(spacing: 12) {
                                Button { viewModel.continueWithGoogle() } label: {
                                    HStack {
                                        Image("google_logo").resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                        Text("Continue with Google")
                                            .font(.appFont(
                                                .rethinkRegular, size: 15))
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
                                                lineWidth: 1))
                                }
                                Button { viewModel.continueWithFacebook() } label: {
                                    HStack {
                                        Image("facebook_logo").resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                        Text("Continue with Facebook")
                                            .font(.appFont(
                                                .rethinkRegular, size: 15))
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.vertical, 14)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(
                                        red: 0.25, green: 0.4, blue: 0.7))
                                    .cornerRadius(12)
                                }
                            }
                            .opacity(viewModel.animateButtons ? 1 : 0)
                            .offset(y: viewModel.animateButtons ? 0 : 10)
                        }
                        .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .shadow(
                                    color: Color.black.opacity(0.08),
                                    radius: 10, x: 0, y: 5))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        .offset(y: viewModel.animateForm ? 0 : 30)
                        .opacity(viewModel.animateForm ? 1 : 0)
                    }
                    .frame(minHeight: geometry.size.height)
                }
                .onTapGesture { focusedField = nil }
            }
        }
        .onAppear {
            viewModel.onAppearActions()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                focusedField = .email
            }
        }
    }
}
