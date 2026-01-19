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
        "2. Publishing Agent: Formats and publishes standup content to external systems."
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
        "7. +24: Next 24 hours section with AI generated summaries of planned work."
    ]
)

private let styleGuideBlock: Block = (
    "Writing Style Guide",
    [
        "Write brief, concise, readable, and friendly sentences.",
        "Do not use temporal framing or dashes."
    ]
)

private let editingStyleBlock: Block = (
    "Summarization Style",
    [
        "Summarize only the content explicitly provided in the context.",
        "Do not add information beyond what is specified.",
        "Condense multiple related items into coherent sentences.",
        "Focus on the essential information that communicates the workstream's status."
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
    blocks.append((
        "Writing Agent Assignment",
        [
            "Role: You are the StandupComposer Writing Agent.",
            "Task: Generate a summary update for the -24 section of a standup.",
            "Target Workstream: \(ws.title)",
            "Input Sources: Use the workstream updates and completed plans provided below.",
            "Output Goal: Create a concise summary that communicates what happened in this workstream during the previous 24 hours."
        ]
    ))
    
    blocks.append((
        "Input Data: Workstream Updates",
        updates.isEmpty ? ["No updates available."] : updates.map({ $0.body })
    ))
    
    blocks.append((
        "Input Data: Completed Workstream Plans",
        ws.plans.complete.isEmpty ? ["No completed plans available."] : completedPlans.map({ $0.body })
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
    
    blocks.append((
        "Writing Agent Assignment",
        [
            "Role: You are the StandupComposer Writing Agent.",
            "Task: Generate a summary update for the +24 section of a standup.",
            "Target Workstream: \(ws.title)",
            "Input Sources: Use the incomplete workstream plans provided below.",
            "Output Goal: Create a concise summary that communicates what is planned for this workstream in the next 24 hours."
        ]
    ))
    
    blocks.append((
        "Input Data: Incomplete Workstream Plans",
        plans.incomplete.isEmpty ? ["No incomplete plans available."] : plans.incomplete.map({ $0.body })
    ))
    
    return combine(blocks)
}

#Playground {
    let ws = Workstream()
    let _ = wsPlanPrompt(ws, [])
}


func slackFormatterPrompt(_ stand: Standup) -> String {
    var blocks: [Block] = []
    blocks.append(appBlock)
    blocks.append(domainBlock)
    
    blocks.append((
        "Publishing Agent Assignment",
        [
            "Role: You are the StandupComposer Publishing Agent.",
            "Task: Assemble the individual -24 updates and +24 plans below into a single, clean string ready to copy and paste into Slack.",
            "Input: Two sections are provided. -24 contains workstream updates (what was done in the previous 24 hours). +24 contains workstream plans (what is planned for the next 24 hours). Each item includes workstream title, optional issue key, and an AI-generated summary.",
            "Output: Produce one formatted string with exactly two sections. Output only the standup content.",
            "Structure: Two sections with clear visual separation. -24 first, then +24. Each workstream: lead with the workstream (issue key + title), then the body. Omit [ISSUE-KEY] when none. Empty or \"None\" bodies: omit that workstream. Omit a section entirely if it has no valid items.",
            "Formatting (all render in Slack):",
            "  • Section headers: put each on its own line, e.g. *═══ -24 ═══* or *─── +24 ───* or *► -24* / *► +24*. Pick one style and use it for both.",
            "  • Workstream lead: *bold* for the title. If there is an issue key use `KEY` (backticks) before the title, e.g. *`FOOD-10` Add new pasta types*. Otherwise *Workstream title* only.",
            "  • Body: on the next line(s), indented with spaces or a prefix like ▸ │ ► ▪. You may use • for sub-bullets if the body has multiple points.",
            "  • Dividers: between workstreams use a blank line, or a light rule like ─── or ···. Between -24 and +24 use a slightly stronger break (e.g. blank line + section header).",
            "  • Emphasis: _italic_ for occasional emphasis in the body. `code` for IDs, names, or technical terms. *Bold* only for workstream titles and section headers.",
            "  • Symbols: ► ▸ ▪ • │ ─ ═ · are fine. Use sparingly so it stays scannable.",
            "Be creative: mix header rules (═══, ───), bullets (►, ▸, ▪), and spacing to make -24 and +24 distinct and easy to scan. Stay consistent within one standup.",
            "Empty or missing content: If an update or plan is \"None\" or empty, omit that workstream. If an entire section has no valid items, omit that section header and its items.",
            "Tone: Professional, concise, and scannable. Preserve the meaning of each summary; do not paraphrase or add information."
        ]
    ))
    
    blocks.append((
        "-24",
        stand.prevDay.flatMap({ upd in
            var arr: [String] = [
                "Workstream: \(upd.ws.title)"
            ]
            if let key = upd.ws.issueKey {
                arr.append("Issue key: \(key)")
            }
            arr.append("Update: \(upd.ai.final ?? "None")")
            arr.append("**** ****")
            return arr
        })
    ))
    
    blocks.append((
        "+24",
        stand.today.flatMap({ pln in
            var arr: [String] = [
                "Workstream: \(pln.ws.title)"
            ]
            if let key = pln.ws.issueKey {
                arr.append("Issue key: \(key)")
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
