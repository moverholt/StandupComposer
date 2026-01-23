//
//  prompts.swift
//  StandupComposer
//
//  Created by Matt Overholt on 1/11/26.
//

import Foundation
import Playgrounds

private typealias Block = (title: String, content: [String])

private let appBlock: Block = (
    "Application Details",
    [
        "Application Name: StandupComposer",
        "AI Agent Types: This application uses 2 distinct AI agents to process standup content.",
        "1. Writing Agent: Generates AI summaries for standup sections from workstream updates and plans.",
        "2. Publishing Agent: Formats and publishes standup content to external systems.",
    ]
)

private let domainBlock: Block = (
    "Domain Dictionary",
    [
        "Below is a dictionary of terms used by this application",
        "1. Workspace: Top level container for workstreams and standups.",
        "2. Workstream: Project or task that tracks work with updates and plans.",
        "3. Workstream Update: Developer note about completed work on a workstream.",
        "4. Workstream Plan: Planned task or goal for a workstream.",
        "5. Standup: Daily document with prevDay (-24) and today (+24) sections summarizing work.",
        "6. -24: Previous 24 hours section with AI generated summaries of completed work.",
        "7. +24: Next 24 hours section with AI generated summaries of planned work.",
    ]
)

private let styleGuideBlock: Block = (
    "Writing Style Guide",
    [
        "Write brief, concise, readable, and friendly sentences.",
        "Do not use temporal framing or dashes.",
    ]
)

private let editingStyleBlock: Block = (
    "Summarization Style",
    [
        "Summarize only the content explicitly provided in the context.",
        "Do not add information beyond what is specified.",
        "Condense multiple related items into coherent sentences.",
        "Focus on the essential information that communicates the workstream's status.",
    ]
)

private func combine(_ blocks: [Block]) -> String {
    var lines: [String] = []
    for b in blocks {
        lines.append("**** Start section: \(b.title) ****")
        lines.append(b.content.joined(separator: "\n"))
        lines.append("**** End section: \(b.title) ****")
        lines.append("")
    }
    return lines.joined(separator: "\n")
}

func wsUpdatePrompt(
    _ ws: Workstream,
    _ completedPlans: [Workstream.Plan],
    _ updates: [Workstream.Update]
) -> String {
    var blocks: [Block] = []
    blocks.append(appBlock)
    blocks.append(domainBlock)
    blocks.append(styleGuideBlock)
    blocks.append(editingStyleBlock)
    blocks.append(
        (
            "Writing Agent Assignment",
            [
                "Role: You are the StandupComposer Writing Agent.",
                "Task: Generate a summary update for the -24 section of a standup.",
                "Target Workstream: \(ws.title)",
                "Input Sources: Use the workstream updates and completed plans provided below.",
                "Output Goal: Create a concise summary that communicates what happened in this workstream during the previous 24 hours.",
            ]
        ))

    blocks.append(
        (
            "Input Data: Workstream Updates",
            updates.isEmpty ? ["No updates available."] : updates.map({ $0.body })
        ))

    blocks.append(
        (
            "Input Data: Completed Workstream Plans",
            ws.plans.complete.isEmpty
                ? ["No completed plans available."] : completedPlans.map({ $0.body })
        ))

    return combine(blocks)
}

#Playground {
    let ws = Workstream()
    let _ = wsUpdatePrompt(ws, [], [])
}

func wsPlanPrompt(
    _ ws: Workstream,
    _ plans: [Workstream.Plan]
) -> String {
    var blocks: [Block] = []
    blocks.append(appBlock)
    blocks.append(domainBlock)
    blocks.append(styleGuideBlock)
    blocks.append(editingStyleBlock)

    blocks.append(
        (
            "Writing Agent Assignment",
            [
                "Role: You are the StandupComposer Writing Agent.",
                "Task: Generate a summary update for the +24 section of a standup.",
                "Target Workstream: \(ws.title)",
                "Input Sources: Use the incomplete workstream plans provided below.",
                "Output Goal: Create a concise summary that communicates what is planned for this workstream in the next 24 hours.",
            ]
        ))

    blocks.append(
        (
            "Input Data: Incomplete Workstream Plans",
            plans.incomplete.isEmpty
                ? ["No incomplete plans available."] : plans.incomplete.map({ $0.body })
        ))

    return combine(blocks)
}

#Playground {
    let ws = Workstream()
    let _ = wsPlanPrompt(ws, [])
}

