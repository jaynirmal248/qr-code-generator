# GitHub Update Catalog

Use this catalog for every release/update pushed to GitHub.

## Mandatory Checklist

1. Confirm feature or fix is complete and tested in browser.
2. Update `CHANGELOG.md` with a new version heading and date.
3. Run `tools/sync-readme-latest-changelog.ps1` so README shows the newest changelog version block.
4. Update `UPDATE_TRACKER.json`:
   - Increase `total_updates` by 1.
   - Add next incremental `id` in `history`.
   - Update `last_updated` and `latest_version`.
   - List all touched files.
5. Update `README.md` only if setup, structure, or behavior changed.
6. Run a quick manual smoke test:
   - Generate QR from URL.
   - Generate QR from plain text.
   - Download PNG.
   - Verify clear/reset behavior.
7. Commit with versioned message, for example:
   - `feat: release v1.1.0 add batch QR presets`
8. Push to GitHub branch.
9. Create GitHub release notes using matching changelog text.

## Versioning Rule

- Use semantic versioning: `MAJOR.MINOR.PATCH`.
- Increment:
  - MAJOR for breaking behavior.
  - MINOR for new features.
  - PATCH for fixes and small improvements.
