//
//  StandFormattedView.swift
//  StandupComposer
//
//  Created by Developer on 2025-12-29.
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

private struct SelectableFormattedTextView: NSViewRepresentable {
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

struct StandFormattedView: View {
    @Environment(UserSettings.self) var settings
    let stand: Standup

    @State private var partial: String?
    @State private var loading = false
    @State private var error: String?
    @State private var selectAllRequested = false

    @MainActor
    private func run() async {
//        loading = true
//        error = nil
//        partial = ""
//        let prompt = slackFormatterPrompt(stand, jiraBaseUrl: settings.jiraUrl)
//        let stream = streamOpenAIChat(
//            prompt: prompt,
//            config: OpenAIConfig(settings)
//        )
//        do {
//            for try await partial in stream {
//                self.partial = partial
//            }
//            stand.formattedSlack = self.partial
//        } catch {
//            self.error = error.localizedDescription
//        }
//        partial = nil
//        loading = false
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                if let body = partial ?? stand.formattedSlack {
                    SelectableFormattedTextView(content: body, selectAllRequested: $selectAllRequested)
                        .frame(minHeight: 120, maxHeight: .infinity)
                }
                HStack(spacing: 8) {
                    Button(
                        action: {
                            Task {
                                await run()
                            }
                        }
                    ) {
                        Label("Format", systemImage: "wand.and.stars")
                    }
                    .disabled(loading)
                    if partial != nil || stand.formattedSlack != nil {
                        Button(action: { selectAllRequested = true }) {
                            Label("Select All", systemImage: "doc.on.doc")
                        }
                    }
                }
                if loading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
//            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var stand = Standup(UUID())
    StandFormattedView(stand: stand)
        .frame(width: 600, height: 400)
        .environment(UserSettings())
        .onAppear {
            var ws1 = Workstream(UUID())
            ws1.issueKey = "ZZZZ-9998"

            var up1 = Standup.WorkstreamGenUpdate(ws1)
//            up1.body = "This is a test update."
//            stand.prevDay.append(up1)
//
//            var ws2 = Workstream()
//            ws2.issueKey = "ZZZZ-9999"
//
//            var up2 = Standup.WorkstreamGenUpdate(ws2)
//            up2.body = "This is another test update."
//            stand.prevDay.append(up2)
//
//            var pl1 = Standup.WorkstreamGenUpdate(ws1)
//            pl1.body = "This is a plan."
//            stand.today.append(pl1)
//
//            var pl2 = Standup.WorkstreamGenUpdate(ws2)
//            pl2.body = "This is another test plan."
//            stand.today.append(pl2)
        }
}
