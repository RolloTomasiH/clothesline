import SwiftUI
import AppKit

/// A hanging iOS 27 Liquid Glass sticky note card on the clothesline.
struct NotePeggedView: View {
    @State var item: PeggedNote
    @ObservedObject var line: Line

    @State private var swing: Double = 0
    @State private var arrived = false
    @State private var hovering = false
    @State private var showEditor = false

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
        .popover(isPresented: $showEditor, arrowEdge: .bottom) {
            NoteEditorView(
                note: $item,
                onSave: {
                    line.updateNote(item)
                },
                onDelete: {
                    line.dropNote(item.id)
                },
                onDismiss: {
                    showEditor = false
                }
            )
        }
        .onChange(of: showEditor) { _, isShowing in
            line.isEditingNote = isShowing
        }
    }

    private var accentColor: Color {
        PeggedNote.tintColor(for: item.tint)
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Note Header: Jewel dot + Title
            HStack(spacing: 6) {
                Circle()
                    .fill(accentColor)
                    .frame(width: 8, height: 8)
                    .shadow(color: accentColor.opacity(0.6), radius: 3)

                Text(item.title.isEmpty ? "便笺" : item.title)
                    .font(.system(size: 11.5, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer(minLength: 0)

                // Edit Button
                Button(action: { showEditor = true }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .opacity(hovering ? 1 : 0.4)
            }
            .padding(.bottom, 2)

            // Content preview with interactive checkboxes
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(item.content.components(separatedBy: .newlines).prefix(5).enumerated()), id: \.offset) { idx, lineText in
                    let trimmed = lineText.trimmingCharacters(in: .whitespaces)
                    if trimmed.hasPrefix("- [x]") || trimmed.hasPrefix("- [X]") {
                        // Completed Todo
                        HStack(spacing: 5) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(accentColor)
                            Text(trimmed.dropFirst(5).trimmingCharacters(in: .whitespaces))
                                .font(.system(size: 10.5))
                                .strikethrough()
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleTodo(at: idx, currentDone: true)
                        }
                    } else if trimmed.hasPrefix("- [ ]") {
                        // Pending Todo
                        HStack(spacing: 5) {
                            Image(systemName: "circle")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                            Text(trimmed.dropFirst(5).trimmingCharacters(in: .whitespaces))
                                .font(.system(size: 10.5))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleTodo(at: idx, currentDone: false)
                        }
                    } else if !trimmed.isEmpty {
                        // Normal line
                        Text(trimmed)
                            .font(.system(size: 10.5))
                            .foregroundStyle(.primary.opacity(0.88))
                            .lineLimit(1)
                    }
                }
            }

            Spacer(minLength: 0)

            // Footer: Timestamp
            HStack {
                Spacer()
                Text(formatTime(item.date))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(9)
        .frame(width: Layout.cardWidth + 10, height: Layout.photoMaxHeight + 16)
        .glassFrame(cornerRadius: Frame.radius)
        .background(
            RoundedRectangle(cornerRadius: Frame.radius, style: .continuous)
                .fill(accentColor.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Frame.radius, style: .continuous)
                .stroke(accentColor.opacity(0.35), lineWidth: 0.8)
        )
        .shadow(color: .black.opacity(hovering ? 0.26 : 0.18), radius: hovering ? 14 : 10, y: hovering ? 8 : 5)
        .scaleEffect(hovering ? 1.03 : 1, anchor: .top)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: hovering)
        .overlay(alignment: .topLeading) {
            // Discard cross button
            Button(action: { line.dropNote(item.id) }) {
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
        .onHover { hovering = $0 }
        .onTapGesture(count: 2) {
            showEditor = true
        }
        .background(
            GeometryReader { g in
                Color.clear.preference(key: HitRectsKey.self,
                                       value: item.falling ? [:] : [item.id: g.frame(in: .global)])
            }
        )
    }

    private func toggleTodo(at lineIdx: Int, currentDone: Bool) {
        var lines = item.content.components(separatedBy: .newlines)
        guard lineIdx < lines.count else { return }
        let target = lines[lineIdx]
        if currentDone {
            lines[lineIdx] = target.replacingOccurrences(of: "- [x]", with: "- [ ]", options: .caseInsensitive)
        } else {
            lines[lineIdx] = target.replacingOccurrences(of: "- [ ]", with: "- [x]")
        }
        item.content = lines.joined(separator: "\n")
        line.updateNote(item)
        if line.soundOn, let sound = NSSound(named: "Pop") { sound.play() }
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MM/dd HH:mm"
        return f.string(from: date)
    }
}
