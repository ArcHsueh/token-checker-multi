import Foundation
import Network
import OSLog

struct ProxyDetector {
    private actor State {
        var resolved = false
        func resolve() -> Bool {
            if resolved { return false }
            resolved = true
            return true
        }
    }

    /// Detects if a local proxy (like Clash, Clash Verge, etc.) is running on common ports.
    /// Returns the first open port (typically 7890 or 7897), or nil if none found.
    static func detectProxyPort() async -> Int? {
        let commonPorts = [7890, 7897]
        for port in commonPorts {
            if await isPortOpen(port: port) {
                Logger.app.info("Detected local proxy on port \(port, privacy: .public)")
                return port
            }
        }
        return nil
    }

    private static func isPortOpen(port: Int) async -> Bool {
        let host = NWEndpoint.Host("127.0.0.1")
        let endpointPort = NWEndpoint.Port(rawValue: UInt16(port))!
        let connection = NWConnection(host: host, port: endpointPort, using: .tcp)
        let state = State()
        
        return await withCheckedContinuation { continuation in
            connection.stateUpdateHandler = { connState in
                switch connState {
                case .ready:
                    Task {
                        if await state.resolve() {
                            connection.cancel()
                            continuation.resume(returning: true)
                        }
                    }
                case .failed, .cancelled:
                    Task {
                        if await state.resolve() {
                            continuation.resume(returning: false)
                        }
                    }
                default:
                    break
                }
            }
            
            connection.start(queue: .global())
            
            // Timeout after 200 milliseconds to avoid blocking UI or delays
            Task {
                try? await Task.sleep(nanoseconds: 200_000_000)
                if await state.resolve() {
                    connection.cancel()
                    continuation.resume(returning: false)
                }
            }
        }
    }
}
