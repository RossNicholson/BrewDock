import SwiftUI

struct DiscoverPackage: Identifiable {
    let id: String
    let displayName: String
    let description: String
    let category: Category
    let type: BrewPackage.PackageType
    let iconURL: String?

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
    init(_ id: String, _ displayName: String, _ description: String, _ category: Category, _ type: BrewPackage.PackageType, _ iconURL: String? = nil) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.category = category
        self.type = type
        self.iconURL = iconURL
    }
}

private func icon(_ domain: String) -> String {
    "https://icon.horse/icon/\(domain)"
}

enum DiscoverCatalog {
    static let all: [DiscoverPackage] = [

        // MARK: Browsers
        .init("google-chrome",  "Google Chrome",  "Fast, secure web browser by Google",              .browsers, .cask, icon("chrome.google.com")),
        .init("firefox",        "Firefox",        "Free and open-source web browser",                .browsers, .cask, icon("mozilla.org")),
        .init("arc",            "Arc",            "Browser that puts you in control",                .browsers, .cask, icon("arc.net")),
        .init("brave-browser",  "Brave",          "Privacy-focused browser with ad blocking",        .browsers, .cask, icon("brave.com")),
        .init("opera",          "Opera",          "Feature-rich browser with built-in VPN",          .browsers, .cask, icon("opera.com")),

        // MARK: Development
        .init("visual-studio-code", "VS Code",           "Lightweight but powerful source code editor",     .development, .cask, icon("code.visualstudio.com")),
        .init("cursor",             "Cursor",            "AI-first code editor",                            .development, .cask, icon("cursor.sh")),
        .init("iterm2",             "iTerm2",            "Feature-rich terminal emulator for macOS",        .development, .cask, icon("iterm2.com")),
        .init("warp",               "Warp",              "Modern terminal with AI built in",                .development, .cask, icon("warp.dev")),
        .init("sublime-text",       "Sublime Text",      "Sophisticated text editor for code",              .development, .cask, icon("sublimetext.com")),
        .init("nova",               "Nova",              "Native macOS code editor by Panic",               .development, .cask, icon("nova.app")),
        .init("jetbrains-toolbox",  "JetBrains Toolbox", "Manage all your JetBrains tools in one place",   .development, .cask, icon("jetbrains.com")),
        .init("android-studio",     "Android Studio",    "Official IDE for Android development",            .development, .cask, icon("developer.android.com")),
        .init("node",               "Node.js",           "JavaScript runtime built on Chrome's V8",         .development, .formula, icon("nodejs.org")),
        .init("python",             "Python",            "Interpreted, high-level programming language",    .development, .formula, icon("python.org")),
        .init("go",                 "Go",                "Fast, statically typed compiled language",        .development, .formula, icon("go.dev")),
        .init("ruby",               "Ruby",              "Dynamic, open source programming language",       .development, .formula, icon("ruby-lang.org")),
        .init("rust",               "Rust",              "Safe, concurrent systems programming language",   .development, .formula, icon("rust-lang.org")),
        .init("git",                "Git",               "Distributed version control system",              .development, .formula, icon("git-scm.com")),
        .init("gh",                 "GitHub CLI",        "GitHub's official command-line tool",             .development, .formula, icon("cli.github.com")),
        .init("neovim",             "Neovim",            "Hyperextensible vim-based text editor",           .development, .formula, icon("neovim.io")),

        // MARK: Databases
        .init("tableplus",          "TablePlus",         "Modern native database management tool",          .databases, .cask, icon("tableplus.com")),
        .init("sequel-pro",         "Sequel Pro",        "Fast MySQL and MariaDB database manager",         .databases, .cask, icon("sequelpro.com")),
        .init("postico",            "Postico",           "PostgreSQL client for macOS",                     .databases, .cask, icon("eggerapps.at")),
        .init("dbeaver-community",  "DBeaver",           "Free universal database management tool",         .databases, .cask, icon("dbeaver.io")),
        .init("postgresql",         "PostgreSQL",        "Powerful open source relational database",        .databases, .formula, icon("postgresql.org")),
        .init("mysql",              "MySQL",             "World's most popular open source database",       .databases, .formula, icon("mysql.com")),
        .init("redis",              "Redis",             "In-memory data structure store",                  .databases, .formula, icon("redis.io")),
        .init("sqlite",             "SQLite",            "Lightweight embedded SQL database engine",        .databases, .formula, icon("sqlite.org")),

        // MARK: DevOps & Cloud
        .init("docker",       "Docker",        "Platform for building and running containers",     .devops, .cask, icon("docker.com")),
        .init("terraform",    "Terraform",     "Infrastructure as code tool by HashiCorp",         .devops, .formula, icon("terraform.io")),
        .init("kubectl",      "kubectl",       "Kubernetes command-line tool",                     .devops, .formula, icon("kubernetes.io")),
        .init("helm",         "Helm",          "Package manager for Kubernetes",                   .devops, .formula, icon("helm.sh")),
        .init("awscli",       "AWS CLI",       "Amazon Web Services command-line interface",       .devops, .formula, icon("aws.amazon.com")),
        .init("azure-cli",    "Azure CLI",     "Microsoft Azure command-line interface",           .devops, .formula, icon("azure.microsoft.com")),
        .init("vagrant",      "Vagrant",       "Build and manage virtual machine environments",    .devops, .cask, icon("vagrantup.com")),
        .init("minikube",     "Minikube",      "Run Kubernetes locally",                           .devops, .formula, icon("minikube.sigs.k8s.io")),

        // MARK: Media & Design
        .init("figma",        "Figma",         "Collaborative interface design tool",              .media, .cask, icon("figma.com")),
        .init("sketch",       "Sketch",        "Digital design platform for macOS",                .media, .cask, icon("sketch.com")),
        .init("vlc",          "VLC",           "Free and open source media player",                .media, .cask, icon("videolan.org")),
        .init("iina",         "IINA",          "Modern media player built for macOS",              .media, .cask, icon("iina.io")),
        .init("handbrake",    "HandBrake",     "Open source video transcoder",                     .media, .cask, icon("handbrake.fr")),
        .init("imageoptim",   "ImageOptim",    "Optimises images by removing bloated metadata",    .media, .cask, icon("imageoptim.com")),
        .init("gimp",         "GIMP",          "Free and open source image editor",                .media, .cask, icon("gimp.org")),
        .init("inkscape",     "Inkscape",      "Free and open source vector graphics editor",      .media, .cask, icon("inkscape.org")),
        .init("ffmpeg",       "FFmpeg",        "Record, convert and stream audio and video",       .media, .formula, icon("ffmpeg.org")),
        .init("imagemagick",  "ImageMagick",   "Create, edit, compose or convert images",          .media, .formula, icon("imagemagick.org")),
        .init("yt-dlp",       "yt-dlp",        "Download videos from YouTube and other sites",     .media, .formula, icon("youtube.com")),

        // MARK: Productivity
        .init("raycast",      "Raycast",       "Supercharged macOS launcher",                      .productivity, .cask, icon("raycast.com")),
        .init("alfred",       "Alfred",        "Award-winning productivity app for macOS",         .productivity, .cask, icon("alfredapp.com")),
        .init("notion",       "Notion",        "All-in-one workspace for notes and docs",          .productivity, .cask, icon("notion.so")),
        .init("obsidian",     "Obsidian",      "Knowledge base on local Markdown files",           .productivity, .cask, icon("obsidian.md")),
        .init("1password",    "1Password",     "Password manager and secure digital wallet",       .productivity, .cask, icon("1password.com")),
        .init("bitwarden",    "Bitwarden",     "Open source password manager",                     .productivity, .cask, icon("bitwarden.com")),
        .init("cleanmymac",   "CleanMyMac",    "Mac cleaning and performance optimiser",           .productivity, .cask, icon("macpaw.com")),
        .init("bartender",    "Bartender",     "Take control of your menu bar",                    .productivity, .cask, icon("macbartender.com")),
        .init("things",       "Things 3",      "Award-winning personal task manager",              .productivity, .cask, icon("culturedcode.com")),
        .init("craft",        "Craft",         "Beautiful native document editor",                 .productivity, .cask, icon("craft.do")),

        // MARK: Communication
        .init("slack",            "Slack",           "Business communication platform",            .communication, .cask, icon("slack.com")),
        .init("discord",          "Discord",         "Voice, video and text communication",        .communication, .cask, icon("discord.com")),
        .init("telegram",         "Telegram",        "Fast and secure messaging app",              .communication, .cask, icon("telegram.org")),
        .init("signal",           "Signal",          "Private and encrypted messenger",            .communication, .cask, icon("signal.org")),
        .init("zoom",             "Zoom",            "Video conferencing and online meetings",      .communication, .cask, icon("zoom.us")),
        .init("microsoft-teams",  "Microsoft Teams", "Chat-based workspace in Microsoft 365",      .communication, .cask, icon("microsoft.com")),
        .init("whatsapp",         "WhatsApp",        "WhatsApp desktop client",                    .communication, .cask, icon("whatsapp.com")),

        // MARK: Security
        .init("wireshark",      "Wireshark",       "Network protocol analyser",                   .security, .cask, icon("wireshark.org")),
        .init("proxyman",       "Proxyman",        "Debug network traffic on macOS",              .security, .cask, icon("proxyman.io")),
        .init("gpg-suite",      "GPG Suite",       "GPG encryption tools for macOS",              .security, .cask, icon("gpgtools.org")),
        .init("nordvpn",        "NordVPN",         "Fast and secure VPN service",                 .security, .cask, icon("nordvpn.com")),
        .init("little-snitch",  "Little Snitch",   "Monitor outgoing network connections",        .security, .cask, icon("obdev.at")),
        .init("charles",        "Charles",         "HTTP proxy and monitor",                      .security, .cask, icon("charlesproxy.com")),

        // MARK: Utilities
        .init("the-unarchiver",  "The Unarchiver",    "Open any archive format in seconds",        .utilities, .cask, icon("theunarchiver.com")),
        .init("appcleaner",      "AppCleaner",        "Thoroughly uninstall unwanted apps",        .utilities, .cask, icon("freemacsoft.net")),
        .init("rectangle",       "Rectangle",         "Move and resize windows with shortcuts",    .utilities, .cask, icon("rectangleapp.com")),
        .init("istat-menus",     "iStat Menus",       "Advanced Mac system monitor",               .utilities, .cask, icon("bjango.com")),
        .init("bettertouchtool", "BetterTouchTool",   "Powerful input device customisation",       .utilities, .cask, icon("folivora.ai")),
        .init("hazel",           "Hazel",             "Automated folder organisation for Mac",     .utilities, .cask, icon("noodlesoft.com")),
        .init("cleanshot",       "CleanShot X",       "Best-in-class screen capture for Mac",      .utilities, .cask, icon("cleanshot.com")),
        .init("transmission",    "Transmission",      "Fast, easy and free BitTorrent client",     .utilities, .cask, icon("transmissionbt.com")),
        .init("calibre",         "Calibre",           "Powerful e-book management",                .utilities, .cask, icon("calibre-ebook.com")),
        .init("fzf",             "fzf",               "Command-line fuzzy finder",                 .utilities, .formula),
        .init("ripgrep",         "ripgrep",           "Fast recursive search tool",                .utilities, .formula),
        .init("bat",             "bat",               "cat clone with syntax highlighting",        .utilities, .formula),
        .init("htop",            "htop",              "Interactive process viewer",                .utilities, .formula, icon("htop.dev")),
    ]
}
