//
//  UserSettings.swift
//  JWTMenu
//
//  Created by Matt Overholt on 12/21/25.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class UserSettings {
    private let defaults = UserDefaults.standard

    static let shared = UserSettings()

    static let defaultOpenAIHost = "https://api.openai.com"

    // MARK: - Keys

    private enum Keys: String {
        case openAIApiKey = "Settings.openAIApiKey"
        case openAIApiUrl = "Settings.openAIApiUrl"
        case openAISelectedModel = "Settings.openAISelectedModel"
        case jiraAccessToken = "Settings.jiraAccessToken"
        case jiraUrl = "Settings.jiraUrl"
        case workspaceSelected = "Settings.workspaceSelected"
        case workspaceColumnVisibility = "Settings.workspaceColumnVisibility"
        case workspaceShowInspector = "Settings.workspaceShowInspector"
    }

    // MARK: - Stored Properties

    var openAIApiKey: String? = nil {
        didSet { saveOpenAIApiKey() }
    }

    var openAIApiUrl: String = defaultOpenAIHost {
        didSet { saveOpenAIApiUrl() }
    }

    var openAISelectedModel: String = "gpt-4.1-nano" {
        didSet { saveOpenAISelectedModel() }
    }

    var jiraAccessToken: String? = nil {
        didSet { saveJiraAccessToken() }
    }

    var jiraUrl: String = "" {
        didSet { saveJiraUrl() }
    }

    var workspaceSelected: WorkspaceSelected = .none {
        didSet {
            saveWorkspaceSelected()
            if workspaceShowInspector && !workspaceSelected.hasInspector {
                workspaceShowInspector = false
            }
        }
    }

    var workspaceColumnVisibility: NavigationSplitViewVisibility = .all {
        didSet { saveWorkspaceColumnVisibility() }
    }

    var workspaceShowInspector: Bool = false {
        didSet { saveWorkspaceShowInspector() }
    }

    // MARK: - Init

    init() {
        loadOpenAIApiKey()
        loadOpenAIApiUrl()
        loadOpenAISelectedModel()
        loadJiraAccessToken()
        loadJiraUrl()
        loadWorkspaceSelected()
        loadWorkspaceColumnVisibility()
        loadWorkspaceShowInspector()
    }

    // MARK: - Persistence

    private func saveOpenAIApiKey() {
        saveKey(openAIApiKey, for: .openAIApiKey)
    }

    private func saveOpenAIApiUrl() {
        saveKey(openAIApiUrl, for: .openAIApiUrl)
    }

    private func saveOpenAISelectedModel() {
        saveKey(openAISelectedModel, for: .openAISelectedModel)
    }

    private func saveJiraAccessToken() {
        saveKey(jiraAccessToken, for: .jiraAccessToken)
    }

    private func saveJiraUrl() {
        saveKey(jiraUrl, for: .jiraUrl)
    }

    private func saveWorkspaceSelected() {
        saveKey(workspaceSelected, for: .workspaceSelected)
    }

    private func saveWorkspaceColumnVisibility() {
        saveKey(workspaceColumnVisibility, for: .workspaceColumnVisibility)
    }

    private func saveWorkspaceShowInspector() {
        saveKey(workspaceShowInspector, for: .workspaceShowInspector)
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

    private func loadOpenAIApiUrl() {
        self.openAIApiUrl = loadKey(.openAIApiUrl) ?? Self.defaultOpenAIHost
    }

    private func loadOpenAISelectedModel() {
        self.openAISelectedModel = loadKey(.openAISelectedModel) ?? "gpt-4.1-nano"
    }

    private func loadJiraAccessToken() {
        self.jiraAccessToken = loadKey(.jiraAccessToken) ?? ""
    }

    private func loadJiraUrl() {
        self.jiraUrl = loadKey(.jiraUrl) ?? ""
    }

    private func loadWorkspaceSelected() {
        self.workspaceSelected = loadKey(.workspaceSelected) ?? .none
    }

    private func loadWorkspaceColumnVisibility() {
        self.workspaceColumnVisibility = loadKey(.workspaceColumnVisibility) ?? .all
    }

    private func loadWorkspaceShowInspector() {
        self.workspaceShowInspector = loadKey(.workspaceShowInspector) ?? false
    }

    private func loadKey<T: Codable>(_ key: Keys) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
