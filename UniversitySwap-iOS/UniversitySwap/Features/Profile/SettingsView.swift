import SwiftUI

struct SettingsView: View {
    @AppStorage("settings.notifications") private var notificationsEnabled = true
    @AppStorage("settings.emailAlerts") private var emailAlertsEnabled = false

    var body: some View {
        List {
            Section("Preferences") {
                Toggle("Push Notifications", isOn: $notificationsEnabled)
                Toggle("Email Alerts", isOn: $emailAlertsEnabled)
            }

            Section("About") {
                HStack {
                    Text("App Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(AppTheme.textTertiary)
                }
                HStack {
                    Text("Campus")
                    Spacer()
                    Text("AUT")
                        .foregroundColor(AppTheme.textTertiary)
                }
            }

            Section {
                Text("University Swap is for verified AUT students and staff only. Payment is cash or bank transfer, offline.")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textTertiary)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
