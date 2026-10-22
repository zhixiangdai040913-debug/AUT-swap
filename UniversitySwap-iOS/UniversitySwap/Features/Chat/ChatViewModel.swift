import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
    static let reportReasons = [
        "Scam or fraud",
        "Item not as described",
        "Inappropriate messages",
        "Spam",
        "Something else"
    ]

    let conversationId: String
    @Published var draft = ""
    @Published var isShowingReportOptions = false
    @Published var isShowingReportConfirmation = false
    @Published var isShowingBlockConfirmation = false

    init(conversationId: String) {
        self.conversationId = conversationId
    }

    var listingId: String? {
        let prefix = "listing-"
        guard conversationId.hasPrefix(prefix) else { return nil }
        return String(conversationId.dropFirst(prefix.count))
    }

    var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func send(using store: ChatStore) {
        guard canSend else { return }
        store.send(draft, to: conversationId)
        draft = ""
    }

    func report(reason: String, using store: ChatStore) {
        store.report(conversationId)
        isShowingReportConfirmation = true
    }

    func timeLabel(for date: Date) -> String {
        Self.timeFormatter.string(from: date)
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
