import SwiftUI

struct DiscoverPackage: Identifiable {
    let id: String
    let displayName: String
    let description: String
    let category: Category
    let type: BrewPackage.PackageType

    enum Category: String, CaseIterable {
        case browsers      = "Browsers"
        case development   = "Development"
        case databases     = "Databases"
        case devops        = "DevOps & Cloud"
        case media         = "Media & Design"
        case productivity  = "Productivity"
        case communication = "Communication"
        case security      = "Security"
        case utilities     = "Utilities"

        var symbol: String {
            switch self {
            case .browsers:      return "safari"
            case .development:   return "hammer"
            case .databases:     return "cylinder"
            case .devops:        return "cloud"
            case .media:         return "photo"
            case .productivity:  return "star"
            case .communication: return "message"
            case .security:      return "lock.shield"
            case .utilities:     return "wrench.and.screwdriver"
            }
        }

        var color: Color {
            switch self {
            case .browsers:      return .blue
            case .development:   return .orange
            case .databases:     return .teal
            case .devops:        return .purple
            case .media:         return .pink
            case .productivity:  return .yellow
            case .communication: return .green
            case .security:      return .red
            case .utilities:     return Color(nsColor: .secondaryLabelColor)
            }
        }
    }

    var icon: FormulaIcon {
        FormulaIcons.icon(for: id) ?? FormulaIcon(symbol: category.symbol, color: category.color)
    }
}

private extension DiscoverPackage {
    init(_ id: String, _ displayName: String, _ description: String, _ category: Category, _ type: BrewPackage.PackageType) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.category = category
        self.type = type
    }
}

