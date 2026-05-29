import Foundation

/// サポートするサービス（将来的に増やしやすいよう enum 化）
enum Service: String, CaseIterable, Identifiable, Sendable {
    case claude = "claude"
    case codex = "codex"
    case grok = "grok"
    case gemini = "gemini"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .claude: return "Claude Code"
        case .codex: return "Codex"
        case .grok: return "Grok"
        case .gemini: return "Gemini"
        }
    }

    /// SF Symbol 名（メニューバー用）
    var iconName: String {
        switch self {
        case .claude: return "sparkles"
        case .codex: return "terminal.fill"
        case .grok: return "x.circle.fill"
        case .gemini: return "g.circle.fill"
        }
    }
}

/// 1 つのレート制限ウィンドウ。
struct RateLimit: Equatable, Sendable {
    /// 0.0 〜 1.0+。1.0 で 100% 使用。たまに 1.0 を超えることがある（API 側仕様）。
    let utilization: Double
    /// ウィンドウがリセットされる時刻。
    let resetsAt: Date

    var percent: Int { Int((utilization * 100).rounded()) }
}

/// 1 サービスの使用状況。
struct ServiceUsage: Equatable, Sendable {
    let fiveHour: RateLimit?
    let weekly: RateLimit?
    /// Claude のみ有効。他サービスは nil。
    let weeklySonnet: RateLimit?
}

/// 取得結果をサービスごとに保持（4サービス対応）。
struct UsageSnapshot: Equatable, Sendable {
    let results: [Service: Result<ServiceUsage, DomainError>]
    let fetchedAt: Date

    static let empty: UsageSnapshot = UsageSnapshot(
        results: [:],
        fetchedAt: .distantPast
    )

    // 後方互換のための computed property（段階的移行用）
    var claude: Result<ServiceUsage, DomainError>? { results[.claude] }
    var codex: Result<ServiceUsage, DomainError>? { results[.codex] }
}

extension ServiceUsage: CustomStringConvertible {
    var description: String {
        let fh = fiveHour.map { "\($0.percent)% (resets \($0.resetsAt))" } ?? "nil"
        let wk = weekly.map { "\($0.percent)% (resets \($0.resetsAt))" } ?? "nil"
        let wks = weeklySonnet.map { "\($0.percent)% (resets \($0.resetsAt))" } ?? "nil"
        return "ServiceUsage(fiveHour: \(fh), weekly: \(wk), weeklySonnet: \(wks))"
    }
}
