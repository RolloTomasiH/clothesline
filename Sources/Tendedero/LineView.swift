import SwiftUI

enum Layout {
    /// How big the photos hang, from Size in the menu bar. The clip, the rope
    /// and the glass frame keep their size; the photos and the room they take
    /// grow or shrink. Medium is the original size.
    enum Size: String, CaseIterable {
        case small, medium, large

        var scale: CGFloat {
            switch self {
            case .small: 0.8
            case .medium: 1
            case .large: 1.35
            }
        }
    }

    static var size: Size {
        get { Size(rawValue: UserDefaults.standard.string(forKey: "lineSize") ?? "") ?? .medium }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "lineSize") }
    }

    static var photoMaxHeight: CGFloat { (104 * size.scale).rounded() }
    static var cardWidth: CGFloat { (150 * size.scale).rounded() }
    static var spacing: CGFloat { cardWidth + 24 }
    static var panelHeight: CGFloat { photoMaxHeight + 118 }
    static let ropeTop: CGFloat = 10
    static let pinAbove: CGFloat = 9.5

    /// The rope hangs as a parabola from edge to edge of the screen.
    static func sag(width: CGFloat) -> CGFloat { min(30, width * 0.018) }

    static func ropeY(x: CGFloat, width: CGFloat) -> CGFloat {
        guard width > 0 else { return ropeTop }
        let f = x / width
        return ropeTop + 4 * sag(width: width) * f * (1 - f)
    }

    /// Items hang `spacing` apart, centred. When there are more than the
    /// `visible` that fit: with Keep on line set, they keep their spacing,
    /// the newest stays where the last one would hang on a full line, and
    /// `scroll` brings older ones in from the left. Otherwise (a line hung
    /// on a wider screen) they move closer together so none is past the edge.
    static func x(index: Int, count: Int, width: CGFloat, visible: Int, scroll: CGFloat) -> CGFloat {
        if Line.keepOnLine != nil && count > visible {
            let newest = width / 2 + CGFloat(visible - 1) * spacing / 2
            return newest - CGFloat(count - 1 - index) * spacing + scroll
        }
        let gaps = CGFloat(max(count - 1, 0))
        let step = gaps > 0 ? min(spacing, max(0, width - 200) / gaps) : spacing
        return width / 2 - gaps * step / 2 + CGFloat(index) * step
    }
}

struct LineView: View {
    @ObservedObject var line: Line

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack(alignment: .topLeading) {
                // The hanging rope
                Rope(width: width)

                // Category-specific items on the line
                switch line.category {
                case .screenshots:
                    if line.items.isEmpty {
                        Hint(text: "拍张截图或录屏，它就会挂在晾衣绳上")
                            .position(x: width / 2, y: Layout.ropeY(x: width / 2, width: width) + 38)
                            .transition(.opacity)
                    }

                    ForEach(Array(line.items.enumerated()), id: \.element.id) { index, item in
                        let x = Layout.x(index: index, count: line.items.count, width: width,
                                         visible: line.visibleCount, scroll: line.scroll)
                        let ropeY = Layout.ropeY(x: x, width: width)
                        PeggedView(item: item, line: line)
                            .frame(width: Layout.cardWidth, height: Layout.panelHeight - ropeY - 26, alignment: .top)
                            .opacity(min(1, max(0, min(x, width - x) / 90)))
                            .position(x: x, y: ropeY - Layout.pinAbove + (Layout.panelHeight - ropeY - 26) / 2)
                    }

                case .clipboard:
                    if line.clipboardItems.isEmpty {
                        Hint(text: "复制一段文字，它就会自动挂在晾衣绳上")
                            .position(x: width / 2, y: Layout.ropeY(x: width / 2, width: width) + 38)
                            .transition(.opacity)
                    }

                    ForEach(Array(line.clipboardItems.enumerated()), id: \.element.id) { index, item in
                        let x = Layout.x(index: index, count: line.clipboardItems.count, width: width,
                                         visible: line.visibleCount, scroll: line.scroll)
                        let ropeY = Layout.ropeY(x: x, width: width)
                        ClipboardPeggedView(item: item, line: line)
                            .frame(width: Layout.cardWidth + 10, height: Layout.panelHeight - ropeY - 26, alignment: .top)
                            .opacity(min(1, max(0, min(x, width - x) / 90)))
                            .position(x: x, y: ropeY - Layout.pinAbove + (Layout.panelHeight - ropeY - 26) / 2)
                    }

                case .notes:
                    if line.noteItems.isEmpty {
                        Hint(text: "点击下方「+ 新建」或按 ⌘N 创建流光便笺")
                            .position(x: width / 2, y: Layout.ropeY(x: width / 2, width: width) + 38)
                            .transition(.opacity)
                    }

                    ForEach(Array(line.noteItems.enumerated()), id: \.element.id) { index, item in
                        let x = Layout.x(index: index, count: line.noteItems.count, width: width,
                                         visible: line.visibleCount, scroll: line.scroll)
                        let ropeY = Layout.ropeY(x: x, width: width)
                        NotePeggedView(item: item, line: line)
                            .frame(width: Layout.cardWidth + 10, height: Layout.panelHeight - ropeY - 26, alignment: .top)
                            .opacity(min(1, max(0, min(x, width - x) / 90)))
                            .position(x: x, y: ropeY - Layout.pinAbove + (Layout.panelHeight - ropeY - 26) / 2)
                    }
                }

                // Bottom Category Switcher Pill
                CategoryBar(line: line)
                    .position(x: width / 2, y: Layout.panelHeight - 18)
            }
            .animation(.spring(response: 0.52, dampingFraction: 0.78), value: line.category)
            .animation(.spring(response: 0.52, dampingFraction: 0.78), value: line.items.map(\.id))
            .animation(.spring(response: 0.52, dampingFraction: 0.78), value: line.clipboardItems.map(\.id))
            .animation(.spring(response: 0.52, dampingFraction: 0.78), value: line.noteItems.map(\.id))
            .animation(.easeInOut(duration: 0.25), value: line.liveCount == 0)
            // Tucked away, the whole line waits above the top edge and slides
            // out from under the menu bar, the way an auto-hiding Dock does.
            .offset(y: line.revealed ? 0 : -(Layout.panelHeight + 14))
            .animation(line.revealed ? .spring(response: 0.42, dampingFraction: 0.82)
                                     : .easeIn(duration: 0.22), value: line.revealed)
        }
        .onPreferenceChange(HitRectsKey.self) { rects in
            line.hitRects = rects
        }
    }
}

