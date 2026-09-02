import AudioToolbox
import AudioUnit
import Foundation

public enum SpatialOutputDeviceKind {
    case headphones
    case builtInSpeakers
    case externalSpeakers

    public var audioUnitValue: UInt32 {
        switch self {
        case .headphones:
            return AUSpatialMixerOutputType.spatialMixerOutputType_Headphones.rawValue
        case .builtInSpeakers:
            return AUSpatialMixerOutputType.spatialMixerOutputType_BuiltInSpeakers.rawValue
        case .externalSpeakers:
            return AUSpatialMixerOutputType.spatialMixerOutputType_ExternalSpeakers.rawValue
        }
    }

    /// Picks the spatial profile for an output device.
    ///
    /// `transportType` is the device's `kAudioDevicePropertyTransportType`. Name matching
    /// runs first because it is the more specific signal, but it cannot see a renamed
    /// device: AirPods renamed in Settings carry no keyword in either the name or the UID
    /// (which is just a Bluetooth MAC address). The transport type is what catches those.
    public static func infer(
        deviceName: String,
        deviceUID: String,
        transportType: UInt32? = nil
    ) -> SpatialOutputDeviceKind {
        let haystack = "\(deviceName) \(deviceUID)".lowercased()

        if haystack.contains("airpods") ||
            haystack.contains("headphones") ||
            haystack.contains("headphone") ||
            haystack.contains("headset") ||
            haystack.contains("beats") ||
            haystack.contains("earbuds") ||
            haystack.contains("buds") {
            return .headphones
        }

        if haystack.contains("builtinspeaker") ||
            haystack.contains("built-in speaker") ||
            haystack.contains("built in speaker") ||
            haystack.contains("macbook") {
            return .builtInSpeakers
        }

        switch transportType {
        // ponytail: a Bluetooth *speaker* lands here too and gets the headphone profile.
        // Bluetooth output on a Mac is overwhelmingly headphones, and the old behaviour
        // (external speakers for every renamed pair) was wrong more often. Read the
        // device's Bluetooth Class of Device here if that trade ever stops holding.
        case kAudioDeviceTransportTypeBluetooth?, kAudioDeviceTransportTypeBluetoothLE?:
            return .headphones
        case kAudioDeviceTransportTypeBuiltIn?:
            return .builtInSpeakers
        default:
            return .externalSpeakers
        }
    }
}
