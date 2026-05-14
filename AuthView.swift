import SwiftUI

struct AuthGateView: View {
    @StateObject private var authManager = AuthManager()
    @StateObject private var propertyStore = PropertyStore()

    var body: some View {
        Group {
            if authManager.isSignedIn {
                SignedInView()
                    .environmentObject(authManager)
                    .environmentObject(propertyStore)
            } else {
                AuthView()
                    .environmentObject(authManager)
            }
        }
    }
}

struct SignedInView: View {
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        ContentView()
            .toolbar {
                if let account = authManager.signedInAccount {
                    ToolbarItem(placement: .automatic) {
                        Text(account.role == .admin ? "Admin" : account.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                ToolbarItem(placement: .automatic) {
                    Button("Logout") {
                        authManager.signOut()
                    }
                }
            }
    }
}

struct AuthView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var authMode: AuthMode = .signIn
    @State private var identifier = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var phoneNumber = ""
    @State private var birthday = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
    @State private var isPasswordVisible = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case identifier
        case fullName
        case phoneNumber
        case password
    }

    private var title: String {
        authMode == .signIn ? "Login" : "Sign Up"
    }

    private var buttonTitle: String {
        authMode == .signIn ? "Login" : "Create Account"
    }

    var body: some View {
        VStack(spacing: 22) {
            VStack(spacing: 8) {
                Text("Happy Home")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("REAL ESTATE AGENT")
                    .font(.caption)
                    .tracking(2)
                    .foregroundStyle(.secondary)
            }

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Picker("Mode", selection: $authMode) {
                Text("Login").tag(AuthMode.signIn)
                Text("Sign Up").tag(AuthMode.signUp)
            }
            .pickerStyle(.segmented)
            .onChange(of: authMode) { _ in
                focusedField = authMode == .signIn ? .identifier : .fullName
            }

            VStack(spacing: 14) {
                if authMode == .signUp {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Full Name")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("Enter your name", text: $fullName)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .fullName)
                            .onSubmit {
                                focusedField = .phoneNumber
                            }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Phone Number")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("Enter your phone number", text: $phoneNumber)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .phoneNumber)
                            .onSubmit {
                                focusedField = .identifier
                            }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Birthday")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("ID or Email")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("Enter your ID or email", text: $identifier)
                        .textContentType(.username)
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                    #endif
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .identifier)
                        .onSubmit {
                            focusedField = .password
                        }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Password")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Group {
                        if isPasswordVisible {
                            TextField("Enter your password", text: $password)
                        } else {
                            SecureField("Enter your password", text: $password)
                        }
                    }
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .password)
                    .onSubmit(submitAuth)
                }

                Toggle("Show password", isOn: $isPasswordVisible)
                    .toggleStyle(.checkbox)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: submitAuth) {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                        }

                        Text(buttonTitle)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.black)
                .disabled(authManager.isLoading)
            }

            if let message = authManager.message {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(authManager.isSignedIn ? .green : .secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
        .frame(width: 420, height: authMode == .signIn ? 520 : 720)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                focusedField = authMode == .signIn ? .identifier : .fullName
            }
        }
    }

    private func submitAuth() {
        Task {
            if authMode == .signIn {
                await authManager.signIn(identifier: identifier, password: password)
            } else {
                await authManager.signUp(
                    identifier: identifier,
                    password: password,
                    fullName: fullName,
                    phoneNumber: phoneNumber,
                    birthday: birthday
                )
            }
        }
    }
}

#if canImport(PreviewsMacros)
#Preview {
    AuthView()
        .environmentObject(AuthManager())
}
#endif
