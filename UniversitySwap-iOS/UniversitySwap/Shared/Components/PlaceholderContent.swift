import SwiftUI

struct PlaceholderContent: View {
    let title: String
    let systemImage: String
    /// Shown under the title. Defaults to a clear demo limitation note.
    var message: String = "Not included in this classroom demo."

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundColor(AppTheme.icon)
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
