import SwiftUI
import AppKit

struct SubmittableTextView: View {
    @Binding var text: String
    var placeholder: String = ""
    var maxLines: Int = 5
    var font: NSFont = .systemFont(ofSize: 14)
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {
            SubmittableTextViewRepresentable(
                text: $text,
                maxLines: maxLines,
                font: font,
                onSubmit: onSubmit
            )
            if text.isEmpty && !placeholder.isEmpty {
                Text(placeholder)
                    .foregroundStyle(.tertiary)
                    .font(.system(size: font.pointSize))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 7)
                    .allowsHitTesting(false)
            }
        }
    }
}

fileprivate final class SizingScrollView: NSScrollView {
    var onIntrinsicSizeChange: (() -> Void)?

    override var intrinsicContentSize: NSSize {
        guard let documentView = documentView else {
            return super.intrinsicContentSize
        }
        return NSSize(
            width: NSView.noIntrinsicMetric,
            height: documentView.frame.height
        )
    }

    func notifyHeightChanged() {
        invalidateIntrinsicContentSize()
        onIntrinsicSizeChange?()
    }
}

struct SubmittableTextViewRepresentable: NSViewRepresentable {
    @Binding var text: String
    var maxLines: Int = 5
    var font: NSFont = .systemFont(ofSize: 14)
    var onSubmit: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView()
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.isRichText = false
        textView.usesFontPanel = false
        textView.importsGraphics = false
        textView.allowsUndo = true
        textView.font = font
        textView.textContainerInset = NSSize(width: 4, height: 6)
        textView.backgroundColor = .clear
        textView.drawsBackground = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false

        if let container = textView.textContainer {
            container.widthTracksTextView = true
            container.heightTracksTextView = false
        }

        let scrollView = SizingScrollView()
        scrollView.documentView = textView
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.autohidesScrollers = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let lineHeight = font.ascender - font.descender + font.leading
        let insetH = textView.textContainerInset.height * 2
        let initialHeight = lineHeight + insetH

        let heightConstraint = scrollView.heightAnchor.constraint(equalToConstant: initialHeight)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true

        context.coordinator.textView = textView
        context.coordinator.scrollView = scrollView
        context.coordinator.heightConstraint = heightConstraint

        textView.delegate = context.coordinator
        textView.string = text

        context.coordinator.recalcHeight()

        DispatchQueue.main.async {
            textView.window?.makeFirstResponder(textView)
        }

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        context.coordinator.parent = self

        guard let textView = context.coordinator.textView else { return }

        if textView.string != text {
            let selectedRanges = textView.selectedRanges
            textView.string = text
            textView.selectedRanges = selectedRanges
            context.coordinator.recalcHeight()
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: SubmittableTextViewRepresentable

        weak var textView: NSTextView?
        fileprivate weak var scrollView: SizingScrollView?
        var heightConstraint: NSLayoutConstraint?

        init(_ parent: SubmittableTextViewRepresentable) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = textView else { return }
            parent.text = textView.string
            recalcHeight()
        }

        func textView(
            _ textView: NSTextView,
            doCommandBy commandSelector: Selector
        ) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if let event = NSApp.currentEvent,
                   event.modifierFlags.contains(.shift) {
                    textView.insertNewlineIgnoringFieldEditor(nil)
                    return true
                }
                parent.onSubmit?()
                return true
            }

            if commandSelector == #selector(NSResponder.insertLineBreak(_:)) {
                textView.insertNewlineIgnoringFieldEditor(nil)
                return true
            }

            return false
        }

        func recalcHeight() {
            guard
                let textView = textView,
                let scrollView = scrollView,
                let textContainer = textView.textContainer,
                let layoutManager = textView.layoutManager,
                let heightConstraint = heightConstraint
            else { return }

            let lineHeight = parent.font.ascender - parent.font.descender + parent.font.leading
            let maxLinesF = CGFloat(parent.maxLines)
            let insetH = textView.textContainerInset.height * 2

            let minHeight = lineHeight + insetH
            let maxHeight = (lineHeight * maxLinesF) + insetH

            textView.layoutManager?.glyphRange(for: textContainer)
            layoutManager.ensureLayout(for: textContainer)
            let usedRect = layoutManager.usedRect(for: textContainer)
            let desiredHeight = usedRect.height + insetH

            let clampedHeight = min(max(desiredHeight, minHeight), maxHeight)

            heightConstraint.constant = clampedHeight
            scrollView.hasVerticalScroller = desiredHeight > maxHeight

            textView.frame.size.height = clampedHeight
            scrollView.notifyHeightChanged()
            scrollView.needsLayout = true

            if desiredHeight > maxHeight {
                textView.scrollRangeToVisible(textView.selectedRange())
            }
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @State var submitted = ""

    VStack(spacing: 16) {
        Text("Return submits. Shift+Return inserts newline.")
            .font(.caption)
            .foregroundStyle(.secondary)

        SubmittableTextView(
            text: $text,
            placeholder: "Type something here…",
            maxLines: 5
        ) {
            submitted = text
            text = ""
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.quaternary.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(.separator, lineWidth: 0.5)
        )

        if !submitted.isEmpty {
            GroupBox("Last submitted") {
                Text(submitted)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    .padding(20)
    .frame(width: 380)
}
