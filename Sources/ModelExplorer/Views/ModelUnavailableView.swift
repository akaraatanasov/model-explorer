import SwiftUI

struct ModelUnavailableView: View {
    let status: ModelAvailabilityStatus
    var onEnableDemoMode: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: status.systemImage)
                .font(.system(size: 64))
                .foregroundStyle(iconColor)
            
            Text(status.title)
                .font(.title.bold())
            
            Text(status.message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 500)
            
            if status.canOpenSettings {
                Button("Open Settings") {
                    openSettings()
                }
                .buttonStyle(.borderedProminent)
            }
            
            if status == .modelNotReady {
                ProgressView()
                    .padding(.top, 8)
                Text("Checking availability...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Demo mode button for unsupported environments
            if let onEnableDemoMode {
                Divider()
                    .frame(maxWidth: 300)
                    .padding(.top, 8)
                
                VStack(spacing: 8) {
                    Text("Want to test the UI?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Button("Enable Demo Mode") {
                        onEnableDemoMode()
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var iconColor: Color {
        switch status {
        case .available:
            return .green
        case .deviceNotEligible:
            return .red
        case .appleIntelligenceNotEnabled:
            return .orange
        case .modelNotReady:
            return .blue
        case .runningInSimulator:
            return .purple
        }
    }
    
    private func openSettings() {
        #if os(macOS)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preferences.AppleIntelligence") {
            NSWorkspace.shared.open(url)
        }
        #else
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #endif
    }
}

#Preview("Running in Simulator") {
    ModelUnavailableView(status: .runningInSimulator)
}

#Preview("Device Not Eligible") {
    ModelUnavailableView(status: .deviceNotEligible)
}

#Preview("Apple Intelligence Disabled") {
    ModelUnavailableView(status: .appleIntelligenceNotEnabled)
}

#Preview("Model Not Ready") {
    ModelUnavailableView(status: .modelNotReady)
}
