import SwiftUI
import AppKit

/// A sleek Liquid Glass popover editor for Sticky Notes.
struct NoteEditorView: View {
    @Binding var note: PeggedNote
    let onSave: () -> Void
    let onDelete: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with color palette and close button
            HStack {
                // Color dots
                HStack(spacing: 8) {
                    ForEach(PeggedNote.availableTints, id: \.self) { tintName in
                        Circle()
                            .fill(PeggedNote.tintColor(for: tintName))
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: note.tint == tintName ? 2 : 0)
                            )
                            .scaleEffect(note.tint == tintName ? 1.2 : 1.0)
                            .onTapGesture {
                                note.tint = tintName
                            }
                    }
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            // Title Input
            TextField("便笺标题...", text: $note.title)
                .font(.system(size: 14, weight: .semibold))
                .textFieldStyle(.plain)
                .padding(6)
                .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 6, style: .continuous))

            // Content Editor
            TextEditor(text: $note.content)
                .font(.system(size: 12.5, weight: .regular))
                .frame(minHeight: 120, maxHeight: 180)
                .padding(4)
                .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6, style: .continuous))

            // Quick Insertion Toolbar
            HStack(spacing: 6) {
                Button(action: {
                    let prefix = note.content.isEmpty || note.content.hasSuffix("\n") ? "" : "\n"
                    note.content += prefix + "- [ ] "
                }) {
                    Text("+ [ ] 待办")
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.primary.opacity(0.06), in: Capsule())
                }
                .buttonStyle(.plain)

                Button(action: {
                    note.content += " #标签"
                }) {
                    Text("# 标签")
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.primary.opacity(0.06), in: Capsule())
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: {
                    onDelete()
                    onDismiss()
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 4)

                Button(action: {
                    onSave()
                    onDismiss()
                }) {
                    Text("保存并挂起")
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.accentColor, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .frame(width: 290)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(PeggedNote.tintColor(for: note.tint).opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 18, y: 8)
    }
}
