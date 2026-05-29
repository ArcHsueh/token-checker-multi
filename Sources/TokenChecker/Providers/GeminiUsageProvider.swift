import Foundation

/// Gemini 使用量プロバイダ（現在はスタブ）。
/// 個人向け Google AI Studio / Gemini のレートリミットは公式にプログラムから取りにくい。
/// 将来的な妥協案:
/// - Google Cloud Monitoring API（プロジェクト連携時）
/// - クライアントサイドでトークンカウント + 429 エラー解析
/// - AI Studio ダッシュボードを案内するだけ
struct GeminiUsageProvider: UsageProvider {
    func fetch() async throws -> ServiceUsage {
        // Gemini 個人アカウントのクリーンな usage API は現状存在しない
        throw DomainError.network("Gemini usage tracking requires Google Cloud project + Monitoring API or client-side estimation (not yet implemented)")
    }
}
