import SwiftUI
import AppKit

private enum AUTTheme {
    static let orange = Color(red: 245 / 255, green: 130 / 255, blue: 32 / 255)
    static let orangeMid = Color(red: 220 / 255, green: 115 / 255, blue: 28 / 255)
    static let orangeDark = Color(red: 185 / 255, green: 85 / 255, blue: 18 / 255)
    static let logoBlack = Color.black
}

struct RootView: View {
    @StateObject private var cart = CartStore()
    @StateObject private var listingStore = ListingStore()
    @StateObject private var messageStore = MessageStore()
    @State private var screen: AppScreen = .welcome
    @State private var userEmail: String = ""

    enum AppScreen { case welcome, login, home }

    var body: some View {
        Group {
            switch screen {
            case .welcome:
                WelcomeView(onLoginTapped: { screen = .login })
            case .login:
                LoginView(
                    onBack: { screen = .welcome },
                    onLoginSuccess: { email in
                        userEmail = email
                        screen = .home
                    }
                )
            case .home:
                HomeView(
                    userEmail: userEmail,
                    cart: cart,
                    listingStore: listingStore,
                    messageStore: messageStore,
                    onLogout: {
                        userEmail = ""
                        screen = .welcome
                    }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { expandToMainScreen() }
    }

    private func expandToMainScreen() {
        DispatchQueue.main.async {
            guard let window = NSApp.keyWindow ?? NSApplication.shared.windows.first else { return }
            guard let screen = window.screen ?? NSScreen.main else { return }
            window.setFrame(screen.visibleFrame, display: true, animate: false)
        }
    }
}

struct WelcomeView: View {
    var onLoginTapped: () -> Void

    var body: some View {
        GeometryReader { geo in
            let logoSize = min(geo.size.width * 0.22, 140)
            ZStack {
                AUTTheme.orange.ignoresSafeArea()
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        AUTTheme.orangeDark.frame(height: 28)
                        AUTTheme.orangeMid.frame(height: 22)
                        AUTTheme.orange.frame(height: 18)
                    }.frame(width: geo.size.width)
                    Spacer()
                }.ignoresSafeArea(edges: .top)

                VStack(spacing: 28) {
                    Spacer().frame(height: geo.size.height * 0.12)
                    AUTLogoMark(size: logoSize)
                    VStack(spacing: 10) {
                        Text("Kia Ora").font(.system(size: 36, weight: .bold)).foregroundColor(.white)
                        Text("welcome to AUTswap").font(.system(size: 22)).foregroundColor(.white)
                    }
                    Button(action: onLoginTapped) {
                        HStack(spacing: 12) {
                            Text("LOGIN").font(.system(size: 16, weight: .bold)).foregroundColor(AUTTheme.orange)
                            ZStack {
                                Circle().fill(AUTTheme.orange).frame(width: 28, height: 28)
                                Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 36).padding(.vertical, 14)
                        .background(Color.white).clipShape(Capsule())
                    }.buttonStyle(PlainButtonStyle())
                    Spacer()
                    Text("AUTswap").font(.system(size: 14)).foregroundColor(Color.white.opacity(0.85)).padding(.bottom, 32)
                }.frame(width: geo.size.width, height: geo.size.height)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var keepSignedIn = false
    @State private var isLoading = false
    @State private var showLoginErrorAlert = false
    var onBack: () -> Void
    var onLoginSuccess: (String) -> Void
    private let loginErrorMessage = "Email or password is wrong. Please check your email/password format and try again."

    var body: some View {
        GeometryReader { geo in
            let logoSize = min(geo.size.width * 0.12, 80)
            ZStack {
                AUTTheme.orange.ignoresSafeArea()
                loginCard(logoSize: logoSize)
                    .frame(maxWidth: min(480, geo.size.width * 0.5))
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .alert(isPresented: $showLoginErrorAlert) {
            Alert(title: Text("Login Failed"), message: Text(loginErrorMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func loginCard(logoSize: CGFloat) -> some View {
        VStack(spacing: 0) {
            AUTLogoMark(size: logoSize).padding(.top, 28).padding(.bottom, 20)
            VStack(alignment: .leading, spacing: 6) {
                Text("Alumni:").font(.system(size: 14, weight: .semibold))
                Text("Sign in with your Student ID or Email").font(.system(size: 13)).foregroundColor(.secondary)
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 28).padding(.bottom, 12)

            VStack(spacing: 12) {
                TextField("name@autuni.ac.nz or name@aut.ac.nz", text: $email)
                    .textFieldStyle(PlainTextFieldStyle()).padding(10).background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                HStack(spacing: 8) {
                    Group {
                        if showPassword { TextField("Please enter your email password", text: $password) }
                        else { SecureField("Please enter your email password", text: $password) }
                    }.textFieldStyle(PlainTextFieldStyle())
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye").foregroundColor(AUTTheme.orange)
                    }.buttonStyle(PlainButtonStyle())
                }.padding(10).background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.gray.opacity(0.4), lineWidth: 1))
            }.padding(.horizontal, 28).padding(.bottom, 12)

            HStack {
                Button("Reset my password") {}.buttonStyle(PlainButtonStyle()).foregroundColor(.blue)
                Spacer()
                Toggle("Keep me signed in", isOn: $keepSignedIn).font(.system(size: 12))
            }.padding(.horizontal, 28).padding(.bottom, 20)

            Button(action: attemptLogin) {
                HStack {
                    if isLoading { ProgressView().scaleEffect(0.8) }
                    Text(isLoading ? "Signing In..." : "Sign In").fontWeight(.semibold)
                }.frame(maxWidth: .infinity).padding(.vertical, 12).foregroundColor(.white)
                    .background(Color.black).cornerRadius(4)
            }.buttonStyle(PlainButtonStyle()).disabled(!canAttemptLogin || isLoading)
                .padding(.horizontal, 28).padding(.bottom, 28)

            Button(action: onBack) { Text("Back").foregroundColor(.secondary) }
                .buttonStyle(PlainButtonStyle()).padding(.bottom, 16)
        }.background(Color.white)
    }

    private var canAttemptLogin: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }
    private func isEmailValid() -> Bool {
        let t = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let i = t.firstIndex(of: "@") else { return false }
        let local = String(t[..<i]), domain = String(t[t.index(after: i)...])
        return !local.isEmpty && !local.contains(" ") && (domain == "autuni.ac.nz" || domain == "aut.ac.nz")
    }
    private func isFormValid() -> Bool { isEmailValid() && !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private func attemptLogin() {
        guard canAttemptLogin else { return }
        guard isFormValid() else { showLoginErrorAlert = true; return }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            if isFormValid() { onLoginSuccess(email.trimmingCharacters(in: .whitespacesAndNewlines)) }
            else { showLoginErrorAlert = true }
        }
    }
}

struct AUTLogoMark: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            Rectangle().fill(AUTTheme.logoBlack).frame(width: size, height: size)
            AUTOutlinedText(text: "AUT", fontSize: size * 0.34)
        }.frame(width: size, height: size)
    }
}

struct AUTOutlinedText: View {
    let text: String; let fontSize: CGFloat
    var body: some View {
        let font = Font.system(size: fontSize, weight: .bold)
        ZStack {
            ForEach(0..<offsets.count, id: \.self) { i in
                Text(text).font(font).foregroundColor(.white)
                    .offset(x: offsets[i].width, y: offsets[i].height)
            }
            Text(text).font(font).foregroundColor(AUTTheme.logoBlack)
        }
    }
    private var offsets: [CGSize] {
        let d: CGFloat = 1.2
        return [CGSize(width:-d,height:0),CGSize(width:d,height:0),CGSize(width:0,height:-d),CGSize(width:0,height:d),
                CGSize(width:-d,height:-d),CGSize(width:d,height:-d),CGSize(width:-d,height:d),CGSize(width:d,height:d)]
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View { RootView().frame(width: 1440, height: 900) }
}
