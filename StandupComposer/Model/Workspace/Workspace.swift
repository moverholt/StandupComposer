//
//  Workspace.swift
//  StandupComposer
//
//  Created by Matt Overholt on 1/2/26.
//

import Foundation


struct Workspace: Codable, CustomStringConvertible, Identifiable  {
    let id: UUID
    var title: String
    
    init() {
        id = UUID()
        title = "New Workspace"
    }
    
    var description: String { title }
}
