//
//  CleanerViewModel.swift
//  ContainersCleaner
//
//  Created by foyoodo on 1/11/2024.
//

import Foundation
import AppKit

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

        let folders: [Folder] = try contents.compactMap { url in
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

        allFolders = folders.sorted()
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
