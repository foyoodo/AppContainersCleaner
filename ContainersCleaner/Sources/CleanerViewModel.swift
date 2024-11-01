//
//  CleanerViewModel.swift
//  ContainersCleaner
//
//  Created by foyoodo on 1/11/2024.
//

import Foundation
import AppKit

struct Folder: Hashable, Identifiable {
    let url: URL
    let metadata: MCMMetadata

    var id: URL { url }
    var name: String {
        if let applicationURL,
           let bundle = Bundle(url: applicationURL),
           let appName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return appName
        }
        return url.lastPathComponent
    }

    var icon: NSImage {
        guard let applicationURL else {
            return NSWorkspace.shared.icon(for: .folder)
        }
        return NSWorkspace.shared.icon(forFile: applicationURL.path())
    }

    private var bundleIdentifier: String {
        let components = metadata.identifier.components(separatedBy: ".")
        guard components.count > 3 else { return metadata.identifier }
        return components.prefix(3).joined(separator: ".")
    }

    private var applicationURL: URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

struct MCMMetadata: Equatable, Decodable {
    let identifier: String

    enum CodingKeys: String, CodingKey {
        case identifier = "MCMMetadataIdentifier"
    }
}

@Observable
final class CleanerViewModel {
    let path = FileManager.default.homeDirectoryForCurrentUser.appending(
        components: "Library", "Containers"
    )

    private let decoder = PropertyListDecoder()

    private var allFolders: [Folder] = [] { didSet { folders = allFolders } }
    var folders: [Folder] = []

    var selectedFolders = Set<Folder>()

    var searchPresented: Bool = false

    func scan() throws {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: path,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        ) else { return }

        allFolders = try contents.compactMap { url in
            if url.lastPathComponent.hasPrefix("com.apple") { return nil }
            let plistURL = url.appending(component: ".com.apple.containermanagerd.metadata.plist")
            let data = try Data(contentsOf: plistURL)
            do {
                let metadata = try decoder.decode(MCMMetadata.self, from: data)
                return .init(url: url, metadata: metadata)
            } catch {
                throw CleanerError.metadataDecodeFailed
            }
        }
    }

    func search(_ text: String) {
        guard !text.isEmpty else { folders = allFolders; return }
        folders = allFolders.filter { $0.metadata.identifier.contains(text)}
    }

    func showInFinder(_ folder: Folder) {
        NSWorkspace.shared.activateFileViewerSelecting([folder.url])
    }

    func moveToTrash(_ folder: Folder) throws {
        try FileManager.default.trashItem(at: folder.url, resultingItemURL: nil)
        allFolders.removeAll { $0 == folder }
    }
}
