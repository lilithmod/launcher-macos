//
//  VersionManifest.swift
//  Lilith-Launcher
//
//  Created by 0x41c on 2022-04-22.
//

import Foundation

struct VersionManifest: Codable {
    let version: String
    let name: String
    
    init(fromFile: String) throws {
        let data = try String(contentsOfFile: fromFile).data(using: .utf8)
        self = try JSONDecoder().decode(VersionManifest.self, from: data!)
    }
    
    init(fromURL: String) async throws {
        let (data, _ ) = try await URLSession.shared.data(from: URL(string: fromURL)!)
        self = try JSONDecoder().decode(VersionManifest.self, from: data)
    }
    
    init(fromData data: Data) throws {
        self = try JSONDecoder().decode(VersionManifest.self, from: data)
    }
    
    func save(toFile: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        try String(data: data, encoding: .utf8)?.write(toFile: toFile, atomically: true, encoding: .utf8)
    }
}
