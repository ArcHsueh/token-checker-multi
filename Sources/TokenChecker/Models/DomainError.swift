import Foundation

enum DomainError: Error, Equatable, LocalizedError, Sendable {
    case keychainTokenMissing
    case anthropicUnauthorized
    case anthropicRateLimited(retryAfter: TimeInterval?)
    case anthropicHTTP(status: Int)
    case codexCLINotFound
    case codexProcessExited
    case codexRPCError(message: String)

    // Grok (xAI)
    case grokAuthMissing
    case grokUnauthorized
    case grokHTTP(status: Int)
    case decoding(String)
    case timeout
    case network(String)

    var errorDescription: String? {
        switch self {
        case .keychainTokenMissing:
            return L("Claude Code OAuth token not found in Keychain. Run `claude login` in the terminal.")
        case .anthropicUnauthorized:
            return L("Authentication error from Anthropic (401). Re-login with `claude login`.")
        case .anthropicRateLimited(let retryAfter):
            if let sec = retryAfter {
                let mins = max(1, Int((sec / 60).rounded()))
                return L("Anthropic API rate limit reached. Retrying automatically in about %d min.", mins)
            }
            return L("Anthropic API rate limit (429). Waiting until the next poll.")
        case .anthropicHTTP(let status):
            return L("Anthropic API error (status %d)", status)
        case .codexCLINotFound:
            return L("Codex CLI not found. Run `npm i -g @openai/codex`.")
        case .codexProcessExited:
            return L("codex app-server exited. Attempting to restart.")
        case .codexRPCError(let message):
            return L("Codex RPC error: %@", message)

        // Grok
        case .grokAuthMissing:
            return L("Grok CLI auth not found. Make sure you have run the Grok CLI at least once.")
        case .grokUnauthorized:
            return L("Grok authentication failed (401). Try logging in again with the Grok CLI.")
        case .grokHTTP(let status):
            return L("Grok API error (status %d)", status)

        case .decoding(let detail):
            return L("Failed to decode response: %@", detail)
        case .timeout:
            return L("Request timed out.")
        case .network(let detail):
            return L("Network error: %@", detail)
        }
    }
}
