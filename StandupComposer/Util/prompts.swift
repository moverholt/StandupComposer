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
