# Changelog

All notable changes to this project are documented here.

## [1.2.1] - 2026-03-31

### Added

- Added `tools/sync-readme-latest-changelog.ps1` to automatically sync README with the newest version block from `CHANGELOG.md`.
- Added managed README markers so the latest changelog section can be safely overwritten on every sync.

### Changed

- Updated release workflow documentation to require running changelog-to-README sync whenever a new version is added.
- Updated maintenance rules to enforce README latest-version sync after changelog updates.

## [1.2.0] - 2026-03-31

### Changed

- Recreated the entire app interface with a fresh professional layout architecture across hero, tabs, builder panels, preview, and modal dialogs.
- Rebuilt the full visual system with new spacing, typography rhythm, soft gradients, shadows, border treatment, and component polish for a premium white-themed experience.
- Redesigned the content-type tab strip for better clarity and control using swipe-friendly behavior, stronger active states, and improved desktop-to-mobile interaction consistency.
- Reworked form and action ergonomics for mobile by increasing touch targets, refining field density, and improving vertical flow.
- Rebalanced workspace responsiveness so the preview panel is prioritized on smaller screens while preserving strong desktop composition.
- Refined modal and status surfaces to keep warning, quality, and download messaging readable and professional at every viewport size.

## [1.1.2] - 2026-03-31

### Changed

- Completely rebuilt the entire application UI from the ground up for a true professional, studio-grade appearance.
- Re-architected the responsive layout structure to flawlessly handle PC, tablet, and mobile devices using a modernized CSS Grid approach.
- Overhauled color palettes, typography, shadows, structural element spacing, buttons, and input fields to follow best-in-class SaaS design patterns.
- Resolved previous mobile layout limitations by implementing optimal viewing hierarchies, prioritizing the QR code preview on small screens.
## [1.1.1] - 2026-03-30

### Added

- Added draggable horizontal category tabs with pointer drag support and left/right navigation buttons.
- Added visual drag feedback and smart tab-scroll controls for better usability on desktop and mobile.

### Changed

- Rebuilt the full website UI with a more professional studio-style layout and improved visual hierarchy.
- Upgraded typography, color treatment, spacing, and component styling across header, builder, preview, and modal.
- Improved responsiveness and polish for both desktop and mobile views.

## [1.1.0] - 2026-03-30

### Added

- Added a professional header content-type menu inspired by modern QR generators.
- Added structured QR templates for URL, Text, Email, Phone, SMS, WiFi, Location, vCard, MeCard, Event, Bitcoin, Facebook, X/Twitter, YouTube, Instagram, LinkedIn, WhatsApp, and App Link.
- Added dedicated input panels so each setting group has its own separate UI block.

### Changed

- Restored download warning popup flow: when warnings are present, download now requires confirmation.
- Upgraded warning UI under download button into a cleaner advisory card style.
- Refined overall layout and spacing for a more professional settings experience.

## [1.0.9] - 2026-03-30

### Added

- Added smart real-time QR quality evaluation showing scanability percentage.
- Quality badge displays inline showing scores from 0-100%.
- Automatic quality assessment based on pattern detail, dot fill, dot style, content length, and export size.

### Changed

- Removed download modal popup; users now see quality score and warnings automatically without interaction required.
- Download now directly exports QR without confirmation dialog.
- Warnings update in real-time as users adjust QR design settings.

## [1.0.8] - 2026-03-30

### Added

- Added professional download confirmation modal with scanability warnings.
- Added warning display near download button.
- Modal offers users option to download anyway or change design before downloading.

## [1.0.7] - 2026-03-30

### Changed

- QR preview now stays sticky and visible in the viewport while scrolling through controls.
- Preview stays centered and maintains optimal viewing angle during scroll.

## [1.0.6] - 2026-03-30

### Added

- Added real-time scanability warnings when QR settings may reduce scan reliability.
- Warning conditions include: ultra-dense patterns, very low dot fill, round dots, and large content in ultra mode.

### Changed

- QR preview is now always centered with optimal viewing angle for any content complexity.
- Improved QR output display consistency and alignment in the preview area.

## [1.0.5] - 2026-03-30

### Added

- Added QR pattern detail presets for denser dot patterns.
- Added dot style selection (square/round) and dot fill slider for spacing control.

### Changed

- Preview rendering is now fixed-size for consistent UI while export keeps selected output size.
- Switched QR rendering to custom canvas drawing for richer visual customization.

## [1.0.4] - 2026-03-30

### Added

- Added a professional QR size slider with a wide size range from 160 px to 1000 px.

### Changed

- Replaced the old size dropdown with a live size selector and current-size display.
- Added live QR regeneration while adjusting the slider after a QR has been generated.

## [1.0.3] - 2026-03-30

### Changed

- Renamed local private maintenance files to neutral, process-oriented naming.
- Updated documentation and tracker references to match new names.
- Added VS Code workspace settings for smoother local commit workflow.

## [1.0.2] - 2026-03-30

### Added

- Added local-only `COMMIT_DRAFT.md` template for latest commit title and description.

### Changed

- Updated `.gitignore` to exclude `COMMIT_DRAFT.md` from GitHub.
- Updated `MAINTENANCE_RULES.md` to enforce overwrite-only behavior for local commit drafts.
- Updated docs and tracker for the new local commit-note workflow.

## [1.0.1] - 2026-03-30

### Changed

- Added `.gitignore` to keep only public-shareable files in Git tracking.
- Added `MAINTENANCE_RULES.md` to ignored files so it stays local/private.
- Updated project docs and update tracker for this policy change.

## [1.0.0] - 2026-03-30

### Added

- Initial QR Code Generator app using HTML, CSS, and JavaScript.
- Input validation, size selection, and PNG download support.
- Professional white-themed responsive UI.
- Project governance files for update tracking and GitHub release catalog.

