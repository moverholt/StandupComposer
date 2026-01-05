//
//  Standup.swift
//  JWTMenu
//
//  Created by Matt Overholt on 12/27/25.
//

import Foundation
import UniformTypeIdentifiers

func wsUpdatePrompt(_ updates: [Workstream.Update]) -> String {
    var base: [String] = [
        "Write a brief, concise, readable, and friendly daily standup for 1 workstream.",
        "Do not include any future plans.",
        "The expected response is 1 paragraph summary of the day's work that is displayed below as user recorded updates.",
        "Do not include any temporal framing.",
        "This paragraph is part of a larger standup. This update is for 1 workstream of many."
    ]
    
    base.append("Below are user recored updates, recorded since last standup:")
    for u in updates.available {
        base.append("** User recorded update \(u.day.description) **: \(u.body)")
    }
    
    return base.joined(separator: "\n")
}

enum SelectStandup: Codable, Hashable {
    case none
    case existing(Standup.ID)
    case new
    
    var id: Standup.ID? {
        switch self {
        case .existing(let id):
            return id
        case .none:
            return nil
        case .new:
            return nil
        }
    }
}

struct Standup: Codable, Identifiable {
    let id: UUID
    let day: IsoDay
    var title: String
    let created: Date
    var updated: Date
    var updates: [WorkstreamUpdate]
    var deleted: Bool = false
    
    init(_ day: IsoDay) {
        self.init(day, title: "New Standup")
    }

    init(_ day: IsoDay, title: String) {
        id = UUID()
        self.day = day
        self.title = title
        let now = Date()
        created = now
        updated = now
        updates = []
    }
}

extension [Standup] {
    func find(id: Standup.ID) -> Standup? {
        first(where: { $0.id == id })
    }
    
    func findIndex(id: Standup.ID) -> Int? {
        firstIndex(where: { $0.id == id })
    }
    
    func first(day: IsoDay) -> Standup? {
        first(where: { $0.day == day })
    }
    
    var available: [Standup] {
        self.filter({ $0.deleted == false })
    }
    
    var sortByUpdatedDesc: [Standup] {
        self.sorted { lhs, rhs in
            lhs.created > rhs.created
        }
    }
}

extension [Standup.WorkstreamUpdate] {
    func find(wsid: Standup.WorkstreamUpdate.ID) -> Standup.WorkstreamUpdate? {
        first(where: { $0.ws.id == wsid })
    }
    
    func findIndex(wsid: Standup.WorkstreamUpdate.ID) -> Int? {
        firstIndex(where: { $0.ws.id == wsid })
    }
}

extension Standup {
    struct WorkstreamUpdate: Codable, Identifiable {
        struct WorkstreamMeta: Codable, Identifiable, Hashable {
            let id: UUID
            let title: String
            let issueKey: String?
            
            init(_ ws: Workstream) {
                id = ws.id
                title = ws.title
                issueKey = ws.issueKey
            }
        }
        
        struct GeneratorState: Codable, Hashable {
            var active: Bool = false
            var partial: String? = nil
            var final: String? = nil
            var error: String? = nil
        }
        
        let id: UUID
        let ws: WorkstreamMeta
        var body: String?
        var ai: GeneratorState
        
        init(_ ws: Workstream) {
            id = UUID()
            ai = GeneratorState()
            self.ws = WorkstreamMeta(ws)
        }
    }
}

extension Standup {
    
    @Observable
    @MainActor
    final class Store {
        static let shared = Store()
        
        init() {
            loadModels()
        }
        
        var models: [Standup] = [] {
            didSet {
                saveModels()
            }
        }
        
        private var modelsFileURL: URL {
            let fm = FileManager.default
            let appSupport = try! fm.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let dir = appSupport.appendingPathComponent("JWTMenu", isDirectory: true)
            if !fm.fileExists(atPath: dir.path) {
                try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
            }
            return dir.appendingPathComponent("standups-v3.json", conformingTo: .json)
        }
        
        private func saveModels() {
            do {
                print("Saving standups: \(models.count.description)")
                let data = try JSONEncoder().encode(models)
                try data.write(to: modelsFileURL, options: [.atomic])
            } catch {
                NSLog("Failed to save standups: \(error.localizedDescription)")
            }
        }
        
        func loadModels() {
            do {
                let data = try Data(contentsOf: modelsFileURL)
                let decoded = try JSONDecoder().decode([Standup].self, from: data)
                print("Loaded models: \(decoded.count.description)")
                models = decoded
            } catch {
                models = []
            }
        }
    }
}
