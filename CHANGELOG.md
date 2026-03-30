# Changelog

All notable changes to this project are documented here.

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
