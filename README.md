# QR Code Generator

A clean, responsive QR Code Generator built with plain HTML, CSS, and JavaScript.

## Features

- Generate QR codes from text, URLs, or any string input.
- Choose output size from 160 px to 1000 px using a professional slider.
- Download generated QR code as PNG.
- Responsive white-themed modern UI.
- Built-in update governance with changelog and tracking files.

## Project Structure

- `index.html` - Main app layout.
- `styles.css` - Visual styling and responsive behavior.
- `script.js` - QR logic, validation, and download behavior.
- `.gitignore` - Controls private/local files excluded from GitHub.
- `CHANGELOG.md` - Human-readable update history.
- `UPDATE_TRACKER.json` - Machine-readable update counter and entries.
- `GITHUB_UPDATE_CATALOG.md` - Release/update process for GitHub.

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
4. Follow checklist in `GITHUB_UPDATE_CATALOG.md`.
5. Commit and push.

## Public Repository Note

- `MAINTENANCE_RULES.md` is intentionally ignored in `.gitignore` to keep local process notes private.
- `COMMIT_DRAFT.md` is intentionally ignored in `.gitignore` to keep commit drafting notes private.
