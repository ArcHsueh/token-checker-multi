import Foundation

/// xAI Grok 使用量客户端（目前为实验性实现）
/// 基于 Grok CLI 的 OAuth token 尝试获取 rate limit / usage 信息
struct XAIUsageAPIClient {
    private let session = URLSession.shared

    /// 尝试获取 usage 数据。
    /// 当前实现从 JWT claims 中提取 tier 等信息，并返回占位数据。
    /// TODO: 替换为真实的 xAI usage/rate limit 接口调用。
    func fetch(accessToken: String) async throws -> XAIUsageDTO {
        let claims = try decodeJWTClaims(accessToken)

        let tier = claims["tier"] as? Int ?? 0
        let teamId = claims["team_id"] as? String

        // 临时实现：根据 tier 返回一个合理的占位使用率
        // 后续需要替换成真实调用 xAI 的 usage endpoint
        let now = Date()
        let fiveHourReset = Calendar.current.date(byAdding: .hour, value: 5, to: now) ?? now
        let weeklyReset = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now

        let utilization: Double = tier >= 2 ? 0.28 : (tier == 1 ? 0.55 : 0.78)

        return XAIUsageDTO(
            fiveHour: XAIWindow(utilization: utilization, resetsAt: fiveHourReset),
            weekly: XAIWindow(utilization: min(1.0, utilization * 0.7), resetsAt: weeklyReset),
            tier: tier,
            teamId: teamId
        )
    }

    private func decodeJWTClaims(_ jwt: String) throws -> [String: Any] {
        let parts = jwt.split(separator: ".")
        guard parts.count >= 2 else {
            throw DomainError.decoding("Invalid JWT format in grok auth")
        }

        var payload = String(parts[1])
        // base64 padding
        while payload.count % 4 != 0 { payload += "=" }

        guard let data = Data(base64Encoded: payload, options: .ignoreUnknownCharacters),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw DomainError.decoding("Failed to decode Grok JWT payload")
        }
        return json
    }
}

// MARK: - DTOs

struct XAIUsageDTO {
    let fiveHour: XAIWindow?
    let weekly: XAIWindow?
    let tier: Int?
    let teamId: String?
}

struct XAIWindow {
    let utilization: Double
    let resetsAt: Date
}

extension XAIWindow {
    func toRateLimit() -> RateLimit {
        RateLimit(utilization: utilization, resetsAt: resetsAt)
    }
}
