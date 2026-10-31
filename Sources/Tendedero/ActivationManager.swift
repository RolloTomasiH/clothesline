import Foundation
import CryptoKit

/// Manages invitation code validation, activation, and expiration tracking.
@MainActor
final class ActivationManager: ObservableObject {
    static let shared = ActivationManager()

    private static let salt = "LYS-Clothesline-2026-Secret-Salt#7"
    private static let masterCode = "LYS-VIP-MASTER"

    private let storeKeyExpiry = "lys_activation_expiry"
    private let storeKeyCode = "lys_activation_code"
    private let storeKeySignature = "lys_activation_sig"

    @Published private(set) var isActivated: Bool = false
    @Published private(set) var expiryDate: Date? = nil

    private init() {
        checkActivationState()
    }

    /// Checks if current activation is valid and not expired.
    func checkActivationState() {
        guard let code = UserDefaults.standard.string(forKey: storeKeyCode),
              let sig = UserDefaults.standard.string(forKey: storeKeySignature) else {
            isActivated = false
            expiryDate = nil
            return
        }

        let expiryTime = UserDefaults.standard.double(forKey: storeKeyExpiry)
        let expiry = Date(timeIntervalSince1970: expiryTime)

        // Master bypass code never expires
        if code.uppercased() == Self.masterCode {
            isActivated = true
            expiryDate = Date.distantFuture
            return
        }

        // Verify anti-tamper signature
        let expectedSig = signature(for: code, expiry: expiryTime)
        guard sig == expectedSig else {
            isActivated = false
            expiryDate = nil
            return
        }

        // Check date
        if Date() < expiry {
            isActivated = true
            expiryDate = expiry
        } else {
            // Expired!
            isActivated = false
            expiryDate = expiry
        }
    }

    /// Remaining days of activation.
    var remainingDays: Int {
        guard let expiry = expiryDate, expiry > Date() else { return 0 }
        let diff = Calendar.current.dateComponents([.day], from: Date(), to: expiry)
        return max(1, diff.day ?? 0)
    }

    /// Formatted expiry date string.
    var expiryString: String {
        guard let expiry = expiryDate else { return "未激活" }
        if expiry == Date.distantFuture { return "永久有效" }
        let f = DateFormatter()
        f.dateFormat = "yyyy年MM月dd日 HH:mm"
        return f.string(from: expiry)
    }

    /// Attempts to activate the app with the given code.
    func activate(with inputCode: String) -> (success: Bool, message: String) {
        let code = inputCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !code.isEmpty else {
            return (false, "请输入邀请码")
        }

        // 1. Check Master Code
        if code == Self.masterCode {
            saveActivation(code: code, expiry: Date.distantFuture)
            return (true, "Master 永久激活成功！")
        }

        // 2. Parse Code: Format LYS-YYYYMMDD-XXXX
        let parts = code.components(separatedBy: "-")
        guard parts.count == 3, parts[0] == "LYS" else {
            return (false, "邀请码格式不正确 (例: LYS-20261027-XXXX)")
        }

        let dateStr = parts[1]
        let checksum = parts[2]

        // Validate date format YYYYMMDD
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        df.timeZone = TimeZone.current
        guard let targetDate = df.date(from: dateStr) else {
            return (false, "邀请码日期无效")
        }

        // Target expiration is set to 23:59:59 of that date
        let calendar = Calendar.current
        var comp = calendar.dateComponents([.year, .month, .day], from: targetDate)
        comp.hour = 23
        comp.minute = 59
        comp.second = 59
        guard let fullExpiryDate = calendar.date(from: comp) else {
            return (false, "邀请码日期解析失败")
        }

        // Check if already expired
        if fullExpiryDate < Date() {
            return (false, "该邀请码已过期 (有效期至: \(df.string(from: targetDate)))")
        }

        // Verify checksum: SHA256(LYS + dateStr + salt).prefix(4)
        let expectedChecksum = Self.computeChecksum(dateStr: dateStr)
        guard checksum == expectedChecksum else {
            return (false, "邀请码无效或已被篡改")
        }

        // Activation successful! Save to UserDefaults
        saveActivation(code: code, expiry: fullExpiryDate)
        let diff = Calendar.current.dateComponents([.day], from: Date(), to: fullExpiryDate).day ?? 0
        let daysDesc = diff > 0 ? " (约\(diff)天)" : ""
        return (true, "激活成功！有效期至 \(df.string(from: targetDate))\(daysDesc)")
    }

    private func saveActivation(code: String, expiry: Date) {
        let expiryTime = expiry.timeIntervalSince1970
        let sig = signature(for: code, expiry: expiryTime)

        UserDefaults.standard.set(code, forKey: storeKeyCode)
        UserDefaults.standard.set(expiryTime, forKey: storeKeyExpiry)
        UserDefaults.standard.set(sig, forKey: storeKeySignature)

        isActivated = true
        expiryDate = expiry
    }

    func resetActivation() {
        UserDefaults.standard.removeObject(forKey: storeKeyCode)
        UserDefaults.standard.removeObject(forKey: storeKeyExpiry)
        UserDefaults.standard.removeObject(forKey: storeKeySignature)
        isActivated = false
        expiryDate = nil
    }

    private func signature(for code: String, expiry: Double) -> String {
        let payload = "\(code):\(expiry):\(Self.salt)"
        let digest = SHA256.hash(data: Data(payload.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// Computes the 4-hex-character checksum for a given YYYYMMDD string.
    static func computeChecksum(dateStr: String) -> String {
        let raw = "LYS-\(dateStr)-\(salt)"
        let digest = SHA256.hash(data: Data(raw.utf8))
        let hex = digest.map { String(format: "%02X", $0) }.joined()
        return String(hex.prefix(4))
    }

    /// Generates a valid invitation code for `days` from today (default 14 days).
    static func generateCode(validDays: Int = 14) -> (code: String, expiry: Date) {
        let expiry = Calendar.current.date(byAdding: .day, value: validDays, to: Date()) ?? Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        let dateStr = df.string(from: expiry)
        let checksum = computeChecksum(dateStr: dateStr)
        let code = "LYS-\(dateStr)-\(checksum)"
        return (code, expiry)
    }
}
