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
        case ai            = "AI & ML"
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
            case .ai:            return "brain.head.profile"
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
            case .ai:            return .indigo
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
        .init("google-chrome",  "Google Chrome",   "Fast, secure web browser by Google",              .browsers, .cask, icon("chrome.google.com")),
        .init("firefox",        "Firefox",         "Free and open-source web browser",                .browsers, .cask, icon("mozilla.org")),
        .init("arc",            "Arc",             "Browser that puts you in control",                .browsers, .cask, icon("arc.net")),
        .init("brave-browser",  "Brave",           "Privacy-focused browser with ad blocking",        .browsers, .cask, icon("brave.com")),
        .init("opera",          "Opera",           "Feature-rich browser with built-in VPN",          .browsers, .cask, icon("opera.com")),
        .init("vivaldi",        "Vivaldi",         "Highly customisable Chromium-based browser",      .browsers, .cask, icon("vivaldi.com")),
        .init("microsoft-edge", "Microsoft Edge",  "Fast browser built on Chromium by Microsoft",     .browsers, .cask, icon("microsoft.com/edge")),
        .init("tor-browser",    "Tor Browser",     "Browse privately using the Tor network",          .browsers, .cask, icon("torproject.org")),

        // MARK: Development
        .init("visual-studio-code", "VS Code",           "Lightweight but powerful source code editor",     .development, .cask, icon("code.visualstudio.com")),
        .init("cursor",             "Cursor",            "AI-first code editor",                            .development, .cask, icon("cursor.sh")),
        .init("zed",                "Zed",               "High-performance multiplayer code editor",        .development, .cask, icon("zed.dev")),
        .init("iterm2",             "iTerm2",            "Feature-rich terminal emulator for macOS",        .development, .cask, icon("iterm2.com")),
        .init("warp",               "Warp",              "Modern terminal with AI built in",                .development, .cask, icon("warp.dev")),
        .init("sublime-text",       "Sublime Text",      "Sophisticated text editor for code",              .development, .cask, icon("sublimetext.com")),
        .init("nova",               "Nova",              "Native macOS code editor by Panic",               .development, .cask, icon("nova.app")),
        .init("jetbrains-toolbox",  "JetBrains Toolbox", "Manage all your JetBrains tools in one place",   .development, .cask, icon("jetbrains.com")),
        .init("android-studio",     "Android Studio",    "Official IDE for Android development",            .development, .cask, icon("developer.android.com")),
        .init("postman",            "Postman",           "API platform for building and using APIs",        .development, .cask, icon("postman.com")),
        .init("insomnia",           "Insomnia",          "Open source API client and design tool",          .development, .cask, icon("insomnia.rest")),
        .init("github",             "GitHub Desktop",    "Easy-to-use GitHub GUI client",                   .development, .cask, icon("desktop.github.com")),
        .init("sourcetree",         "Sourcetree",        "Free Git and Mercurial client by Atlassian",      .development, .cask, icon("sourcetreeapp.com")),
        .init("fork",               "Fork",              "Fast and friendly Git client for Mac",            .development, .cask, icon("fork.dev")),
        .init("tower",              "Tower",             "Powerful Git client with a clean UI",             .development, .cask, icon("git-tower.com")),
        .init("dash",               "Dash",              "Offline documentation browser and snippet manager", .development, .cask, icon("kapeli.com")),
        .init("node",               "Node.js",           "JavaScript runtime built on Chrome's V8",         .development, .formula, icon("nodejs.org")),
        .init("bun",                "Bun",               "Incredibly fast JavaScript runtime and toolkit",  .development, .formula, icon("bun.sh")),
        .init("deno",               "Deno",              "Secure JavaScript and TypeScript runtime",        .development, .formula, icon("deno.com")),
        .init("python",             "Python",            "Interpreted, high-level programming language",    .development, .formula, icon("python.org")),
        .init("go",                 "Go",                "Fast, statically typed compiled language",        .development, .formula, icon("go.dev")),
        .init("ruby",               "Ruby",              "Dynamic, open source programming language",       .development, .formula, icon("ruby-lang.org")),
        .init("rust",               "Rust",              "Safe, concurrent systems programming language",   .development, .formula, icon("rust-lang.org")),
        .init("openjdk",            "OpenJDK",           "Open-source implementation of the Java Platform", .development, .formula, icon("adoptium.net")),
        .init("git",                "Git",               "Distributed version control system",              .development, .formula, icon("git-scm.com")),
        .init("gh",                 "GitHub CLI",        "GitHub's official command-line tool",             .development, .formula, icon("cli.github.com")),
        .init("jq",                 "jq",                "Lightweight command-line JSON processor",         .development, .formula, icon("jqlang.github.io")),
        .init("httpie",             "HTTPie",            "Modern, user-friendly HTTP client for the CLI",   .development, .formula, icon("httpie.io")),
        .init("wget",               "wget",              "Internet file retriever",                         .development, .formula),
        .init("neovim",             "Neovim",            "Hyperextensible vim-based text editor",           .development, .formula, icon("neovim.io")),
        .init("starship",           "Starship",          "Minimal, fast, customisable shell prompt",        .development, .formula, icon("starship.rs")),
        .init("pnpm",               "pnpm",              "Fast, disk space efficient package manager",      .development, .formula, icon("pnpm.io")),
        .init("yarn",               "Yarn",              "Fast, reliable JavaScript package manager",       .development, .formula, icon("yarnpkg.com")),
        .init("volta",              "Volta",             "Hassle-free JavaScript tool manager",             .development, .formula, icon("volta.sh")),

        // MARK: AI & ML
        .init("ollama",       "Ollama",        "Run large language models locally",                .ai, .cask, icon("ollama.com")),
        .init("lm-studio",    "LM Studio",     "Discover, download and run local LLMs",           .ai, .cask, icon("lmstudio.ai")),
        .init("jan",          "Jan",           "Open source ChatGPT-alternative that runs offline", .ai, .cask, icon("jan.ai")),
        .init("diffusionbee", "DiffusionBee",  "Stable Diffusion app for AI image generation",    .ai, .cask, icon("diffusionbee.com")),
        .init("chatgpt",      "ChatGPT",       "Official OpenAI ChatGPT desktop app",             .ai, .cask, icon("chatgpt.com")),
        .init("anaconda",     "Anaconda",      "Python distribution for data science and ML",     .ai, .cask, icon("anaconda.com")),
        .init("miniconda",    "Miniconda",     "Minimal Conda installer for Python environments", .ai, .cask, icon("docs.conda.io")),

        // MARK: Databases
        .init("tableplus",          "TablePlus",         "Modern native database management tool",          .databases, .cask, icon("tableplus.com")),
        .init("sequel-ace",         "Sequel Ace",        "Fast MySQL and MariaDB database manager",         .databases, .cask, icon("sequel-ace.com")),
        .init("sequel-pro",         "Sequel Pro",        "Classic MySQL and MariaDB database manager",      .databases, .cask, icon("sequelpro.com")),
        .init("postico",            "Postico",           "PostgreSQL client for macOS",                     .databases, .cask, icon("eggerapps.at")),
        .init("dbeaver-community",  "DBeaver",           "Free universal database management tool",         .databases, .cask, icon("dbeaver.io")),
        .init("beekeeper-studio",   "Beekeeper Studio",  "Cross-platform SQL editor and database manager",  .databases, .cask, icon("beekeeperstudio.io")),
        .init("mongodb-compass",    "MongoDB Compass",   "Official GUI for MongoDB",                        .databases, .cask, icon("mongodb.com")),
        .init("redisinsight",       "RedisInsight",      "Official GUI for Redis",                          .databases, .cask, icon("redis.com")),
        .init("postgresql",         "PostgreSQL",        "Powerful open source relational database",        .databases, .formula, icon("postgresql.org")),
        .init("mysql",              "MySQL",             "World's most popular open source database",       .databases, .formula, icon("mysql.com")),
        .init("redis",              "Redis",             "In-memory data structure store",                  .databases, .formula, icon("redis.io")),
        .init("sqlite",             "SQLite",            "Lightweight embedded SQL database engine",        .databases, .formula, icon("sqlite.org")),

        // MARK: DevOps & Cloud
        .init("docker",          "Docker",          "Platform for building and running containers",     .devops, .cask, icon("docker.com")),
        .init("orbstack",        "OrbStack",        "Fast, light Docker and Linux VM manager",         .devops, .cask, icon("orbstack.dev")),
        .init("rancher",         "Rancher Desktop", "Container management on the desktop",             .devops, .cask, icon("rancherdesktop.io")),
        .init("terraform",       "Terraform",       "Infrastructure as code tool by HashiCorp",        .devops, .formula, icon("terraform.io")),
        .init("kubectl",         "kubectl",         "Kubernetes command-line tool",                    .devops, .formula, icon("kubernetes.io")),
        .init("helm",            "Helm",            "Package manager for Kubernetes",                  .devops, .formula, icon("helm.sh")),
        .init("k9s",             "k9s",             "Terminal UI for Kubernetes clusters",             .devops, .formula, icon("k9scli.io")),
        .init("act",             "act",             "Run GitHub Actions locally",                      .devops, .formula),
        .init("ansible",         "Ansible",         "Agentless IT automation platform",               .devops, .formula, icon("ansible.com")),
        .init("awscli",          "AWS CLI",         "Amazon Web Services command-line interface",      .devops, .formula, icon("aws.amazon.com")),
        .init("azure-cli",       "Azure CLI",       "Microsoft Azure command-line interface",          .devops, .formula, icon("azure.microsoft.com")),
        .init("doctl",           "doctl",           "DigitalOcean official command-line tool",         .devops, .formula, icon("digitalocean.com")),
        .init("vagrant",         "Vagrant",         "Build and manage virtual machine environments",   .devops, .cask, icon("vagrantup.com")),
        .init("minikube",        "Minikube",        "Run Kubernetes locally",                          .devops, .formula, icon("minikube.sigs.k8s.io")),

        // MARK: Media & Design
        .init("figma",        "Figma",          "Collaborative interface design tool",              .media, .cask, icon("figma.com")),
        .init("sketch",       "Sketch",         "Digital design platform for macOS",                .media, .cask, icon("sketch.com")),
        .init("blender",      "Blender",        "Free and open source 3D creation suite",          .media, .cask, icon("blender.org")),
        .init("vlc",          "VLC",            "Free and open source media player",                .media, .cask, icon("videolan.org")),
        .init("iina",         "IINA",           "Modern media player built for macOS",              .media, .cask, icon("iina.io")),
        .init("audacity",     "Audacity",       "Free, open source cross-platform audio editor",   .media, .cask, icon("audacityteam.org")),
        .init("davinci-resolve", "DaVinci Resolve", "Professional video editing and colour grading", .media, .cask, icon("blackmagicdesign.com")),
        .init("handbrake",    "HandBrake",      "Open source video transcoder",                     .media, .cask, icon("handbrake.fr")),
        .init("kap",          "Kap",            "Open source screen recorder built with web tech", .media, .cask, icon("getkap.co")),
        .init("losslesscut",  "LosslessCut",    "Lossless video and audio trimming tool",          .media, .cask, icon("mifi.no")),
        .init("imageoptim",   "ImageOptim",     "Optimises images by removing bloated metadata",   .media, .cask, icon("imageoptim.com")),
        .init("gimp",         "GIMP",           "Free and open source image editor",                .media, .cask, icon("gimp.org")),
        .init("inkscape",     "Inkscape",       "Free and open source vector graphics editor",     .media, .cask, icon("inkscape.org")),
        .init("ffmpeg",       "FFmpeg",         "Record, convert and stream audio and video",       .media, .formula, icon("ffmpeg.org")),
        .init("imagemagick",  "ImageMagick",    "Create, edit, compose or convert images",          .media, .formula, icon("imagemagick.org")),
        .init("exiftool",     "ExifTool",       "Read and write meta information in files",         .media, .formula, icon("exiftool.org")),
        .init("yt-dlp",       "yt-dlp",         "Download videos from YouTube and other sites",    .media, .formula, icon("youtube.com")),

        // MARK: Productivity
        .init("raycast",           "Raycast",          "Supercharged macOS launcher",                      .productivity, .cask, icon("raycast.com")),
        .init("alfred",            "Alfred",           "Award-winning productivity app for macOS",         .productivity, .cask, icon("alfredapp.com")),
        .init("notion",            "Notion",           "All-in-one workspace for notes and docs",          .productivity, .cask, icon("notion.so")),
        .init("obsidian",          "Obsidian",         "Knowledge base on local Markdown files",           .productivity, .cask, icon("obsidian.md")),
        .init("todoist",           "Todoist",          "Organise work and life with task management",      .productivity, .cask, icon("todoist.com")),
        .init("fantastical",       "Fantastical",      "Award-winning calendar and tasks app",             .productivity, .cask, icon("flexibits.com")),
        .init("1password",         "1Password",        "Password manager and secure digital wallet",       .productivity, .cask, icon("1password.com")),
        .init("bitwarden",         "Bitwarden",        "Open source password manager",                     .productivity, .cask, icon("bitwarden.com")),
        .init("mimestream",        "Mimestream",       "Native Gmail client built for macOS",              .productivity, .cask, icon("mimestream.com")),
        .init("pdf-expert",        "PDF Expert",       "Fast and powerful PDF editor for Mac",             .productivity, .cask, icon("pdfexpert.com")),
        .init("libreoffice",       "LibreOffice",      "Free and open source office suite",                .productivity, .cask, icon("libreoffice.org")),
        .init("keyboard-maestro",  "Keyboard Maestro", "Powerful keyboard and macro automation tool",      .productivity, .cask, icon("keyboardmaestro.com")),
        .init("popclip",           "PopClip",          "Instant text actions for what you select",         .productivity, .cask, icon("pilotmoon.com")),
        .init("lungo",             "Lungo",            "Prevent Mac from going to sleep",                  .productivity, .cask, icon("sindresorhus.com")),
        .init("cleanmymac",        "CleanMyMac",       "Mac cleaning and performance optimiser",           .productivity, .cask, icon("macpaw.com")),
        .init("bartender",         "Bartender",        "Take control of your menu bar",                    .productivity, .cask, icon("macbartender.com")),
        .init("things",            "Things 3",         "Award-winning personal task manager",              .productivity, .cask, icon("culturedcode.com")),
        .init("craft",             "Craft",            "Beautiful native document editor",                 .productivity, .cask, icon("craft.do")),

        // MARK: Communication
        .init("slack",            "Slack",           "Business communication platform",            .communication, .cask, icon("slack.com")),
        .init("discord",          "Discord",         "Voice, video and text communication",        .communication, .cask, icon("discord.com")),
        .init("telegram",         "Telegram",        "Fast and secure messaging app",              .communication, .cask, icon("telegram.org")),
        .init("signal",           "Signal",          "Private and encrypted messenger",            .communication, .cask, icon("signal.org")),
        .init("zoom",             "Zoom",            "Video conferencing and online meetings",      .communication, .cask, icon("zoom.us")),
        .init("microsoft-teams",  "Microsoft Teams", "Chat-based workspace in Microsoft 365",      .communication, .cask, icon("microsoft.com")),
        .init("whatsapp",         "WhatsApp",        "WhatsApp desktop client",                    .communication, .cask, icon("whatsapp.com")),
        .init("skype",            "Skype",           "Video calling and instant messaging",        .communication, .cask, icon("skype.com")),
        .init("messenger",        "Messenger",       "Facebook Messenger desktop client",          .communication, .cask, icon("messenger.com")),
        .init("mattermost",       "Mattermost",      "Open source messaging platform for teams",   .communication, .cask, icon("mattermost.com")),

        // MARK: Security
        .init("wireshark",      "Wireshark",      "Network protocol analyser",                    .security, .cask, icon("wireshark.org")),
        .init("proxyman",       "Proxyman",       "Debug network traffic on macOS",               .security, .cask, icon("proxyman.io")),
        .init("keepassxc",      "KeePassXC",      "Cross-platform open source password manager",  .security, .cask, icon("keepassxc.org")),
        .init("mullvad-vpn",    "Mullvad VPN",    "VPN service focused on privacy and anonymity", .security, .cask, icon("mullvad.net")),
        .init("tunnelblick",    "Tunnelblick",    "Free and open source OpenVPN client for Mac",  .security, .cask, icon("tunnelblick.net")),
        .init("gpg-suite",      "GPG Suite",      "GPG encryption tools for macOS",               .security, .cask, icon("gpgtools.org")),
        .init("nordvpn",        "NordVPN",        "Fast and secure VPN service",                  .security, .cask, icon("nordvpn.com")),
        .init("little-snitch",  "Little Snitch",  "Monitor outgoing network connections",         .security, .cask, icon("obdev.at")),
        .init("charles",        "Charles",        "HTTP proxy and monitor",                       .security, .cask, icon("charlesproxy.com")),
        .init("nmap",           "nmap",           "Network exploration and security scanner",      .security, .formula, icon("nmap.org")),

        // MARK: Utilities
        .init("the-unarchiver",  "The Unarchiver",    "Open any archive format in seconds",        .utilities, .cask, icon("theunarchiver.com")),
        .init("keka",            "Keka",              "The macOS file archiver",                   .utilities, .cask, icon("keka.io")),
        .init("appcleaner",      "AppCleaner",        "Thoroughly uninstall unwanted apps",        .utilities, .cask, icon("freemacsoft.net")),
        .init("daisydisk",       "DaisyDisk",         "Visualise disk usage and free up space",    .utilities, .cask, icon("daisydiskapp.com")),
        .init("rectangle",       "Rectangle",         "Move and resize windows with shortcuts",    .utilities, .cask, icon("rectangleapp.com")),
        .init("karabiner-elements", "Karabiner-Elements", "Powerful keyboard customiser for macOS", .utilities, .cask, icon("karabiner-elements.pqrs.org")),
        .init("aldente",         "AlDente",           "Battery charge limiter for long-term health", .utilities, .cask, icon("apphousekitchen.com")),
        .init("stats",           "Stats",             "macOS system monitor in your menu bar",     .utilities, .cask, icon("github.com")),
        .init("ice",             "Ice",               "Powerful menu bar manager — free Bartender alternative", .utilities, .cask, icon("icemenubar.app")),
        .init("betterdisplay",   "BetterDisplay",     "Custom resolutions and display controls",   .utilities, .cask, icon("betterdisplay.app")),
        .init("istat-menus",     "iStat Menus",       "Advanced Mac system monitor",               .utilities, .cask, icon("bjango.com")),
        .init("bettertouchtool", "BetterTouchTool",   "Powerful input device customisation",       .utilities, .cask, icon("folivora.ai")),
        .init("hazel",           "Hazel",             "Automated folder organisation for Mac",     .utilities, .cask, icon("noodlesoft.com")),
        .init("cleanshot",       "CleanShot X",       "Best-in-class screen capture for Mac",      .utilities, .cask, icon("cleanshot.com")),
        .init("transmission",    "Transmission",      "Fast, easy and free BitTorrent client",     .utilities, .cask, icon("transmissionbt.com")),
        .init("calibre",         "Calibre",           "Powerful e-book management",                .utilities, .cask, icon("calibre-ebook.com")),
        .init("eza",             "eza",               "Modern replacement for ls with colour and icons", .utilities, .formula, icon("eza.rocks")),
        .init("zoxide",          "zoxide",            "Smarter cd that learns your habits",        .utilities, .formula),
        .init("lazygit",         "lazygit",           "Terminal UI for git commands",              .utilities, .formula),
        .init("fd",              "fd",                "Fast and user-friendly find alternative",   .utilities, .formula),
        .init("yazi",            "Yazi",              "Blazing fast terminal file manager",        .utilities, .formula, icon("yazi.rs")),
        .init("tldr",            "tldr",              "Simplified man pages with examples",        .utilities, .formula, icon("tldr.sh")),
        .init("fzf",             "fzf",               "Command-line fuzzy finder",                 .utilities, .formula),
        .init("ripgrep",         "ripgrep",           "Fast recursive search tool",                .utilities, .formula),
        .init("bat",             "bat",               "cat clone with syntax highlighting",        .utilities, .formula),
        .init("htop",            "htop",              "Interactive process viewer",                .utilities, .formula, icon("htop.dev")),
    ]
}
