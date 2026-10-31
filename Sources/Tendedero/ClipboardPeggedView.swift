import SwiftUI
import AppKit

/// A hanging card for copied text on the clothesline.
struct ClipboardPeggedView: View {
    let item: PeggedClipboardText
    @ObservedObject var line: Line

    @State private var swing: Double = 0
    @State private var arrived = false
    @State private var hovering = false
    @State private var copied = false

    var body: some View {
        VStack(spacing: -12) {
            Clothespin()
                .zIndex(1)
            card
        }
        .rotationEffect(.degrees(swing + item.tilt), anchor: .top)
        .offset(y: arrived ? 0 : -46)
        .opacity(item.falling || item.flying ? 0 : (arrived ? 1 : 0))
        .onAppear {
            withAnimation(.spring(response: 0.48, dampingFraction: 0.65)) {
                arrived = true
                swing = Double.random(in: -3.5...3.5)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.interpolatingSpring(stiffness: 38, damping: 2.4)) { swing = 0 }
            }
        }
        .onChange(of: line.gust) { _, _ in
            let gust = Double.random(in: -2.5...2.5)
            withAnimation(.easeInOut(duration: 1.2)) { swing = gust }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.interpolatingSpring(stiffness: 28, damping: 2.2)) { swing = 0 }
            }
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Text Snippet Preview
            Text(item.previewSnippet)
                .font(.system(size: 11.5, weight: .regular, design: .rounded))
                .lineSpacing(2)
                .foregroundStyle(.primary)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .topLeading)

            Spacer(minLength: 0)

            // Footer info: character count + timestamp
            HStack {
                Text("\(item.charCount) 字")
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.06), in: Capsule())

                Spacer()

                Text(formatTime(item.date))
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(10)
        .frame(width: Layout.cardWidth, height: Layout.photoMaxHeight + 10)
        .glassFrame(cornerRadius: Frame.radius)
        .background(
            RoundedRectangle(cornerRadius: Frame.radius, style: .continuous)
                .fill(Color.primary.opacity(0.03))
        )
        .shadow(color: .black.opacity(hovering ? 0.26 : 0.18), radius: hovering ? 14 : 10, y: hovering ? 8 : 5)
        .scaleEffect(hovering ? 1.03 : 1, anchor: .top)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: hovering)
        .overlay(alignment: .topLeading) {
            // Discard cross button
            Button(action: { line.dropClipboardText(item.id) }) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(width: 18, height: 18)
                    .glassFrame(circle: true)
            }
            .buttonStyle(.plain)
            .padding(4)
            .opacity(hovering ? 1 : 0)
        }
        .overlay(alignment: .bottom) {
            if copied {
                Label("已复制", systemImage: "checkmark")
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .glassFrame(capsule: true)
                    .offset(y: 14)
                    .transition(.opacity.combined(with: .offset(y: -4)))
            }
        }
        .onHover { hovering = $0 }
        .onTapGesture {
            copyText()
        }
        .background(
            GeometryReader { g in
                Color.clear.preference(key: HitRectsKey.self,
                                       value: item.falling ? [:] : [item.id: g.frame(in: .global)])
            }
        )
    }

    private func copyText() {
        let entry = NSPasteboardItem()
        entry.setString(item.text, forType: .string)
        entry.setString("1", forType: ClipboardWatcher.selfCopyType)
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.writeObjects([entry])
        ClipboardWatcher.recordSelfCopy()

        withAnimation(.easeOut(duration: 0.2)) { copied = true }
        if line.soundOn, let sound = NSSound(named: "Tink") { sound.play() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.3)) { copied = false }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}
