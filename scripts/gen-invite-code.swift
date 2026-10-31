#!/usr/bin/env swift
import Foundation
import CryptoKit

let salt = "LYS-Clothesline-2026-Secret-Salt#7"

func computeChecksum(dateStr: String) -> String {
    let raw = "LYS-\(dateStr)-\(salt)"
    let digest = SHA256.hash(data: Data(raw.utf8))
    let hex = digest.map { String(format: "%02X", $0) }.joined()
    return String(hex.prefix(4))
}

let df = DateFormatter()
df.dateFormat = "yyyyMMdd"

let displayDf = DateFormatter()
displayDf.dateFormat = "yyyy-MM-dd"

let now = Date()
let args = Array(CommandLine.arguments.dropFirst())

var days: Int = 30
var expiry: Date = Calendar.current.date(byAdding: .day, value: 30, to: now)!

if let first = args.first {
    if first.count == 8, let customDate = df.date(from: first) {
        expiry = customDate
        days = Calendar.current.dateComponents([.day], from: now, to: expiry).day ?? 0
    } else if let num = Int(first.replacingOccurrences(of: "d", with: "").replacingOccurrences(of: "天", with: "")) {
        days = num
        expiry = Calendar.current.date(byAdding: .day, value: days, to: now)!
    }
}

let dateStr = df.string(from: expiry)

print("\n" + String(repeating: "═", count: 50))
print("🧺 「晾衣绳」邀请码生成器")
print("签发日期: \(displayDf.string(from: now))")
print("到期日期: \(displayDf.string(from: expiry)) (有效期 \(days) 天)")
print(String(repeating: "═", count: 50))

let checksum = computeChecksum(dateStr: dateStr)
let code = "LYS-\(dateStr)-\(checksum)"

print("\n【专属邀请码 (有效期 \(days) 天，到期时间: \(displayDf.string(from: expiry)))】:")
print("👉  \(code)")

print("\n【作者永久管理员专属码 (永不过期)】:")
print("👑  LYS-VIP-MASTER")
print(String(repeating: "═", count: 50) + "\n")
