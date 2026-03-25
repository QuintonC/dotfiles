#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Copy Standup Section
// @raycast.mode silent

// Optional parameters:
// @raycast.icon 🤖
// @raycast.argument1 { "type": "dropdown", "placeholder": "Section", "data": [{"title": "Today", "value": "1"}, {"title": "Tomorrow", "value": "2"}, {"title": "Blockers", "value": "3"}] }

// Documentation:
// @raycast.description Copies a section of today's standup as rich text with clickable links
// @raycast.author quinton
// @raycast.authorURL https://raycast.com/quinton

import Cocoa

let sectionNum = Int(CommandLine.arguments[1]) ?? 1

// Resolve today's standup file using ISO 8601 week numbering
let calendar = Calendar(identifier: .iso8601)
let now = Date()
let year = calendar.component(.yearForWeekOfYear, from: now)
let week = calendar.component(.weekOfYear, from: now)
let weekday = calendar.component(.weekday, from: now)
// Calendar weekday: 1=Sun, 2=Mon...7=Sat → ISO: 1=Mon...7=Sun
let isoDay = weekday == 1 ? 7 : weekday - 1

let home = FileManager.default.homeDirectoryForCurrentUser.path
let filePath = "\(home)/Activity/\(year)-\(String(format: "%02d", week))/\(isoDay).md"

guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
    print("Could not read \(filePath)")
    exit(1)
}

// Extract the requested section (raw markdown)
let lines = content.components(separatedBy: "\n")
var currentSection = 0
var sectionLines: [String] = []
var found = false

for line in lines {
    if line.hasPrefix("## ") {
        currentSection += 1
        if currentSection == sectionNum {
            found = true
            continue
        } else if found {
            break
        }
    }
    if found {
        sectionLines.append(line)
    }
}

guard !sectionLines.isEmpty else {
    print("Section \(sectionNum) not found in \(filePath)")
    exit(1)
}

// Convert markdown to HTML lines with custom list formatting
let linkPattern = try! NSRegularExpression(pattern: "\\[([^\\]]+)\\]\\(([^)]+)\\)")
var htmlLines: [String] = []

for line in sectionLines {
    // Skip empty lines
    guard !line.trimmingCharacters(in: .whitespaces).isEmpty else { continue }

    // Determine indent level and strip list marker
    var indent = 0
    var processed = line
    if let range = processed.range(of: "^(\\s*)- ", options: .regularExpression) {
        let leading = line.prefix(while: { $0 == " " })
        indent = leading.count / 2
        processed = String(processed[range.upperBound...])
    }

    // Convert [text](url) → <a href="url">text</a>
    let mutable = NSMutableString(string: processed)
    linkPattern.replaceMatches(
        in: mutable,
        range: NSRange(location: 0, length: mutable.length),
        withTemplate: "<a href=\"$2\">$1</a>"
    )

    // Format with bullet and indentation matching Geekbot's style
    let bullets = ["•", "◦", "‣", "⁃"]
    let bullet = bullets[min(indent, bullets.count - 1)]
    let padding = String(repeating: "&nbsp;&nbsp;&nbsp;&nbsp;", count: indent)
    htmlLines.append("\(padding)\(bullet) \(mutable)")
}

let html = htmlLines.joined(separator: "<br>")

// Plain text fallback
let plainText = sectionLines
    .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    .joined(separator: "\n")

// Set clipboard as HTML + plain text
let pb = NSPasteboard.general
pb.clearContents()
pb.declareTypes([.html, .string], owner: nil)
pb.setString(html, forType: .html)
pb.setString(plainText, forType: .string)

print("Copied to clipboard")
