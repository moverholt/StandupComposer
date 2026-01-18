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
        "Name: StandupComposer",
        "This app has 2 types of AI agents.",
        "1. Writing Agent",
        "2. Publishing Agent"
    ]
)

private let domainBlock: Block = (
    "Domain Details",
    [
        "Below is a dictionary of terms used by this application",
        "1. Workspace",
        "2. Workstream",
        "3. Workstream Update",
        "4. Workstream Plan",
        "5. Standup",
        "6. Standup Update",
        "-24",
        "+24"
    ]
)

private let styleGuideBlock: Block = (
    "Writing Style Guide",
    [
        "Write brief, concise, readable, and friendly sentences.",
        "Do not use any temporal framing.",
        "Do not use dashes or emdashes.",
        "Do not elaborate or extend the provided context.",
        "Only write what is explicitly specified from the context."
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
    blocks.append((
        "Writing Agent Assignment",
        [
            "You are StandupComposer writing agent.",
            "Write an update (-24) for the workstream: \(ws.title)",
            "Use notes the deceloper recorded as workstream updates to generate few sentences that will help the publishing agent understand the workstream's previous 24."
        ]
    ))
    
    blocks.append((
        "Updates since last standup:",
        updates.isEmpty ? ["None"] : updates.map({ $0.body })
    ))
    
    blocks.append((
        "Plans completed since last standup:",
        ws.plans.complete.isEmpty ? ["None"] : completedPlans.map({ $0.body })
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
    
    blocks.append((
        "Writing Agent Assignment",
        [
            "You are StandupComposer writing agent.",
            "Write an update (+24) for the workstream: \(ws.title)",
            "Use user recorded plans to generate few sentences that will help the publishing agent understand the workstream's next 24."
        ]
    ))
    
    blocks.append((
        "Planned work:",
        plans.incomplete.isEmpty ? ["None"] : plans.incomplete.map({ $0.body })
    ))
    
    return combine(blocks)
}

#Playground {
    let ws = Workstream()
    let _ = wsPlanPrompt(ws, [])
}