enum DiscoverCatalog {
    static let all: [DiscoverPackage] = [

        // MARK: Browsers
        .init("google-chrome",  "Google Chrome",  "Fast, secure web browser by Google",              .browsers, .cask),
        .init("firefox",        "Firefox",        "Free and open-source web browser",                .browsers, .cask),
        .init("arc",            "Arc",            "Browser that puts you in control",                .browsers, .cask),
        .init("brave-browser",  "Brave",          "Privacy-focused browser with ad blocking",        .browsers, .cask),
        .init("opera",          "Opera",          "Feature-rich browser with built-in VPN",          .browsers, .cask),

        // MARK: Development
        .init("visual-studio-code", "VS Code",          "Lightweight but powerful source code editor",     .development, .cask),
        .init("cursor",             "Cursor",            "AI-first code editor",                            .development, .cask),
        .init("iterm2",             "iTerm2",            "Feature-rich terminal emulator for macOS",        .development, .cask),
        .init("warp",               "Warp",              "Modern terminal with AI built in",                .development, .cask),
        .init("sublime-text",       "Sublime Text",      "Sophisticated text editor for code",              .development, .cask),
        .init("nova",               "Nova",              "Native macOS code editor by Panic",               .development, .cask),
        .init("jetbrains-toolbox",  "JetBrains Toolbox", "Manage all your JetBrains tools in one place",   .development, .cask),
        .init("android-studio",     "Android Studio",    "Official IDE for Android development",            .development, .cask),
        .init("node",               "Node.js",           "JavaScript runtime built on Chrome's V8",         .development, .formula),
        .init("python",             "Python",            "Interpreted, high-level programming language",    .development, .formula),
        .init("go",                 "Go",                "Fast, statically typed compiled language",        .development, .formula),
        .init("ruby",               "Ruby",              "Dynamic, open source programming language",       .development, .formula),
        .init("rust",               "Rust",              "Safe, concurrent systems programming language",   .development, .formula),
        .init("git",                "Git",               "Distributed version control system",              .development, .formula),
        .init("gh",                 "GitHub CLI",        "GitHub's official command-line tool",             .development, .formula),
        .init("neovim",             "Neovim",            "Hyperextensible vim-based text editor",           .development, .formula),

        // MARK: Databases
        .init("tableplus",          "TablePlus",         "Modern native database management tool",          .databases, .cask),
        .init("sequel-pro",         "Sequel Pro",        "Fast MySQL and MariaDB database manager",         .databases, .cask),
        .init("postico",            "Postico",           "PostgreSQL client for macOS",                     .databases, .cask),
        .init("dbeaver-community",  "DBeaver",           "Free universal database management tool",         .databases, .cask),
        .init("postgresql",         "PostgreSQL",        "Powerful open source relational database",        .databases, .formula),
        .init("mysql",              "MySQL",             "World's most popular open source database",       .databases, .formula),
        .init("redis",              "Redis",             "In-memory data structure store",                  .databases, .formula),
        .init("sqlite",             "SQLite",            "Lightweight embedded SQL database engine",        .databases, .formula),

        // MARK: DevOps & Cloud
        .init("docker",       "Docker",        "Platform for building and running containers",     .devops, .cask),
        .init("terraform",    "Terraform",     "Infrastructure as code tool by HashiCorp",         .devops, .formula),
        .init("kubectl",      "kubectl",       "Kubernetes command-line tool",                     .devops, .formula),
        .init("helm",         "Helm",          "Package manager for Kubernetes",                   .devops, .formula),
        .init("awscli",       "AWS CLI",       "Amazon Web Services command-line interface",       .devops, .formula),
        .init("azure-cli",    "Azure CLI",     "Microsoft Azure command-line interface",           .devops, .formula),
        .init("vagrant",      "Vagrant",       "Build and manage virtual machine environments",    .devops, .cask),
        .init("minikube",     "Minikube",      "Run Kubernetes locally",                           .devops, .formula),

        // MARK: Media & Design
        .init("figma",        "Figma",         "Collaborative interface design tool",              .media, .cask),
        .init("sketch",       "Sketch",        "Digital design platform for macOS",                .media, .cask),
        .init("vlc",          "VLC",           "Free and open source media player",                .media, .cask),
        .init("iina",         "IINA",          "Modern media player built for macOS",              .media, .cask),
        .init("handbrake",    "HandBrake",     "Open source video transcoder",                     .media, .cask),
        .init("imageoptim",   "ImageOptim",    "Optimises images by removing bloated metadata",    .media, .cask),
        .init("gimp",         "GIMP",          "Free and open source image editor",                .media, .cask),
        .init("inkscape",     "Inkscape",      "Free and open source vector graphics editor",      .media, .cask),
        .init("ffmpeg",       "FFmpeg",        "Record, convert and stream audio and video",       .media, .formula),
        .init("imagemagick",  "ImageMagick",   "Create, edit, compose or convert images",          .media, .formula),
        .init("yt-dlp",       "yt-dlp",        "Download videos from YouTube and other sites",     .media, .formula),

        // MARK: Productivity
        .init("raycast",      "Raycast",       "Supercharged macOS launcher",                      .productivity, .cask),
        .init("alfred",       "Alfred",        "Award-winning productivity app for macOS",         .productivity, .cask),
        .init("notion",       "Notion",        "All-in-one workspace for notes and docs",          .productivity, .cask),
        .init("obsidian",     "Obsidian",      "Knowledge base on local Markdown files",           .productivity, .cask),
        .init("1password",    "1Password",     "Password manager and secure digital wallet",       .productivity, .cask),
        .init("bitwarden",    "Bitwarden",     "Open source password manager",                     .productivity, .cask),
        .init("cleanmymac",   "CleanMyMac",    "Mac cleaning and performance optimiser",           .productivity, .cask),
        .init("bartender",    "Bartender",     "Take control of your menu bar",                    .productivity, .cask),
        .init("things",       "Things 3",      "Award-winning personal task manager",              .productivity, .cask),
        .init("craft",        "Craft",         "Beautiful native document editor",                 .productivity, .cask),

        // MARK: Communication
        .init("slack",            "Slack",           "Business communication platform",            .communication, .cask),
        .init("discord",          "Discord",         "Voice, video and text communication",        .communication, .cask),
        .init("telegram",         "Telegram",        "Fast and secure messaging app",              .communication, .cask),
        .init("signal",           "Signal",          "Private and encrypted messenger",            .communication, .cask),
        .init("zoom",             "Zoom",            "Video conferencing and online meetings",      .communication, .cask),
        .init("microsoft-teams",  "Microsoft Teams", "Chat-based workspace in Microsoft 365",      .communication, .cask),
        .init("whatsapp",         "WhatsApp",        "WhatsApp desktop client",                    .communication, .cask),

        // MARK: Security
        .init("wireshark",      "Wireshark",       "Network protocol analyser",                   .security, .cask),
        .init("proxyman",       "Proxyman",        "Debug network traffic on macOS",              .security, .cask),
        .init("gpg-suite",      "GPG Suite",       "GPG encryption tools for macOS",              .security, .cask),
        .init("nordvpn",        "NordVPN",         "Fast and secure VPN service",                 .security, .cask),
        .init("little-snitch",  "Little Snitch",   "Monitor outgoing network connections",        .security, .cask),
        .init("charles",        "Charles",         "HTTP proxy and monitor",                      .security, .cask),

        // MARK: Utilities
        .init("the-unarchiver",  "The Unarchiver",    "Open any archive format in seconds",        .utilities, .cask),
        .init("appcleaner",      "AppCleaner",        "Thoroughly uninstall unwanted apps",        .utilities, .cask),
        .init("rectangle",       "Rectangle",         "Move and resize windows with shortcuts",    .utilities, .cask),
        .init("istat-menus",     "iStat Menus",       "Advanced Mac system monitor",               .utilities, .cask),
        .init("bettertouchtool", "BetterTouchTool",   "Powerful input device customisation",       .utilities, .cask),
        .init("hazel",           "Hazel",             "Automated folder organisation for Mac",     .utilities, .cask),
        .init("cleanshot",       "CleanShot X",       "Best-in-class screen capture for Mac",      .utilities, .cask),
        .init("transmission",    "Transmission",      "Fast, easy and free BitTorrent client",     .utilities, .cask),
        .init("calibre",         "Calibre",           "Powerful e-book management",                .utilities, .cask),
        .init("fzf",             "fzf",               "Command-line fuzzy finder",                 .utilities, .formula),
        .init("ripgrep",         "ripgrep",           "Fast recursive search tool",                .utilities, .formula),
        .init("bat",             "bat",               "cat clone with syntax highlighting",        .utilities, .formula),
        .init("htop",            "htop",              "Interactive process viewer",                .utilities, .formula),
    ]
}
