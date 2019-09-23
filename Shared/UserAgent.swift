/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit
import UIKit

private extension WKWebView {
    func evaluate(script: String, completion: @escaping (Any?, Error?) -> Void) {
        var finished = false

        evaluateJavaScript(script) { (result, error) in
            if error == nil {
                if result != nil {
                    completion(result, nil)
                }
            } else {
                completion(nil, error)
            }
            finished = true
        }

        while !finished {
            RunLoop.current.run(mode: RunLoop.Mode.default, before: Date.distantFuture)
        }
    }
}

open class UserAgent {
    private static var defaults = UserDefaults(suiteName: AppInfo.sharedContainerIdentifier)!

    private static func clientUserAgent(prefix: String) -> String {
        return "\(prefix)/\(AppInfo.appVersion)b\(AppInfo.buildNumber) (\(DeviceInfo.deviceModel()); iPhone OS \(UIDevice.current.systemVersion)) (\(AppInfo.displayName))"
    }

    public static var syncUserAgent: String {
        return clientUserAgent(prefix: "Firefox-iOS-Sync")
    }

    public static var tokenServerClientUserAgent: String {
        return clientUserAgent(prefix: "Firefox-iOS-Token")
    }

    public static var fxaUserAgent: String {
        return clientUserAgent(prefix: "Firefox-iOS-FxA")
    }

    public static var defaultClientUserAgent: String {
        return clientUserAgent(prefix: "Firefox-iOS")
    }

    /**
     * Use this if you know that a value must have been computed before your
     * code runs, or you don't mind failure.
     */
    public static func cachedUserAgent(checkiOSVersion: Bool = true,
                                     checkFirefoxVersion: Bool = true,
                                     checkFirefoxBuildNumber: Bool = true) -> String? {
        let currentiOSVersion = UIDevice.current.systemVersion
        let lastiOSVersion = defaults.string(forKey: "LastDeviceSystemVersionNumber")

        let currentFirefoxBuildNumber = AppInfo.buildNumber
        let currentFirefoxVersion = AppInfo.appVersion
        let lastFirefoxVersion = defaults.string(forKey: "LastFirefoxVersionNumber")
        let lastFirefoxBuildNumber = defaults.string(forKey: "LastFirefoxBuildNumber")

        if let firefoxUA = defaults.string(forKey: "UserAgent") {
            if (!checkiOSVersion || (lastiOSVersion == currentiOSVersion))
                && (!checkFirefoxVersion || (lastFirefoxVersion == currentFirefoxVersion)
                && (!checkFirefoxBuildNumber || (lastFirefoxBuildNumber == currentFirefoxBuildNumber))) {
                return firefoxUA
            }
        }

        return nil
    }

    /**
     * This will typically return quickly, but can require creation of a UIWebView.
     * As a result, it must be called on the UI thread.
     */
    public static func defaultUserAgent() -> String {
        assert(Thread.current.isMainThread, "This method must be called on the main thread.")

        if let firefoxUA = UserAgent.cachedUserAgent(checkiOSVersion: true) {
            return firefoxUA
        }

        let webView = WKWebView()
        webView.loadHTMLString("<html></html>", baseURL: nil)

        let appVersion = AppInfo.appVersion
        let buildNumber = AppInfo.buildNumber
        let currentiOSVersion = UIDevice.current.systemVersion
        defaults.set(currentiOSVersion, forKey: "LastDeviceSystemVersionNumber")
        defaults.set(appVersion, forKey: "LastFirefoxVersionNumber")
        defaults.set(buildNumber, forKey: "LastFirefoxBuildNumber")

        var userAgent = ""
        // Synchronously get the UA, note this is called only once after install and then cached
        webView.evaluate(script: "navigator.userAgent") { (object, error) in
            if let ua = object as? String {
                userAgent = ua
            } else {
                print("Failed to get user agent.")
            }
        }

        // Extract the WebKit version and use it as the Safari version.
        let webKitVersionRegex = try! NSRegularExpression(pattern: "AppleWebKit/([^ ]+) ", options: [])

        let match = webKitVersionRegex.firstMatch(in: userAgent, options: [],
            range: NSRange(location: 0, length: userAgent.count))

        if match == nil {
            print("Error: Unable to determine WebKit version in UA.")
            return userAgent     // Fall back to Safari's.
        }

        let webKitVersion = (userAgent as NSString).substring(with: match!.range(at: 1))

        // Insert "FxiOS/<version>" before the Mobile/ section.
        let mobileRange = (userAgent as NSString).range(of: "Mobile/")
        if mobileRange.location == NSNotFound {
            print("Error: Unable to find Mobile section in UA.")
            return userAgent     // Fall back to Safari's.
        }

        let mutableUA = NSMutableString(string: userAgent)
        mutableUA.insert("FxiOS/\(appVersion)b\(AppInfo.buildNumber) ", at: mobileRange.location)

        let firefoxUA = "\(mutableUA) Safari/\(webKitVersion)"

        defaults.set(firefoxUA, forKey: "UserAgent")

        return firefoxUA
    }

    public static func isDesktop(ua: String) -> Bool {
        return ua.lowercased().contains("intel mac")
    }

    public static func desktopUserAgent() -> String {
        let userAgent = NSMutableString(string: defaultUserAgent())

        // Spoof platform section
        let platformRegex = try! NSRegularExpression(pattern: "\\([^\\)]+\\)", options: [])
        guard let platformMatch = platformRegex.firstMatch(in: userAgent as String, options: [], range: NSRange(location: 0, length: userAgent.length)) else {
            print("Error: Unable to determine platform in UA.")
            return String(userAgent)
        }
        userAgent.replaceCharacters(in: platformMatch.range, with: "(Macintosh; Intel Mac OS X 10_11_1)")

        // Strip mobile section
        let mobileRegex = try! NSRegularExpression(pattern: " FxiOS/[^ ]+ Mobile/[^ ]+", options: [])

        guard let mobileMatch = mobileRegex.firstMatch(in: userAgent as String, options: [], range: NSRange(location: 0, length: userAgent.length)) else {
            print("Error: Unable to find Mobile section in UA.")
            return String(userAgent)
        }

        // The iOS major version is equal to the Safari major version
        let majoriOSVersion = (UIDevice.current.systemVersion as NSString).components(separatedBy: ".")[0]
        userAgent.replaceCharacters(in: mobileMatch.range, with: " Version/\(majoriOSVersion).0")

        return String(userAgent)
    }
}