private let slackFormatting = """
    You are generating text that will be posted to Slack via the Slack API.

    Follow Slack mrkdwn formatting rules exactly.

    General Rules
    - Use Slack mrkdwn, not standard Markdown.
    - Prefer clarity and readability in Slack’s UI.
    - Use line breaks (\\n) to separate sections.
    - Do not use unsupported Markdown features such as tables, headings, or HTML.

    Text Styling
    - Bold: wrap text in asterisks -> *bold*
    - Italic: wrap text in underscores -> _italic_
    - Strikethrough: wrap text in tildes -> ~strike~

    Lists
    - Use hyphens or bullets with line breaks:
      - Item one
      - Item two
    - Avoid numbered lists unless ordering is important.

    Code Formatting
    - Inline code: wrap in single backticks -> `code`
    - Code blocks: wrap in triple backticks: ```multi-line code```
    - Do not apply bold or italics inside code blocks.

    Quotes
    - Use > at the beginning of a line for block quotes:
    > This is a quoted line

    Links
    - Format links as:
    <https://example.com|Link text>
    - Do not show raw URLs unless necessary.

    Mentions (Only when explicitly requested)
    - Users: <@USERID>
    - Channels: <#CHANNELID>
    - User groups: <!subteam^GROUPID>
    - Special mentions:
    - <!here>
    - <!channel>
    - <!everyone>
    - Never invent IDs.

    Dates and Times
    - Use Slack’s date formatting when timestamps are provided:
    <!date^TIMESTAMP^FORMAT|fallback text>
    - Always include a human-readable fallback.

    Escaping Rules
    - Escape special characters:
    - & -> &amp;
    - < -> &lt;
    - > -> &gt;
    - Do this unless the characters are part of valid Slack formatting.

    Tone and Layout
    - Keep messages concise and scannable.
    - Use whitespace intentionally.
    - Avoid dense paragraphs.
    - Prefer short sections with clear separation.

    Output Constraints
    - Output only the Slack-formatted message text.
    - Do not include explanations or commentary.
    - Assume the message will be pasted directly into Slack.
    """

func slackFormatterPrompt(_ stand: Standup, jiraBaseUrl: String? = nil) -> String {
    var blocks: [Block] = []
    blocks.append(appBlock)
    blocks.append(domainBlock)
    blocks.append(("Slack mrkdwn format rules", [slackFormatting]))

    let base = (jiraBaseUrl ?? "").trimmingCharacters(in: .whitespaces)
    let jiraBrowse = base.isEmpty ? "" : (base.hasSuffix("/") ? String(base.dropLast()) : base)

    var pubContent = [
        "Role: You are the StandupComposer Publishing Agent.",
        "Task: Assemble the -24 and +24 items below into one plain-text string. The output will be copied and pasted into Slack. Use only Slack mrkdwn (https://docs.slack.dev/messaging/formatting-message-text/): *bold*, _italic_, `code`, ~strike~; links as <url> or <url|link text>; newlines for line breaks. Do not use Unicode symbols or decorative rules.",
        "Output: Exactly 2 sections: *-24* (past 24 hours) then *+24* (next 24 hours). Each workstream has 1 row in -24 and 1 row in +24. Every row must: (1) identify the workstream—bold the workstream title using *Workstream Name* format (e.g. *Add new pasta types to the pasta view* or *Import next month's menu*; use full title or clear abbreviated title); (2) state the update (in -24) or the plan (in +24). Omit a workstream row if its update or plan body is empty or \"None\". Omit a section entirely if it has no rows.",
        "Style: Bold the workstream title in each row using *Workstream Title* format, followed by the update or plan content.",
    ]
    if !jiraBrowse.isEmpty {
        pubContent.append(
            "When a workstream has a Jira URL, include a link as <url|ISSUE KEY> (e.g. <\(jiraBrowse)/browse/KEY|KEY>) so the issue key is the link text. The Jira link helps the reader navigate to the story."
        )
    }

    blocks.append(("Publishing Agent Assignment", pubContent))

    blocks.append(
        (
            "-24 (Individual workstream sections to assemble into the formatted standup)",
            stand.prevDay.flatMap({ upd in
                var arr: [String] = [
                    "**** Start Workstream: \(upd.ws.title) ****"
                ]
                arr.append("Issue key: \(upd.ws.issueKey ?? "None")")
                if !jiraBrowse.isEmpty, let key = upd.ws.issueKey, !key.isEmpty {
                    arr.append("Jira: \(jiraBrowse)/browse/\(key)")
                }
                arr.append("Update: \(upd.ai.final ?? "None")")
                arr.append("**** End workstream ****")
                return arr
            })
        ))

    blocks.append(
        (
            "+24 (Individual workstream sections to assemble into the formatted standup)",
            stand.today.flatMap({ pln in
                var arr: [String] = [
                    "**** Start Workstream: \(pln.ws.title) ****"
                ]
                arr.append("Issue key: \(pln.ws.issueKey ?? "None")")
                if !jiraBrowse.isEmpty, let key = pln.ws.issueKey, !key.isEmpty {
                    arr.append("Jira: \(jiraBrowse)/browse/\(key)")
                }
                arr.append("Plan: \(pln.ai.final ?? "None")")
                arr.append("**** ****")
                return arr
            })
        ))

    return combine(blocks)
}

#Playground {
    var s = Standup(.today, title: "Mon Jan 19")

    var ws1 = Workstream()
    ws1.title = "Add new pasta types to the pasta view"
    ws1.issueKey = "FOOD-10"
    var up1 = Standup.WorkstreamGenUpdate(ws1)
    up1.ai.final = "Met with product manager about new pasta types."
    s.prevDay.append(up1)
    var pl1 = Standup.WorkstreamGenUpdate(ws1)
    pl1.ai.final = "Update API to support to pasta attributes."
    s.today.append(pl1)

    var ws2 = Workstream()
    ws2.title = "Import next month's menu into the application"
    ws2.issueKey = "FOOD-20"
    var up2 = Standup.WorkstreamGenUpdate(ws2)
    up2.ai.final = "Tracked down API documents and started to build backend updates"
    s.prevDay.append(up2)
    var pl2 = Standup.WorkstreamGenUpdate(ws2)
    pl2.ai.final = "Meet with chefs to gather menu items."
    s.today.append(pl2)

    let p = slackFormatterPrompt(s)
}
