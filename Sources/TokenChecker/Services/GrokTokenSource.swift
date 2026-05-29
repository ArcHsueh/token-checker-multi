import Foundation

/// 从 ~/.grok/auth.json 读取 Grok CLI 的 OAuth token
struct GrokTokenSource {
    private let authPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".grok/auth.json")

    func readAccessToken() async throws -> String {
        guard FileManager.default.fileExists(atPath: authPath.path) else {
            throw DomainError.grokAuthMissing
        }

        let data = try Data(contentsOf: authPath)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw DomainError.decoding("Failed to parse ~/.grok/auth.json")
        }

        // The structure is { "https://auth.x.ai::...": { "key": "<JWT>", ... } }
        guard let firstValue = json.values.first as? [String: Any],
              let jwt = firstValue["key"] as? String else {
            throw DomainError.grokAuthMissing
        }

        return jwt
    }
}
