import Foundation
import FoundationModels

/// Provides detailed availability status for Apple Foundation Models
public enum ModelAvailabilityStatus: Sendable {
    case available
    case deviceNotEligible
    case appleIntelligenceNotEnabled
    case modelNotReady
    case runningInSimulator
    
    public static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    public init() {
        // Check simulator first - models never work there
        if Self.isSimulator {
            self = .runningInSimulator
            return
        }
        
        let availability = SystemLanguageModel.default.availability
        switch availability {
        case .available:
            self = .available
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible:
                self = .deviceNotEligible
            case .appleIntelligenceNotEnabled:
                self = .appleIntelligenceNotEnabled
            case .modelNotReady:
                self = .modelNotReady
            @unknown default:
                self = .deviceNotEligible
            }
        }
    }
    
    public var isAvailable: Bool {
        self == .available
    }
    
    public var title: String {
        switch self {
        case .available:
            return "Ready"
        case .deviceNotEligible:
            return "Device Not Eligible"
        case .appleIntelligenceNotEnabled:
            return "Apple Intelligence Disabled"
        case .modelNotReady:
            return "Models Not Ready"
        case .runningInSimulator:
            return "Simulator Not Supported"
        }
    }
    
    public var message: String {
        switch self {
        case .available:
            return "Apple Foundation Models are ready to use."
            
        case .runningInSimulator:
            return """
            Apple Foundation Models cannot run in the iOS/iPadOS Simulator.
            
            The simulator does not have access to the on-device machine learning models required for Foundation Models.
            
            To use this app:
            • Run on a physical iPhone 15 Pro or later
            • Run on a physical iPad with M-series chip
            • Run natively on a Mac with Apple Silicon
            """
            
        case .deviceNotEligible:
            return """
            This device cannot run Apple Foundation Models.
            
            Possible reasons:
            • Running macOS in a virtual machine (VMs are not supported)
            • Device doesn't have Apple Silicon (M1 or later required)
            • Insufficient device memory (8GB+ recommended)
            
            Foundation Models require a physical Apple Silicon Mac, iPhone 15 Pro or later, or iPad with M-series chip.
            """
            
        case .appleIntelligenceNotEnabled:
            return """
            Apple Intelligence is not enabled on this device.
            
            To enable:
            1. Open System Settings (or Settings on iOS)
            2. Go to "Apple Intelligence & Siri"
            3. Enable "Apple Intelligence"
            4. Wait for the initial setup to complete
            """
            
        case .modelNotReady:
            return """
            The Foundation Models are still being prepared.
            
            This usually means:
            • Models are currently downloading
            • Models are being installed after an update
            
            Please wait a few minutes and try again. You can check the download progress in System Settings > General > Storage.
            """
        }
    }
    
    public var systemImage: String {
        switch self {
        case .available:
            return "checkmark.circle.fill"
        case .deviceNotEligible:
            return "xmark.circle.fill"
        case .appleIntelligenceNotEnabled:
            return "gear.badge.xmark"
        case .modelNotReady:
            return "arrow.down.circle"
        case .runningInSimulator:
            return "desktopcomputer.trianglebadge.exclamationmark"
        }
    }
    
    public var canOpenSettings: Bool {
        switch self {
        case .appleIntelligenceNotEnabled:
            return true
        default:
            return false
        }
    }
}
