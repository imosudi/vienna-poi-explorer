import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section("Status") {
                    Label(
                        appState.isNetworkAvailable ? "Network available" : "Network unavailable",
                        systemImage: appState.isNetworkAvailable ? "wifi" : "wifi.slash"
                    )

                    Label(
                        appState.locationStatus == .authorizedWhenInUse || appState.locationStatus == .authorizedAlways
                            ? "Location access granted"
                            : "Location permission unavailable",
                        systemImage: "location"
                    )
                }

                Section("Overview") {
                    Text(appState.statusMessage)
                        .foregroundStyle(.secondary)
                }

                if appState.pois.isEmpty == false {
                    Section("Points of interest") {
                        ForEach(appState.pois.prefix(5)) { poi in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(poi.name)
                                    .font(.headline)
                                if let category = poi.category {
                                    Text(category)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                if let address = poi.address {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Vienna POI Explorer")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await appState.refreshPOIs() }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .disabled(appState.isLoading)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    ContentView()
        .environmentObject(AppState())
}
#endif
