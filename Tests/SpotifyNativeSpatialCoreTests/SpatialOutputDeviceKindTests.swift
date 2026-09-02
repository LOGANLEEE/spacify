import AudioToolbox
import Testing
@testable import SpotifyNativeSpatialCore

@Suite("Spatial output device selection")
struct SpatialOutputDeviceKindTests {
    @Test("AirPods are rendered with the headphone spatial profile")
    func airPodsUseHeadphones() {
        #expect(SpatialOutputDeviceKind.infer(deviceName: "Arya's AirPods Pro", deviceUID: "Bluetooth-AACP").audioUnitValue == SpatialOutputDeviceKind.headphones.audioUnitValue)
    }

    @Test("Built-in Mac speakers use the speaker spatial profile")
    func macBookSpeakersUseBuiltInSpeakers() {
        #expect(SpatialOutputDeviceKind.infer(deviceName: "MacBook Pro Speakers", deviceUID: "BuiltInSpeakerDevice").audioUnitValue == SpatialOutputDeviceKind.builtInSpeakers.audioUnitValue)
    }

    @Test("Unknown outputs default to external speakers")
    func unknownOutputUsesExternalSpeakers() {
        #expect(SpatialOutputDeviceKind.infer(deviceName: "Studio Display", deviceUID: "AppleDisplayAudio").audioUnitValue == SpatialOutputDeviceKind.externalSpeakers.audioUnitValue)
    }

    @Test("Renamed AirPods still use the headphone profile")
    func renamedAirPodsUseHeadphones() {
        // Reproduces a real report: AirPods renamed in Settings, so neither the device
        // name nor the UID (a Bluetooth MAC) contains a headphone keyword.
        #expect(SpatialOutputDeviceKind.infer(
            deviceName: "Jellybeans",
            deviceUID: "AA-BB-CC-DD-EE-FF:output",
            transportType: kAudioDeviceTransportTypeBluetooth
        ).audioUnitValue == SpatialOutputDeviceKind.headphones.audioUnitValue)
    }

    @Test("A renamed built-in output falls back to the speaker profile")
    func builtInTransportUsesBuiltInSpeakers() {
        #expect(SpatialOutputDeviceKind.infer(
            deviceName: "Desk",
            deviceUID: "BuiltInSpeakerDevice-renamed",
            transportType: kAudioDeviceTransportTypeBuiltIn
        ).audioUnitValue == SpatialOutputDeviceKind.builtInSpeakers.audioUnitValue)
    }

    @Test("An explicit headphone name still wins over the transport type")
    func nameWinsOverTransport() {
        #expect(SpatialOutputDeviceKind.infer(
            deviceName: "USB Headphones",
            deviceUID: "usb-dac",
            transportType: kAudioDeviceTransportTypeUSB
        ).audioUnitValue == SpatialOutputDeviceKind.headphones.audioUnitValue)
    }
}
