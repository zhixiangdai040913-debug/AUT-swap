import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case email
        case password
        case confirm
    }

    @State private var confirmPassword = ""
    @State private var localError: String?

    private let horizontalPadding: CGFloat = 22

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Create account")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.top, 12)

                Text(AppConfig.useSampleData
                    ? "Use your AUT student (@autuni.ac.nz) or staff (@aut.ac.nz) email. Phase 1 sample sign-up only — not saved to Firebase."
                    : "Use your AUT student (@autuni.ac.nz) or staff (@aut.ac.nz) email. Your account is stored with Firebase Authentication.")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.top, 8)

                field(
                    icon: "envelope",
                    isFocused: focusedField == .email
                ) {
                    TextField(
                        "",
                        text: $viewModel.email,
                        prompt: Text("AUT Email").foregroundColor(AppTheme.placeholder)
                    )
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
                }
                .padding(.top, 24)

                field(icon: "lock", isFocused: focusedField == .password) {
                    SecureField(
                        "",
                        text: $viewModel.password,
                        prompt: Text("Password (min 6 characters)").foregroundColor(AppTheme.placeholder)
                    )
                    .focused($focusedField, equals: .password)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .confirm }
                }
                .padding(.top, 14)

                field(icon: "lock", isFocused: focusedField == .confirm) {
                    SecureField(
                        "",
                        text: $confirmPassword,
                        prompt: Text("Confirm password").foregroundColor(AppTheme.placeholder)
                    )
                    .focused($focusedField, equals: .confirm)
                    .submitLabel(.go)
                    .onSubmit(register)
                }
                .padding(.top, 14)

                if let message = localError ?? viewModel.error?.message {
                    Text(message)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.requiredRed)
                        .padding(.top, 10)
                }

                Button(action: register) {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Sign Up")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Capsule().fill(AppTheme.brandOrange))
                }
                .disabled(viewModel.isLoading)
                .padding(.top, 28)

                Button("Already have an account? Log In") {
                    dismiss()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.brandOrange)
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.bottom, 32)
        }
        .background(Color.white)
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .onChange(of: viewModel.email) { _ in localError = nil }
        .onChange(of: viewModel.password) { _ in localError = nil }
        .onChange(of: confirmPassword) { _ in localError = nil }
    }

    private func field<Content: View>(
        icon: String,
        isFocused: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17))
                .foregroundColor(AppTheme.icon)
                .frame(width: 22)
            content()
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(.leading, 18)
        .padding(.trailing, 12)
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.fieldFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isFocused ? AppTheme.brandOrange.opacity(0.6) : AppTheme.border, lineWidth: 1)
        )
    }

    private func register() {
        focusedField = nil
        localError = nil

        guard viewModel.password == confirmPassword else {
            localError = "Passwords do not match."
            return
        }

        Task {
            _ = await viewModel.performRegister(using: appState)
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RegisterView()
        }
        .environmentObject(AppState())
    }
}
