import Foundation
import Network
import SystemConfiguration // kept only to satisfy legacy init signature; not used internally

// MARK: - Version symbols (kept for compatibility; you can fill these at build time if needed)
public var ReachabilityVersionNumber: Double = 1.0
public let ReachabilityVersionString: String = "MRReachability (NWPathMonitor-backed) 1.0.0"

/// MRReachability: lightweight, NWPathMonitor-backed reachability with a legacy-style API.
/// Available where Apple's Network framework is available.
@available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 5.0, *)
public final class MRReachability: CustomStringConvertible {

    // MARK: Legacy callback aliases
    public typealias NetworkReachable   = (MRReachability) -> Void
    public typealias NetworkUnreachable = (MRReachability) -> Void

    // MARK: Legacy 3-state connection enum (mapped from NWPath)
    public enum Connection: CustomStringConvertible {
        case unavailable
        case wifi
        case cellular

        public var description: String {
            switch self {
            case .unavailable: return "unavailable"
            case .wifi:        return "wifi"
            case .cellular:    return "cellular"
            }
        }

        @available(*, deprecated, renamed: "unavailable")
        public static let none: MRReachability.Connection = .unavailable
    }

    // MARK: Public (legacy) surface
    public var whenReachable:   NetworkReachable?
    public var whenUnreachable: NetworkUnreachable?

    @available(*, deprecated, renamed: "allowsCellularConnection")
    public let reachableOnWWAN: Bool = true

    /// Set to `false` to force MRReachability.connection to .unavailable when on cellular connection (default `true`)
    public var allowsCellularConnection: Bool = true

    public var notificationCenter: NotificationCenter = .default

    @available(*, deprecated, renamed: "connection.description")
    public var currentReachabilityString: String { connection.description }

    public var connection: Connection {
        guard let path = latestPath else { return .unavailable }
        return map(path: path)
    }

    // MARK: Legacy-style initializers (kept for compatibility)
    public init(
        reachabilityRef _: SCNetworkReachability,
        queueQoS: DispatchQoS = .default,
        targetQueue: DispatchQueue? = nil,
        notificationQueue: DispatchQueue? = .main
    ) {
        self.queueQoS = queueQoS
        self.targetQueue = targetQueue ?? DispatchQueue(label: "mrreachability.monitor.queue", qos: queueQoS)
        self.notificationQueue = notificationQueue ?? .main
        self.monitor = NWPathMonitor()
    }

    public convenience init(
        hostname: String,
        queueQoS: DispatchQoS = .default,
        targetQueue: DispatchQueue? = nil,
        notificationQueue: DispatchQueue? = .main
    ) throws {
        // Create a dummy SCNetworkReachabilityRef just to satisfy legacy signature; not used internally.
        let chosenHost = hostname.isEmpty ? "localhost" : hostname
        guard let dummyRef = SCNetworkReachabilityCreateWithName(nil, chosenHost) else {
            throw MRReachabilityError.failedToCreateWithHostname(chosenHost, EINVAL)
        }
        self.init(reachabilityRef: dummyRef, queueQoS: queueQoS, targetQueue: targetQueue, notificationQueue: notificationQueue)
    }

    public convenience init(
        queueQoS: DispatchQoS = .default,
        targetQueue: DispatchQueue? = nil,
        notificationQueue: DispatchQueue? = .main
    ) throws {
        var addr = sockaddr_in(
            sin_len: UInt8(MemoryLayout<sockaddr_in>.size),
            sin_family: sa_family_t(AF_INET),
            sin_port: in_port_t(0),
            sin_addr: in_addr(s_addr: 0),
            sin_zero: (0,0,0,0,0,0,0,0)
        )
        let ref: SCNetworkReachability? = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }
        guard let safeRef = ref else {
            throw MRReachabilityError.failedToCreateWithAddress(unsafeBitCast(addr, to: sockaddr.self), EINVAL)
        }
        self.init(reachabilityRef: safeRef, queueQoS: queueQoS, targetQueue: targetQueue, notificationQueue: notificationQueue)
    }

    deinit { stopNotifier() }

    // MARK: Notifier lifecycle
    public func startNotifier() throws {
        guard !isRunning else { return }
        isRunning = true

        monitor.pathUpdateHandler = { [weak self] path in
            self?.handlePathUpdate(path)
        }

        monitor.start(queue: targetQueue)

        // Emit an initial snapshot immediately
        handlePathUpdate(monitor.currentPath)
    }

    public func stopNotifier() {
        guard isRunning else { return }
        isRunning = false
        monitor.cancel()
        monitor.pathUpdateHandler = nil
        latestPath = nil
    }

    @available(*, deprecated, message: "Please use `connection != .unavailable`")
    public var isReachable: Bool { connection != .unavailable }

    @available(*, deprecated, message: "Please use `connection == .cellular`")
    public var isReachableViaWWAN: Bool { connection == .cellular }

    @available(*, deprecated, message: "Please use `connection == .wifi`")
    public var isReachableViaWiFi: Bool { connection == .wifi }

    public var description: String {
        "MRReachability(connection: \(connection.description), allowsCellular: \(allowsCellularConnection))"
    }

    // MARK: - Internals
    private let monitor: NWPathMonitor
    private let queueQoS: DispatchQoS
    private let targetQueue: DispatchQueue
    private let notificationQueue: DispatchQueue
    private var isRunning: Bool = false
    private var latestPath: NWPath?

    private func handlePathUpdate(_ path: NWPath) {
        latestPath = path
        let status = map(path: path)

        notificationQueue.async { [weak self] in
            guard let self else { return }
            switch status {
            case .unavailable:
                self.whenUnreachable?(self)
            case .wifi, .cellular:
                self.whenReachable?(self)
            }
            self.notificationCenter.post(name: .reachabilityChanged, object: self)
        }
    }

    private func map(path: NWPath) -> Connection {
        guard path.status == .satisfied else { return .unavailable }

        if path.usesInterfaceType(.cellular), allowsCellularConnection == false {
            return .unavailable
        }

        if path.usesInterfaceType(.wifi)          { return .wifi }
        if path.usesInterfaceType(.wiredEthernet) { return .wifi }
        if path.usesInterfaceType(.cellular)      { return .cellular }
        if path.usesInterfaceType(.loopback)      { return .unavailable }

        return .wifi
    }
}

// MARK: - Errors
public enum MRReachabilityError: Error {
    case failedToCreateWithAddress(sockaddr, Int32)
    case failedToCreateWithHostname(String, Int32)
    case unableToSetCallback(Int32)
    case unableToSetDispatchQueue(Int32)
    case unableToGetFlags(Int32)
}

// MARK: - Notification Name
public extension NSNotification.Name {
    static let reachabilityChanged = Notification.Name("reachabilityChanged")
}
