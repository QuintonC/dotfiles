#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Screen Resolution
// @raycast.mode silent

// Optional parameters:
// @raycast.icon 🖥️
// @raycast.argument1 { "type": "dropdown", "placeholder": "Direction", "data": [{"title": "Up (4K - 3840x2160 @ 144Hz)", "value": "up"}, {"title": "Down (3008x1692 HiDPI @ 120Hz)", "value": "down"}] }

// Documentation:
// @raycast.description Switch screen resolution between 4K and lower resolution for pair programming
// @raycast.author quinton
// @raycast.authorURL https://raycast.com/quinton

import Foundation
import CoreGraphics

struct Resolution {
    let width: Int
    let height: Int

    func matches(_ mode: CGDisplayMode) -> Bool {
        return Int(mode.width) == width && Int(mode.height) == height
    }
}

enum ResolutionError: Error {
    case alreadySet(width: Int, height: Int, refreshRate: Int)
    case displayModesUnavailable
    case resolutionNotSupported(width: Int, height: Int)
    case configurationFailed
    case applyChangesFailed
    case invalidArgument

    var message: String {
        switch self {
        case .alreadySet(let width, let height, let refreshRate):
            return "Display is already at \(width)×\(height) @ \(refreshRate)Hz"
        case .displayModesUnavailable:
            return "Could not get display modes"
        case .resolutionNotSupported(let width, let height):
            return "\(width)×\(height) is not supported"
        case .configurationFailed:
            return "Could not configure display"
        case .applyChangesFailed:
            return "Could not apply changes"
        case .invalidArgument:
            return "Invalid argument: use 'up' or 'down'"
        }
    }
}

struct ResolutionSuccess {
    let width: Int
    let height: Int
    let refreshRate: Int
    let isHiDPI: Bool
    let direction: String

    var message: String {
        let dpiStatus = isHiDPI ? "HiDPI" : "Standard"
        return "\(width)×\(height) @ \(refreshRate)Hz (\(dpiStatus))"
    }
}

let resolution4K = Resolution(width: 3840, height: 2160)
let resolutionLower = Resolution(width: 3008, height: 1692)

func showNotification(result: Result<ResolutionSuccess, ResolutionError>) {
    let (title, message, soundName) = switch result {
    case .success(let info):
        (
            "\(info.direction == "up" ? "↑" : "↓") Display resolution changed",
            info.message,
            "Glass"
        )
    case .failure(let error):
        (
            "Set resolution failed",
            error.message,
            "Basso"
        )
    }

    // Escape quotes for AppleScript
    let escapedMessage = message.replacingOccurrences(of: "\"", with: "\\\"")
    let escapedTitle = title.replacingOccurrences(of: "\"", with: "\\\"")

    let script = "display notification \"\(escapedMessage)\" with title \"\(escapedTitle)\" sound name \"\(soundName)\""

    // Use Process for notification delivery (don't wait for completion)
    let task = Process()
    task.launchPath = "/usr/bin/osascript"
    task.arguments = ["-e", script]

    do {
        try task.run()
        // Don't wait - let notification show asynchronously
    } catch {
        print("Failed to show notification: \(error)")
    }
}

func findBestMode(for resolution: Resolution, from modes: [CGDisplayMode]) -> CGDisplayMode? {
    var bestMode: CGDisplayMode?
    var bestIsHiDPI = false
    var bestRefreshRate: Double = 0

    // Single pass to find best mode
    for mode in modes {
        guard mode.width == resolution.width && mode.height == resolution.height else { continue }

        let isHiDPI = (mode.pixelWidth == mode.width * 2) && (mode.pixelHeight == mode.height * 2)
        let refreshRate = mode.refreshRate

        // Update best if: first match, or HiDPI preference, or better refresh rate
        if bestMode == nil ||
           (isHiDPI && !bestIsHiDPI) ||
           (isHiDPI == bestIsHiDPI && refreshRate > bestRefreshRate) {
            bestMode = mode
            bestIsHiDPI = isHiDPI
            bestRefreshRate = refreshRate
        }
    }

    return bestMode
}

func setResolution(_ resolution: Resolution, direction: String) -> Result<ResolutionSuccess, ResolutionError> {
    let mainDisplay = CGMainDisplayID()

    // Get all display modes once (including current mode check)
    let options: CFDictionary = [
        kCGDisplayShowDuplicateLowResolutionModes: kCFBooleanTrue
    ] as CFDictionary

    guard let modes = CGDisplayCopyAllDisplayModes(mainDisplay, options) as? [CGDisplayMode],
          let currentMode = CGDisplayCopyDisplayMode(mainDisplay) else {
        print("❌ Failed to get display modes")
        return .failure(.displayModesUnavailable)
    }

    // Check if already at target resolution
    if resolution.matches(currentMode) {
        let refreshRate = currentMode.refreshRate > 0 ? Int(currentMode.refreshRate) : 60
        print("❌ Already at \(resolution.width)x\(resolution.height) @ \(refreshRate)Hz")
        return .failure(.alreadySet(width: resolution.width, height: resolution.height, refreshRate: refreshRate))
    }

    guard let targetMode = findBestMode(for: resolution, from: modes) else {
        print("❌ Resolution \(resolution.width)x\(resolution.height) not available")
        return .failure(.resolutionNotSupported(width: resolution.width, height: resolution.height))
    }

    // Create display configuration
    var config: CGDisplayConfigRef?
    let beginError = CGBeginDisplayConfiguration(&config)

    guard beginError == .success else {
        print("❌ Failed to begin display configuration")
        return .failure(.configurationFailed)
    }

    let configError = CGConfigureDisplayWithDisplayMode(config, mainDisplay, targetMode, nil)

    guard configError == .success else {
        CGCancelDisplayConfiguration(config)
        print("❌ Failed to configure display")
        return .failure(.configurationFailed)
    }

    let commitError = CGCompleteDisplayConfiguration(config, .permanently)

    guard commitError == .success else {
        print("❌ Failed to commit display configuration")
        return .failure(.applyChangesFailed)
    }

    // Success
    let refreshRate = targetMode.refreshRate > 0 ? Int(targetMode.refreshRate) : 60
    let isHiDPI = (targetMode.pixelWidth == targetMode.width * 2) && (targetMode.pixelHeight == targetMode.height * 2)

    let success = ResolutionSuccess(
        width: resolution.width,
        height: resolution.height,
        refreshRate: refreshRate,
        isHiDPI: isHiDPI,
        direction: direction
    )

    print("✅ Resolution changed to \(success.message)")
    return .success(success)
}

// Main execution
guard CommandLine.arguments.count > 1 else {
    print("❌ No argument provided. Use 'up' or 'down'")
    showNotification(result: .failure(.invalidArgument))
    exit(1)
}

let direction = CommandLine.arguments[1].lowercased()

// Validate argument first (fail fast)
guard direction == "up" || direction == "down" else {
    print("❌ Invalid argument '\(direction)'. Use 'up' or 'down'")
    showNotification(result: .failure(.invalidArgument))
    exit(1)
}

let targetResolution = direction == "up" ? resolution4K : resolutionLower
let result = setResolution(targetResolution, direction: direction)

showNotification(result: result)

if case .failure = result {
    exit(1)
}
