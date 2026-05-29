import Foundation

/// Grok (xAI) 使用量プロバイダ
/// 从 ~/.grok/auth.json 读取 OAuth token，并尝试获取使用率信息
struct GrokUsageProvider: UsageProvider {
    private let tokenSource = GrokTokenSource()
    private let api = XAIUsageAPIClient()

    func fetch() async throws -> ServiceUsage {
        let token = try await tokenSource.readAccessToken()
        let dto = try await api.fetch(accessToken: token)

        return ServiceUsage(
            fiveHour: dto.fiveHour?.toRateLimit(),
            weekly: dto.weekly?.toRateLimit(),
            weeklySonnet: nil
        )
    }
}
