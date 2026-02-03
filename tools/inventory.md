# CLI Tools Inventory

Complete catalog of available Claude Code CLI tools.

## Quick Reference

| Tool | Description | Auth Required |
|------|-------------|---------------|
| [bank-integration](#bank-integration) | Bank sync with sevDesk | Yes |
| [calendar-manager](#calendar-manager) | Google Calendar management | Google OAuth |
| [content-generation](#content-generation) | Content creation utilities | No |
| [course-extractor](#course-extractor) | Course download + transcription | Varies |
| [document-generator](#document-generator) | PDF invoices/contracts | No |
| [drive-manager](#drive-manager) | Google Drive operations | Google OAuth |
| [email-manager](#email-manager) | Gmail send/draft/fetch | Google OAuth |
| [freelance-scout](#freelance-scout) | Multi-platform job scouting | Varies |
| [ftp-explorer](#ftp-explorer) | FTP/SFTP file operations | FTP creds |
| [getmyinvoices-manager](#getmyinvoices-manager) | GetMyInvoices API | API key |
| [guide-creator](#guide-creator) | PDF guide generation | No |
| [image-editor](#image-editor) | Sharp-based image manipulation | No |
| [image-tools](#image-tools) | Python image utilities | No |
| [linkedin-tool](#linkedin-tool) | LinkedIn messaging/posts | Session cookies |
| [mega-manager](#mega-manager) | Mega.nz file management | Mega credentials |
| [nano-banana](#nano-banana) | Gemini image generation | Gemini API key |
| [profile-generator](#profile-generator) | Profile generation | No |
| [seo-audit](#seo-audit) | SEO/performance audit | No |
| [service-cli](#service-cli) | Relay service management | No |
| [sharepoint-manager](#sharepoint-manager) | SharePoint/OneDrive sync | MS Graph |
| [skool-manager](#skool-manager) | Skool community management | Session |
| [transcriber](#transcriber) | Unified transcription | OpenAI API |
| [upwork-manager](#upwork-manager) | Upwork API integration | OAuth |
| [video-generator](#video-generator) | Video generation pipeline | API keys |
| [video-transcriber](#video-transcriber) | Video transcription | OpenAI API |
| [website-fetcher](#website-fetcher) | Website download for AI | No |
| [whatsapp-manager](#whatsapp-manager) | WhatsApp message processing | Session |
| [youtube-research](#youtube-research) | YouTube transcription | No |

## Tool Details

### bank-integration
**Purpose**: Sync bank transactions with sevDesk accounting
**Auth**: Banking API, sevDesk API
**Commands**:
```bash
pnpm run sync          # Sync transactions
pnpm run categorize    # Auto-categorize
```

### calendar-manager
**Purpose**: Google Calendar event management
**Auth**: Google OAuth (calendar scope)
**Commands**:
```bash
node index.mjs auth business      # Authenticate
node index.mjs today              # Today's events
node index.mjs week               # Week overview
node index.mjs create "Meeting"   # Create event
```

### content-generation
**Purpose**: Content creation utilities for marketing
**Auth**: None
**Commands**:
```bash
pnpm start generate    # Generate content
```

### course-extractor
**Purpose**: Download and transcribe online courses
**Auth**: Platform-specific (Skool, Loom, Vimeo)
**Commands**:
```bash
pnpm run extract       # Extract course
pnpm run transcribe    # Transcribe videos
```

### document-generator
**Purpose**: Generate PDF invoices, contracts, proposals using React-PDF. Convert PDF to DOCX.
**Auth**: None (pdf2docx Python library required for convert)
**Commands**:
```bash
node index.mjs invoice --data ./invoice.json    # Generate invoice
node index.mjs contract --data ./contract.json  # Generate contract
node index.mjs proposal --data ./proposal.json  # Generate proposal
node index.mjs convert ./document.pdf           # Convert PDF to DOCX
```

### drive-manager
**Purpose**: Google Drive file operations
**Auth**: Google OAuth (drive scope)
**Commands**:
```bash
node index.mjs auth business    # Authenticate
node index.mjs list             # List files
node index.mjs upload file.pdf  # Upload file
node index.mjs search "query"   # Search files
```

### email-manager
**Purpose**: Gmail send, draft, and fetch operations
**Auth**: Google OAuth (gmail scope)
**Commands**:
```bash
pnpm start auth business         # Authenticate
pnpm start send to@example.com   # Send email
pnpm start draft                 # Create draft
pnpm start fetch --unread        # Fetch emails
```

### freelance-scout
**Purpose**: Multi-platform project/job scouting
**Auth**: Platform-specific
**Commands**:
```bash
pnpm run scout          # Scout all platforms
pnpm run scout --platform projektwerk
```

### ftp-explorer
**Purpose**: FTP/SFTP file operations
**Auth**: FTP credentials
**Commands**:
```bash
pnpm start list /path    # List directory
pnpm start upload file   # Upload file
pnpm start download file # Download file
```

### getmyinvoices-manager
**Purpose**: GetMyInvoices API for invoice management
**Auth**: GMI API key
**Commands**:
```bash
pnpm start fetch         # Fetch invoices
pnpm start list          # List documents
```

### guide-creator
**Purpose**: Generate PDF guides from markdown
**Auth**: None
**Commands**:
```bash
pnpm run generate        # Generate PDF guide
```

### image-editor
**Purpose**: Sharp-based image manipulation
**Auth**: None
**Commands**:
```bash
pnpm start crop input.jpg     # Crop image
pnpm start resize input.jpg   # Resize image
pnpm start compress input.jpg # Compress image
```

### image-tools
**Purpose**: Python image utilities
**Auth**: None
**Commands**:
```bash
python main.py process image.jpg
```

### linkedin-tool
**Purpose**: LinkedIn messaging and post management
**Auth**: Session cookies from browser
**Commands**:
```bash
pnpm start setup               # Setup session
pnpm start messages            # Fetch messages
pnpm start post "Content"      # Create post
pnpm start profile username    # View profile
```

### mega-manager
**Purpose**: Mega.nz cloud storage file management
**Auth**: Mega email/password
**Commands**:
```bash
pnpm start auth                # Authenticate
pnpm start list                # List root files
pnpm start list /folder        # List folder
pnpm start download /path      # Download files
pnpm start sync /mega ./local  # Sync to local
pnpm start info                # Account info
```

### nano-banana
**Purpose**: Gemini image generation
**Auth**: Gemini API key
**Commands**:
```bash
pnpm run generate "prompt"     # Generate image
```

### profile-generator
**Purpose**: Generate profiles from templates
**Auth**: None
**Commands**:
```bash
pnpm run generate              # Generate profile
```

### seo-audit
**Purpose**: Site-wide SEO and performance audit
**Auth**: None
**Commands**:
```bash
pnpm run audit https://example.com   # Run audit
```

### service-cli
**Purpose**: Relay service management
**Auth**: None
**Commands**:
```bash
pnpm start status        # Service status
pnpm start deploy        # Deploy service
```

### sharepoint-manager
**Purpose**: SharePoint/OneDrive file sync
**Auth**: Microsoft Graph OAuth
**Commands**:
```bash
node index.mjs auth account      # Authenticate
node index.mjs list              # List files
node index.mjs sync /path        # Sync folder
```

### skool-manager
**Purpose**: Skool community management
**Auth**: Session cookies
**Commands**:
```bash
node index.mjs chats             # Fetch chats
node index.mjs members           # List members
```

### transcriber
**Purpose**: Unified transcription (YouTube, audio, video)
**Auth**: OpenAI API (for Whisper)
**Commands**:
```bash
pnpm run transcribe https://youtube.com/watch?v=xxx
pnpm run transcribe audio.mp3
```

### upwork-manager
**Purpose**: Upwork API integration
**Auth**: Upwork OAuth
**Commands**:
```bash
pnpm start auth              # Authenticate
pnpm start jobs              # Fetch jobs
pnpm start proposals         # List proposals
```

### video-generator
**Purpose**: Video generation pipeline (ElevenLabs, Kling)
**Auth**: ElevenLabs API, Kling API
**Commands**:
```bash
pnpm run full                # Full pipeline
pnpm run audio               # Generate audio
pnpm run video               # Generate video
```

### video-transcriber
**Purpose**: Video file transcription
**Auth**: OpenAI API (for Whisper)
**Commands**:
```bash
pnpm start video.mp4         # Transcribe video
```

### website-fetcher
**Purpose**: Download websites for AI/LLM processing
**Auth**: None
**Commands**:
```bash
pnpm run fetch https://example.com    # Fetch site
```

### whatsapp-manager
**Purpose**: WhatsApp Business message processing
**Auth**: WhatsApp Business session
**Commands**:
```bash
pnpm start chats             # Fetch chats
pnpm start send +123456789   # Send message
```

### youtube-research
**Purpose**: YouTube video transcription for research
**Auth**: None (uses youtube-transcript)
**Commands**:
```bash
pnpm start https://youtube.com/watch?v=xxx
```

## Getting Individual Tools

Clone single tool:
```bash
git clone https://github.com/sftmlg/{tool-name}.git
cd {tool-name}
pnpm install
```

## Tool Locations

All tools available at:
- GitHub: `https://github.com/sftmlg/{tool-name}`
- Submodule path: `claude-code-cli-tools/{tool-name}`
