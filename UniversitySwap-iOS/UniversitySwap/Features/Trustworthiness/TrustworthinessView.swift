import SwiftUI

struct TrustworthinessView: View {
    @StateObject private var viewModel: TrustworthinessViewModel

    private let horizontalPadding: CGFloat = 18
    private let avatarSize: CGFloat = 46
    private let avatarPalette: [(background: Color, tint: Color)] = [
        (Color(hex: 0xFFEBDD), Color(hex: 0xE8730C)),
        (Color(hex: 0xE6EEFF), Color(hex: 0x3F63D6)),
        (Color(hex: 0xE3F6E8), Color(hex: 0x2E9C4D)),
        (Color(hex: 0xF1E8FF), Color(hex: 0x7A4FD6)),
        (Color(hex: 0xFDE7EA), Color(hex: 0xD6455B))
    ]

    init(userId: String) {
        _viewModel = StateObject(wrappedValue: TrustworthinessViewModel(userId: userId))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                scoreCard
                    .padding(.top, 8)
                sentimentCounts
                    .padding(.top, 20)
                Text("Recent Reviews")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.top, 28)
                reviewList
                    .padding(.top, 6)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.bottom, 28)
        }
        .background(Color.white)
        .navigationTitle("Trustworthiness")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
    }

    // MARK: - Score

    private var scoreCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "star.fill")
                .font(.system(size: 34))
                .foregroundColor(AppTheme.starYellow)
            Text(viewModel.scoreText)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            Text(viewModel.basedOnText)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textTertiary)
                .padding(.top, 6)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Trustworthiness score \(viewModel.scoreText) out of 5, \(viewModel.basedOnText)")
    }

    private var sentimentCounts: some View {
        HStack(spacing: 0) {
            countColumn(value: viewModel.positiveCount, label: "Positive", accent: AppTheme.brandOrange)
            verticalDivider
            countColumn(value: viewModel.neutralCount, label: "Neutral", accent: AppTheme.textPrimary)
            verticalDivider
            countColumn(value: viewModel.negativeCount, label: "Negative", accent: AppTheme.textPrimary)
        }
        .padding(.vertical, 4)
    }

    private func countColumn(value: Int, label: String, accent: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(accent)
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var verticalDivider: some View {
        Rectangle()
            .fill(AppTheme.divider)
            .frame(width: 1, height: 40)
    }

    // MARK: - Reviews

    @ViewBuilder
    private var reviewList: some View {
        if viewModel.reviews.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "star.bubble")
                    .font(.system(size: 30))
                    .foregroundColor(AppTheme.icon)
                Text("No reviews yet")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        } else {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.reviews) { review in
                    reviewRow(review)
                    if review.id != viewModel.reviews.last?.id {
                        Rectangle()
                            .fill(AppTheme.divider)
                            .frame(height: 1)
                            .padding(.leading, avatarSize + 14)
                    }
                }
            }
        }
    }

    private func reviewRow(_ review: Review) -> some View {
        let isExpanded = viewModel.isExpanded(review)
        return Button {
            withAnimation(.easeOut(duration: 0.2)) {
                viewModel.toggleExpanded(review)
            }
        } label: {
            HStack(alignment: .top, spacing: 14) {
                avatar(for: review)

                VStack(alignment: .leading, spacing: 4) {
                    Text(review.reviewerName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text(viewModel.relativeTime(for: review.createdAt))
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textTertiary)
                    stars(for: review.rating)
                        .padding(.top, 1)
                    Text(review.text)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(isExpanded ? nil : 2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 2)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.icon)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .frame(height: avatarSize)
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(review.reviewerName), \(review.rating) out of 5 stars, \(viewModel.relativeTime(for: review.createdAt)). \(review.text)")
    }

    private func avatar(for review: Review) -> some View {
        let colors = avatarPalette[review.reviewerName.unicodeScalars.reduce(0) { $0 + Int($1.value) } % avatarPalette.count]
        return Circle()
            .fill(colors.background)
            .frame(width: avatarSize, height: avatarSize)
            .overlay(
                Text(review.reviewerInitials)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(colors.tint)
            )
    }

    private func stars(for rating: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: 12))
                    .foregroundColor(index <= rating ? AppTheme.starYellow : AppTheme.border)
            }
        }
    }
}

struct TrustworthinessView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TrustworthinessView(userId: MockSellers.alex.id)
        }
    }
}
