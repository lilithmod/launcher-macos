//
//  Entry.swift
//  Lilith-Launcher
//
//  Created by 0x41c on 2022-04-22.
//

import Foundation
import AppKit

let fm = FileManager.default
let lilithPath = "\(fm.homeDirectoryForCurrentUser.path)/.lilith"
let lilithExecPath = "\(lilithPath)/lilith"
let versionFile = "\(lilithPath)/version.txt"
let versionURL = "https://api.lilithmod.xyz/versions/latest"
let execWrapper = "\(lilithPath)/donottouchunlessyouknowwhatyourdoing"

@main
enum Entry {
    static func main() async {
        do {
            if !fm.fileExists(atPath: versionFile) || !fm.fileExists(atPath: lilithExecPath) {
                try await downloadLatest()
            } else {
                let localData = try VersionManifest(fromFile: versionFile)
                let latestData = try await VersionManifest(fromURL: versionURL)
                if localData.version != latestData.version {
                    try await downloadLatest()
                }
            }
            
            if !fm.fileExists(atPath: execWrapper) {
                try """
                #/bin/bash
                \(lilithExecPath) --iknowwhatimdoing
                read -p "Press enter to exit..."
                killall Terminal
                """.write(toFile: execWrapper, atomically: true, encoding: .utf8)
                try utils_runCommand(command: "chmod +x \(execWrapper)")
            }
            
            try utils_runCommand(command: "chmod +x \(lilithExecPath)")
            try utils_runCommand(command: "open -a Terminal -W \(execWrapper)")
            try utils_runCommand(command: "killall Terminal")
        } catch {
            // Uh oh stinky
            stinky("\(error)")
        }
    }
}

func downloadLatest() async throws {
    print("Downloading latest lilith version")
    if !fm.fileExists(atPath: lilithPath) {
        try utils_runCommand(command: "mkdir \(lilithPath)")
    }
    try await VersionManifest(fromURL: versionURL).save(toFile: versionFile)
    let (data, _) = try await URLSession.shared.data(from: URL(string: "https://api.lilithmod.xyz/download/macos")!)
    let url = URL(fileURLWithPath: lilithExecPath)
    try data.write(to: url)
}

func stinky(_ message: String) -> Never {
    let alert = NSAlert()
    alert.messageText = "Unable to run"
    alert.informativeText = message
    alert.addButton(withTitle: "Damn it... fine")
    alert.alertStyle = .critical
    alert.runModal()
    exit(1)
}

func utils_runCommand(command: String) throws {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    
    try task.run()
}
