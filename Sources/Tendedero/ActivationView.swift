import SwiftUI
import AppKit

/// A sleek iOS 27 Liquid Glass Activation / Invitation Code Dialog.
struct ActivationView: View {
    @ObservedObject var manager = ActivationManager.shared
    @State private var inputCode: String = ""
    @State private var statusMessage: String = ""
    @State private var isError: Bool = false
    @State private var isSuccess: Bool = false

    let onActivated: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Header: Icon + Title
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.18), Color.purple.opacity(0.12)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 68, height: 68)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)

                    Text("🧺")
                        .font(.system(size: 34))
                }

                Text("欢迎使用「晾衣绳」")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(manager.isActivated ? "当前已激活：剩余 \(manager.remainingDays) 天" : "请输入邀请码以激活桌面便笺系统")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
            }

            // Input section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TextField("输入邀请码，如 LYS-20261027-XXXX", text: $inputCode)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(isError ? Color.red.opacity(0.6) : (isSuccess ? Color.green.opacity(0.6) : Color.white.opacity(0.25)), lineWidth: 1)
                        )

                    Button(action: pasteFromClipboard) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .help("从剪贴板粘贴")
                }

                if !statusMessage.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: isError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                            .font(.system(size: 11))
                        Text(statusMessage)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(isError ? .red : .green)
                    .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity)

            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("退出")
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)

                Button(action: handleActivate) {
                    Text(manager.isActivated ? "更新邀请码" : "激活并开启")
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.defaultAction)
            }

            // Footer Tips
            VStack(spacing: 4) {
                Text("• 邀请码自签发日期起有效期为两周")
                Text("• 如需获取邀请码，请联系作者获取")
            }
            .font(.system(size: 10.5))
            .foregroundStyle(.tertiary)
        }
        .padding(24)
        .frame(width: 330)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 24, y: 10)
        .onAppear {
            if let saved = UserDefaults.standard.string(forKey: "lys_activation_code") {
                inputCode = saved
            }
        }
    }

    private func handleActivate() {
        withAnimation(.easeOut(duration: 0.2)) {
            let res = manager.activate(with: inputCode)
            if res.success {
                isError = false
                isSuccess = true
                statusMessage = res.message
                if let sound = NSSound(named: "Tink") { sound.play() }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    onActivated()
                }
            } else {
                isError = true
                isSuccess = false
                statusMessage = res.message
                NSSound.beep()
            }
        }
    }

    private func pasteFromClipboard() {
        if let str = NSPasteboard.general.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            inputCode = str
            handleActivate()
        }
    }
}
