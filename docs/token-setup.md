# Token Setup Guide

Authentication tokens for CLI tools stored centrally, never committed to git.

## Directory Structure

Create a `tokens/` folder as a sibling to your tools:

```
your-workspace/
├── cli-tools/
│   ├── email-manager/
│   ├── calendar-manager/
│   └── ...
└── tokens/                       # LOCAL ONLY - never commit
    ├── credentials.json          # Google OAuth client (shared)
    ├── calendar-manager/
    │   ├── personal.json
    │   └── business.json
    ├── drive-manager/
    │   └── business.json
    ├── email-manager/
    │   ├── personal.json
    │   └── business.json
    ├── sharepoint-manager/
    │   └── account.json
    ├── upwork-manager/
    │   └── token.json
    ├── getmyinvoices-manager/
    ├── linkedin-tool/
    ├── nano-banana/
    └── whatsapp-manager/
        └── session/          # WhatsApp Web session (Puppeteer/LocalAuth)
```

## Security Rules

- **NEVER** commit tokens to git
- **NEVER** include tokens in tool repositories
- Each machine maintains its own token storage
- Tools reference `../tokens/{tool-name}/` for credentials

## Setup by Tool Category

### Google Tools (Calendar, Drive, Email)

1. **Get OAuth Credentials**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create or select a project
   - Enable required APIs (Gmail, Calendar, Drive)
   - Create OAuth 2.0 credentials (Desktop App)
   - Download `credentials.json`

2. **Place Credentials**
   ```bash
   cp ~/Downloads/credentials.json tokens/credentials.json
   ```

3. **Authenticate Each Account**
   ```bash
   # Calendar
   cd calendar-manager
   node index.mjs auth business
   # Opens browser for OAuth flow

   # Drive
   cd drive-manager
   node index.mjs auth business

   # Email
   cd email-manager
   pnpm start auth business
   ```

4. **Token Files Created**
   - `tokens/calendar-manager/business.json`
   - `tokens/drive-manager/business.json`
   - `tokens/email-manager/business.json`

### Microsoft Tools (SharePoint)

1. **Configure Azure AD App** (one-time)
   - Register app in Azure Portal
   - Set redirect URI: `http://localhost:3000/callback`
   - Grant permissions: Files.ReadWrite.All, Sites.ReadWrite.All

2. **Authenticate**
   ```bash
   cd sharepoint-manager
   node index.mjs auth <account-name>
   # Follow device code flow in browser
   ```

### Upwork

1. **Set Environment Variables**
   ```bash
   export UPWORK_CLIENT_ID="your-client-id"
   export UPWORK_CLIENT_SECRET="your-client-secret"
   ```

2. **Run OAuth Flow**
   ```bash
   cd upwork-manager
   pnpm start auth
   ```

### GetMyInvoices

1. **Get API Key**
   - Login to GetMyInvoices
   - Settings → API → Generate Key

2. **Configure**
   ```bash
   echo "GMI_API_KEY=your-key" > tokens/getmyinvoices-manager/.env
   ```

### LinkedIn

Uses session cookies extracted from browser:
```bash
cd linkedin-tool
pnpm start setup
# Follow instructions to extract cookies
```

### Gemini (nano-banana)

1. **Get API Key**
   - Go to [Google AI Studio](https://aistudio.google.com/)
   - Create API key

2. **Configure**
   ```bash
   echo "GEMINI_API_KEY=your-key" > tokens/nano-banana/.env
   ```

### WhatsApp (whatsapp-manager)

Uses whatsapp-web.js with QR code pairing (personal WhatsApp, not Business API):

1. **First-time Setup**
   ```bash
   cd whatsapp-manager
   pnpm start connect
   # QR code saved to /tmp/whatsapp-qr.png
   # Open image and scan with WhatsApp > Linked Devices
   ```

2. **Session Storage**
   - Session auto-saved to `tokens/whatsapp-manager/session/`
   - No QR needed for subsequent connections
   - Session invalidates if WhatsApp mobile logs out

## Cross-Machine Sync

For syncing tokens between machines:

### Recommended Approaches
- **1Password**: Store tokens in secure vault
- **Encrypted USB**: Physical backup
- **Encrypted cloud**: GPG-encrypted archive

### Sync Procedure
```bash
# Export (source machine)
tar -czf tokens-backup.tar.gz tokens/
gpg -c tokens-backup.tar.gz
# Transfer encrypted file

# Import (target machine)
gpg -d tokens-backup.tar.gz.gpg | tar -xzf -
```

### Alternative: Regenerate
For maximum security, regenerate tokens on each new machine rather than syncing.

## Verification

Run security check to ensure proper configuration:

```bash
./scripts/verify-security.sh
```

Checks performed:
- No hardcoded keys in source
- No tokens tracked in git
- Proper folder structure
- Complete .gitignore files

## Troubleshooting

### Token Expired
```bash
# Re-authenticate
cd {tool-folder}
node index.mjs auth {account}
```

### Missing credentials.json
```
Error: credentials.json not found
```
Download from Google Cloud Console and place in `tokens/credentials.json`

### Permission Denied
Check API is enabled in Google Cloud Console for your project.
