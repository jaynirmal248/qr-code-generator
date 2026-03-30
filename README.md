# QR Code Generator

A clean, responsive QR Code Generator built with plain HTML, CSS, and JavaScript.

## Live Site

- https://jaynirmal248.github.io/qr-code-generator/

## Features

- Generate QR codes with category templates via header menu: URL, Text, Email, Phone, SMS, WiFi, Location, vCard, MeCard, Event, Bitcoin, social links, WhatsApp, and app links.
- Draggable category tab strip with left/right navigation controls for smoother type browsing.
- Choose output size from 160 px to 1000 px using a professional slider.
- Keep preview size fixed while export/download uses selected output size.
- Control QR look with pattern detail presets and dot style/fill customization.
- Smart real-time QR quality evaluation showing scanability percentage.
- Refined advisory warning card near download for cleaner professional UI.
- Download warning popup appears automatically when risky settings are detected.
- Fully rebuilt professional UI with studio-style hero, cleaner spacing, and improved component hierarchy.
- QR preview centered with optimal viewing angle regardless of content complexity.
- QR preview stays sticky and visible in viewport while adjusting controls.
- Download generated QR code as PNG (direct when safe, confirmation popup when warnings exist).
- Responsive white-themed modern UI.
- Built-in update governance with changelog and tracking files.

## Latest Changelog

<!-- LATEST_CHANGELOG:START -->
### [1.2.1] - 2026-03-31

#### Added

- Added `tools/sync-readme-latest-changelog.ps1` to automatically sync README with the newest version block from `CHANGELOG.md`.
- Added managed README markers so the latest changelog section can be safely overwritten on every sync.

#### Changed

- Updated release workflow documentation to require running changelog-to-README sync whenever a new version is added.
- Updated maintenance rules to enforce README latest-version sync after changelog updates.

[View full changelog](CHANGELOG.md)
<!-- LATEST_CHANGELOG:END -->

## Project Structure

- `index.html` - Main app layout.
- `styles.css` - Visual styling and responsive behavior.
- `script.js` - QR logic, validation, and download behavior.
- `.gitignore` - Controls private/local files excluded from GitHub.
- `CHANGELOG.md` - Human-readable update history.
- `UPDATE_TRACKER.json` - Machine-readable update counter and entries.
- `GITHUB_UPDATE_CATALOG.md` - Release/update process for GitHub.
- `tools/sync-readme-latest-changelog.ps1` - Syncs README latest changelog block with newest CHANGELOG entry.

Local private file (ignored from GitHub):

- `MAINTENANCE_RULES.md` - Local maintenance checklist and update rules.
- `COMMIT_DRAFT.md` - Local latest commit title and description, overwritten each update.

## Run Locally

1. Open the project folder.
2. Open `index.html` in a browser.

## GitHub Update Workflow

1. Make code changes.
2. Update `CHANGELOG.md` with the new version/date and notes.
3. Update `UPDATE_TRACKER.json`:
   - Increment `total_updates`.
   - Add a new object in `history`.
   - Set `last_updated` and `latest_version`.
4. Run `pwsh ./tools/sync-readme-latest-changelog.ps1` (or PowerShell: `powershell -ExecutionPolicy Bypass -File .\\tools\\sync-readme-latest-changelog.ps1`) to refresh README latest changelog section.
5. Follow checklist in `GITHUB_UPDATE_CATALOG.md`.
6. Commit and push.

## Public Repository Note

- `MAINTENANCE_RULES.md` is intentionally ignored in `.gitignore` to keep local process notes private.
- `COMMIT_DRAFT.md` is intentionally ignored in `.gitignore` to keep commit drafting notes private.


