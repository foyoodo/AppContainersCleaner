//
//  Folder.swift
//  ContainersCleaner
//
//  Created by foyoodo on 2/11/2024.
//

import Foundation
import AppKit

struct Folder: Hashable, Comparable, Identifiable {
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

    static func < (lhs: Folder, rhs: Folder) -> Bool {
        lhs.metadata.identifier < rhs.metadata.identifier
    }
}

struct MCMMetadata: Equatable, Decodable {
    let identifier: String

    enum CodingKeys: String, CodingKey {
        case identifier = "MCMMetadataIdentifier"
    }
}
