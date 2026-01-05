//
//  GrowingTextView.swift
//  JWTMenu
//
//  Created by Matt Overholt on 12/24/25.
//

import SwiftUI
import AppKit


// MARK: - Calculate line height

func calcLineHeight(_ font: NSFont) -> CGFloat {
    font.ascender - font.descender + font.leading
}

// MARK: - GrowingTextView2

struct GrowingTextView2: NSViewRepresentable {
    @Binding var text: String

    var maxLines: Int = 5
    
    var onSubmit: (() -> Void)? = nil
    var onBlur: (() -> Void)? = nil
    
    var font: NSFont = .systemFont(ofSize: 14)
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        // NSTextView setup
        let textView = NSTextView()
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.isRichText = false
        textView.usesFontPanel = false
        textView.importsGraphics = false
        textView.allowsUndo = true
        textView.font = font
        textView.textContainerInset = NSSize(width: 6, height: 6)
        textView.backgroundColor = .clear
        
        if let container = textView.textContainer {
            container.widthTracksTextView = true
            container.heightTracksTextView = false
        }
        
        // NSScrollView setup
        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // Initial height = 1 line
        let lineHeight = calcLineHeight(font)
        let initialHeight = lineHeight + textView.textContainerInset.height * 2
        
        let heightConstraint = scrollView.heightAnchor.constraint(
            equalToConstant: initialHeight
        )
        heightConstraint.isActive = true
        
        // Wire up coordinator
        context.coordinator.textView = textView
        context.coordinator.scrollView = scrollView
        context.coordinator.heightConstraint = heightConstraint
        
        textView.delegate = context.coordinator
        textView.string = text
        
        // Initial layout
        context.coordinator.recalcHeight()
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        // 🔑 Keep coordinator's parent in sync with latest GrowingTextView2
        context.coordinator.parent = self
        
        guard let textView = context.coordinator.textView else { return }
        
        // Sync SwiftUI → NSTextView
        if textView.string != text {
            textView.string = text
            context.coordinator.recalcHeight()
        }
    }
    
    // MARK: - Coordinator
    
    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: GrowingTextView2
        
        weak var textView: NSTextView?
        weak var scrollView: NSScrollView?
        var heightConstraint: NSLayoutConstraint?
        
        init(_ parent: GrowingTextView2) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = textView else { return }
            
            // NSTextView → SwiftUI
            parent.text = textView.string
            recalcHeight()
        }
        
        // Handle Return vs Shift+Return
        func textView(
            _ textView: NSTextView,
            doCommandBy commandSelector: Selector
        ) -> Bool {
            
            // Return key
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if let event = NSApp.currentEvent,
                   event.modifierFlags.contains(.shift) {
                    return false
                }
                
                // Plain Return = submit
                parent.onSubmit?()
                
                // If you want to clear after submit, you can also do:
                // parent.text = ""
                // textView.string = ""
                // recalcHeight()
                
                return true // we've handled it
            }
            
            // Shift+Return usually maps to insertLineBreak:
            if commandSelector == #selector(NSResponder.insertLineBreak(_:)) {
                // Let NSTextView handle it (insert newline)
                return false
            }
            
            return false
        }
        
        func textDidEndEditing(_ notification: Notification) {
            print("text did end editing")
            guard let tv = notification.object as? NSTextView,
                  tv === textView
            else { return }
            
            parent.onBlur?()
        }
        
        func textViewDidBlur(_ textView: NSView) {
            print("Text view did blur")
        }
        
        func recalcHeight() {
            guard
                let textView = textView,
                let scrollView = scrollView,
                let textContainer = textView.textContainer,
                let layoutManager = textView.layoutManager,
                let heightConstraint = heightConstraint
            else { return }
            
            let font = parent.font
            let lineHeight = calcLineHeight(font)
            let maxLines = CGFloat(parent.maxLines)
            let insets = textView.textContainerInset
            
            let minHeight = lineHeight + insets.height * 2
            let maxHeight = (lineHeight * maxLines) + insets.height * 2
            
            layoutManager.ensureLayout(for: textContainer)
            let usedRect = layoutManager.usedRect(for: textContainer)
            let desiredHeight = usedRect.height + insets.height * 2
//            print("Line height: \(lineHeight)")
//            print("Desired height: \(desiredHeight)")
            
            if desiredHeight <= maxHeight {
                scrollView.hasVerticalScroller = false
                heightConstraint.constant = max(desiredHeight, minHeight)
            } else {
                scrollView.hasVerticalScroller = true
                heightConstraint.constant = maxHeight
            }
            
            scrollView.needsLayout = true
            scrollView.layoutSubtreeIfNeeded()
        }
    }
}

struct GrowingTextView2UI: View {
    @Binding var text: String
    
    let placeholder: String?
    let onSubmit: () -> Void
    
    var body: some View {
        ZStack(alignment: .leadingFirstTextBaseline) {
            GrowingTextView2(text: $text, maxLines: 5) {
                onSubmit()
            }
            if text.isEmpty, let ph = placeholder {
                Text(ph)
            }
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    GrowingTextView2UI(
        text: $text,
        placeholder: "This is an example of a placeholder"
    ) {
        print("SUBMIT!")
        text = ""
    }
    .overlay(
        RoundedRectangle(
            cornerRadius: 12
        )
        .stroke(
            .separator,
            style: StrokeStyle(lineWidth: 1)
        )
    )
    .frame(width: 300, height: 400)
    .padding()
}
