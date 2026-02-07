//
//  SelectableFormattedTextView.swift
//  StandupComposer
//

import AppKit
import SwiftUI

private func prepareLineForMarkdown(_ s: String) -> String {
    var out = s.replacingOccurrences(of: "\r\n", with: "\n")
    if let slackLinkRegex = try? NSRegularExpression(pattern: "<([^|>]+)\\|([^>]+)>") {
        out = slackLinkRegex.stringByReplacingMatches(
            in: out,
            range: NSRange(out.startIndex..<out.endIndex, in: out),
            withTemplate: "[$2]($1)"
        )
    }
    return out
}

private func makeAttributedString(for content: String) -> NSAttributedString {
    let prepared = prepareLineForMarkdown(content)
    let lines = prepared.components(separatedBy: "\n")
    let result = NSMutableAttributedString()
    for (idx, line) in lines.enumerated() {
        if line.isEmpty {
            result.append(NSAttributedString(string: "\n"))
        } else {
            let att = (try? AttributedString(markdown: line)) ?? AttributedString(line)
            result.append(NSAttributedString(att))
            if idx < lines.count - 1 {
                result.append(NSAttributedString(string: "\n"))
            }
        }
    }
    return applySemanticColors(to: result)
}

private func applySemanticColors(to str: NSMutableAttributedString) -> NSAttributedString {
    str.enumerateAttributes(in: NSRange(location: 0, length: str.length)) { attrs, range, _ in
        let color: NSColor = attrs[.link] != nil ? .linkColor : .labelColor
        str.addAttribute(.foregroundColor, value: color, range: range)
    }
    return str
}

struct SelectableFormattedTextView: NSViewRepresentable {
    let content: String
    @Binding var selectAllRequested: Bool

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false

        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.textColor = .labelColor
        textView.textStorage?.setAttributedString(makeAttributedString(for: content))
        scrollView.documentView = textView

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        let next = makeAttributedString(for: content)
        if textView.attributedString().string != next.string {
            textView.textStorage?.setAttributedString(next)
        }

        if selectAllRequested {
            selectAllRequested = false
            if let window = textView.window {
                window.makeFirstResponder(textView)
            }
            textView.selectAll(nil)
        }
    }
}
