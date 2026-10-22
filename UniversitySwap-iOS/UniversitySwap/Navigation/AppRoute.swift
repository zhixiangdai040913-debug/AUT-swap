import SwiftUI

enum AppRoute: Hashable {
    case listingDetail(listingId: String)
    case chat(conversationId: String)
    case trustworthiness(userId: String)
}

extension View {
    func withAppRoutes() -> some View {
        navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .listingDetail(let listingId):
                ListingDetailView(listingId: listingId)
            case .chat(let conversationId):
                ChatView(conversationId: conversationId)
            case .trustworthiness(let userId):
                TrustworthinessView(userId: userId)
            }
        }
    }
}
