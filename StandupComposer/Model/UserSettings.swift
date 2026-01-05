//
//  UserSettings.swift
//  JWTMenu
//
//  Created by Matt Overholt on 12/21/25.
//

import Foundation

@Observable
@MainActor
final class UserSettings {
    private let defaults = UserDefaults.standard
    
    static let shared = UserSettings()
    
    // MARK: - Keys
    private enum Keys: String {
        case workspaceSelected = "Settings.workspaceSelected"
        case openAIApiKey = "Settings.openAIApiKey"
    }

    // MARK: - Stored Properties
    var workspaceSelected: WorkspaceSelected = .none {
        didSet { saveWorkspaceSelected() }
    }
    
    var openAIApiKey: String? = nil {
        didSet { saveOpenAIApiKey() }
    }

    // MARK: - Init
    init() {
        loadWorkspaceSelected()
        loadOpenAIApiKey()
    }

    // MARK: - Persistence
    private func saveWorkspaceSelected() {
        saveKey(workspaceSelected, for: .workspaceSelected)
    }
    
    private func saveOpenAIApiKey() {
        saveKey(openAIApiKey, for: .openAIApiKey)
    }
    
    private func saveKey<T: Codable>(_ value: T?, for key: Keys) {
        if let val = value {
            if let data = try? JSONEncoder().encode(val) {
                defaults.set(data, forKey: key.rawValue)
            } else {
                defaults.removeObject(forKey: key.rawValue)
            }
        } else {
            defaults.removeObject(forKey: key.rawValue)
        }
    }

    private func loadOpenAIApiKey() {
        self.openAIApiKey = loadKey(.openAIApiKey) ?? ""
        
    }
    
    private func loadWorkspaceSelected() {
        self.workspaceSelected = loadKey(.workspaceSelected) ?? .none
    }
    
    private func loadKey<T: Codable>(_ key: Keys) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