/// Floating Liquid Glass Category Switcher & Action Capsule Bar
private struct CategoryBar: View {
    @ObservedObject var line: Line
    static let hitID = UUID(uuidString: "77777777-8888-9999-aaaa-bbbbbbbbbbbb")!

    var body: some View {
        HStack(spacing: 5) {
            tabButton(title: "截图", icon: "camera.fill", count: line.items.count, category: .screenshots)
            tabButton(title: "剪贴板", icon: "doc.on.clipboard.fill", count: line.clipboardItems.count, category: .clipboard)
            tabButton(title: "便笺", icon: "note.text", count: line.noteItems.count, category: .notes)

            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 1, height: 13)
                .padding(.horizontal, 2)

            Button(action: {
                if line.category != .notes {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        line.category = .notes
                    }
                }
                _ = line.createNote()
            }) {
                HStack(spacing: 3) {
                    Image(systemName: "plus")
                        .font(.system(size: 9.5, weight: .bold))
                    Text("新建")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3.5)
                .background(Color.white.opacity(0.16), in: Capsule())
            }
            .buttonStyle(.plain)
            .help("新建流光便笺 (⌘N)")
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.38), Color.white.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.75
                )
        )
        .shadow(color: .black.opacity(0.18), radius: 8, y: 3)
        .background(
            GeometryReader { g in
                Color.clear.preference(key: HitRectsKey.self, value: [Self.hitID: g.frame(in: .global)])
            }
        )
    }

    private func tabButton(title: String, icon: String, count: Int, category: LineCategory) -> some View {
        let isSelected = line.category == category
        return Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                line.category = category
            }
        }) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 9.5, weight: .semibold))
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium, design: .rounded))
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(isSelected ? .white : .secondary)
                        .padding(.horizontal, 4.5)
                        .padding(.vertical, 1)
                        .background(isSelected ? Color.white.opacity(0.28) : Color.white.opacity(0.12), in: Capsule())
                }
            }
            .foregroundStyle(isSelected ? .primary : .secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3.5)
            .background(
                isSelected
                    ? AnyShapeStyle(Color.white.opacity(0.22))
                    : AnyShapeStyle(Color.clear),
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
    }
}

private struct Hint: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(.regularMaterial, in: Capsule())
            .overlay(
                Capsule().strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
    }
}

/// A thin, neutral line: a mid gray core with a faint highlight and a soft
/// shadow, so it reads on light and dark backgrounds alike. It fades out at
/// both ends so it seems to come from beyond the screen.
struct Rope: View {
    let width: CGFloat

    private var path: Path {
        Path { p in
            let top = Layout.ropeTop
            p.move(to: CGPoint(x: -20, y: top))
            p.addQuadCurve(
                to: CGPoint(x: width + 20, y: top),
                control: CGPoint(x: width / 2, y: top + 2 * Layout.sag(width: width)))
        }
    }

    var body: some View {
        ZStack {
            path.stroke(Color.black.opacity(0.22), lineWidth: 1.4).offset(y: 1.2).blur(radius: 1.2)
            path.stroke(Color(white: 0.55), lineWidth: 1.2)
            path.stroke(Color.white.opacity(0.45), lineWidth: 0.4).offset(y: -0.35)
        }
        .mask(
            LinearGradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 0.08),
                .init(color: .black, location: 0.92),
                .init(color: .clear, location: 1),
            ], startPoint: .leading, endPoint: .trailing)
        )
        .allowsHitTesting(false)
    }
}

struct HitRectsKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]
    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}
