import SwiftUI
import AppKit

/// メニューバーには「最も使用率が高いサービス」の1つのドーナツだけ表示。
/// クリックでポップオーバーを縦に展開して全サービスの詳細を見る形。
struct MenuBarLabel: View {
    let viewModel: UsageViewModel

    var body: some View {
        if let image = renderedImage {
            Image(nsImage: image)
        } else {
            Text("TC ⏳")
        }
    }

    private var renderedImage: NSImage? {
        // 找出当前 5 小时使用率最高的那个服务
        let services: [Service] = [.claude, .codex, .grok]
        let mostConstrained = services
            .compactMap { service -> (Service, Double)? in
                guard let util = utilization(for: service) else { return nil }
                return (service, util)
            }
            .max { $0.1 < $1.1 } // 取 utilization 最大的

        guard let (service, util) = mostConstrained else {
            // 所有服务都还没数据时显示占位
            let placeholder = HStack(spacing: 4) {
                DonutChartView(value: 0, size: 18, lineWidth: 2.5, center: .sfSymbol("questionmark", scale: 0.45))
                Text("--%")
                    .font(.system(size: 11, weight: .semibold))
            }
            .padding(.horizontal, 4)
            .foregroundStyle(.white) // menu bar: high contrast on dark status bar

            let renderer = ImageRenderer(content: placeholder)
            renderer.scale = 3
            return renderer.nsImage
        }

        let textColor: Color = {
            if util < 0.7 { return .green }
            if util < 0.85 { return .orange }
            return .red
        }()

        let content = HStack(spacing: 4) {
            DonutChartView(
                value: util,
                size: 18,
                lineWidth: 2.5,
                center: .sfSymbol(service.iconName, scale: 0.45)
            )
            Text(percentLabel(util))
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(textColor) // green/orange/red warning color for visibility on dark menu bar bg
        }
        .padding(.horizontal, 4)

        let renderer = ImageRenderer(content: content)
        let maxScale = NSScreen.screens.map(\.backingScaleFactor).max() ?? 2
        renderer.scale = max(maxScale, 3)
        guard let image = renderer.nsImage else { return nil }
        image.isTemplate = false
        return image
    }

    private func utilization(for service: Service) -> Double? {
        guard case .success(let usage) = viewModel.snapshot.results[service] else { return nil }
        return usage.fiveHour?.utilization
    }

    private func percentLabel(_ value: Double?) -> String {
        guard let v = value else { return "--%" }
        if v > 1.0 { return "100%+" }
        let clamped = max(0, v)
        return "\(Int((clamped * 100).rounded()))%"
    }
}
