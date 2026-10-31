import AppKit
import SwiftUI

/// The three clotheslines available to hang items on.
enum LineCategory: Int, CaseIterable, Identifiable {
    case screenshots = 0
    case clipboard = 1
    case notes = 2

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .screenshots: return "截图"
        case .clipboard: return "剪贴板"
        case .notes: return "便笺"
        }
    }

    var icon: String {
        switch self {
        case .screenshots: return "camera.fill"
        case .clipboard: return "doc.on.clipboard.fill"
        case .notes: return "note.text"
        }
    }
}

/// One text snippet copied to clipboard and hung on the line.
struct PeggedClipboardText: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    var text: String
    var date: Date = Date()
    var tilt: Double = Double.random(in: -2.2...2.2)
    var falling: Bool = false
    var flying: Bool = false

    var previewSnippet: String {
        let lines = text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
        return lines.prefix(4).joined(separator: "\n")
    }

    var charCount: Int {
        text.count
    }

    static func == (a: PeggedClipboardText, b: PeggedClipboardText) -> Bool {
        a.id == b.id && a.text == b.text && a.falling == b.falling && a.flying == b.flying
    }
}

/// One iOS 27 Liquid Glass sticky note hung on the line.
struct PeggedNote: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var tint: String = "amber" // amber, sage, violet, glacier, rose, slate
    var date: Date = Date()
    var tilt: Double = Double.random(in: -2.2...2.2)
    var falling: Bool = false
    var flying: Bool = false

    static let availableTints = ["amber", "sage", "violet", "glacier", "rose", "slate"]

    static func tintColor(for name: String) -> Color {
        switch name {
        case "amber": return Color(red: 245/255, green: 158/255, blue: 11/255)
        case "sage": return Color(red: 16/255, green: 185/255, blue: 129/255)
        case "violet": return Color(red: 139/255, green: 92/255, blue: 246/255)
        case "glacier": return Color(red: 14/255, green: 165/255, blue: 233/255)
        case "rose": return Color(red: 244/255, green: 63/255, blue: 94/255)
        case "slate": return Color(red: 148/255, green: 163/255, blue: 184/255)
        default: return Color(red: 245/255, green: 158/255, blue: 11/255)
        }
    }

    static func == (a: PeggedNote, b: PeggedNote) -> Bool {
        a.id == b.id && a.title == b.title && a.content == b.content && a.tint == b.tint && a.falling == b.falling && a.flying == b.flying
    }
}
