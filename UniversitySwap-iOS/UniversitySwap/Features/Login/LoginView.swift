import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case email
        case password
    }

    private let horizontalPadding: CGFloat = 22

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                header
                titleBlock
                    .padding(.top, -14)
                form
                    .padding(.top, 28)
                footer
                    .padding(.top, 30)
                    .padding(.bottom, 40)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .background(Color.white.ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .onChange(of: viewModel.email) { _ in viewModel.clearError() }
        .onChange(of: viewModel.password) { _ in viewModel.clearError() }
    }

    // MARK: - Header

    private var header: some View {
        ZStack(alignment: .top) {
            LoginHeaderView(archDepth: 60)
            Image("AUTLogo")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 104, height: 104)
                .padding(.top, 62)
                .accessibilityLabel("AUT")
        }
        .frame(height: 248)
        .allowsHitTesting(false)
    }

    private var titleBlock: some View {
        VStack(spacing: 10) {
            Text("University Swap")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            Text("Buy · Swap · Give · Sell")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
            Text("For verified AUT students & staff")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textTertiary)
                .padding(.top, 4)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, horizontalPadding)
        .allowsHitTesting(false)
    }

    // MARK: - Form

    private var form: some View {
        VStack(spacing: 0) {
            emailField
            passwordField
                .padding(.top, 16)

            if let error = viewModel.error {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 14))
                    Text(error.message)
                        .font(.system(size: 13))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundColor(AppTheme.requiredRed)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
                .padding(.top, 10)
                .accessibilityElement(children: .combine)
            }

            Button(action: logIn) {
                ZStack {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Log In")
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

            Button("Forgot Password?") {}
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.brandOrange)
                .padding(.top, 16)

            HStack(spacing: 12) {
                Rectangle().fill(AppTheme.divider).frame(height: 1)
                Text("or")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textTertiary)
                Rectangle().fill(AppTheme.divider).frame(height: 1)
            }
            .padding(.top, 28)

            NavigationLink {
                RegisterView()
            } label: {
                Text("Sign Up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Capsule().fill(Color.white))
                    .overlay(Capsule().stroke(AppTheme.border, lineWidth: 1))
            }
            .padding(.top, 14)
        }
        .padding(.horizontal, horizontalPadding)
    }

    private var emailField: some View {
        HStack(spacing: 12) {
            Image(systemName: "envelope")
                .font(.system(size: 17))
                .foregroundColor(AppTheme.icon)
                .frame(width: 22)
            TextField(
                "",
                text: $viewModel.email,
                prompt: Text("Student or Staff AUT Email").foregroundColor(AppTheme.placeholder)
            )
            .font(.system(size: 15))
            .foregroundColor(AppTheme.textPrimary)
            .textContentType(.username)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.next)
            .focused($focusedField, equals: .email)
            .onSubmit { focusedField = .password }
        }
        .padding(.leading, 18)
        .padding(.trailing, 12)
        .frame(height: 50)
        .background(fieldBackground(isFocused: focusedField == .email, hasError: viewModel.error?.isEmailError == true))
    }

    private var passwordField: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock")
                .font(.system(size: 17))
                .foregroundColor(AppTheme.icon)
                .frame(width: 22)

            Group {
                if viewModel.isPasswordVisible {
                    TextField(
                        "",
                        text: $viewModel.password,
                        prompt: Text("Password").foregroundColor(AppTheme.placeholder)
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .password)
                } else {
                    SecureField(
                        "",
                        text: $viewModel.password,
                        prompt: Text("Password").foregroundColor(AppTheme.placeholder)
                    )
                    .focused($focusedField, equals: .password)
                }
            }
            .font(.system(size: 15))
            .foregroundColor(AppTheme.textPrimary)
            .textContentType(.password)
            .submitLabel(.go)
            .onSubmit(logIn)

            Button {
                viewModel.isPasswordVisible.toggle()
            } label: {
                Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.icon)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(viewModel.isPasswordVisible ? "Hide password" : "Show password")
        }
        .padding(.leading, 18)
        .padding(.trailing, 12)
        .frame(height: 50)
        .background(fieldBackground(isFocused: focusedField == .password, hasError: viewModel.error == .emptyPassword))
    }

    private func fieldBackground(isFocused: Bool, hasError: Bool) -> some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        hasError ? AppTheme.requiredRed : (isFocused ? AppTheme.brandOrange.opacity(0.6) : AppTheme.border),
                        lineWidth: 1
                    )
            )
    }

    private var footer: some View {
        Text(AppConfig.useSampleData
            ? "Phase 1 sample login — use any AUT email and password.\nListings on Home are sample data, not Firebase."
            : "Sign in with your AUT student or staff email\nto join the campus community.")
            .font(.system(size: 12))
            .foregroundColor(AppTheme.textTertiary)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .padding(.horizontal, horizontalPadding)
            .allowsHitTesting(false)
    }

    // MARK: - Actions

    private func logIn() {
        focusedField = nil
        Task {
            _ = await viewModel.performLogin(using: appState)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppState())
    }
}
