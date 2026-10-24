# Solidus 1.4 release preparation

App Store Connect app: 1577127191 (`com.justinnipper.solidus`), profile `default`.
Version: eaa9347e-0bd9-4235-8f2c-0461b49ad074, manual release, Waiting for Review.
English localization: 1e338112-a6c9-4cb6-b151-a397e915694b.

`release-notes.txt` is saved to the draft's en-US What's New field. Existing description, keywords, URLs, and existing non-Duo placements are preserved.

## Screenshots

`product.json` records benefits and proof; `shots.json` is the editable source. `rendered/review.html` shows the three exports. They use native real app captures and the app's navy/lavender palette. The rectangular outline is a presentation border, not a hardware frame.

1. Inner portrait: 2007 × 2853, verified 90-degree horizontal fold. Captured during the passing portrait-fold validation on October 23 at 19:40. The production UI is unchanged since that capture; only release version metadata changed.
2. Outer portrait: 1398 × 2034, 25% off 128 = 96.00.
3. Outer portrait: 1398 × 2034, 18% of 86 = 15.48.

The outer screenshots were captured by `StoreScreenshotTests` using real controls with a short pause after key release. The opt-in capture test passed on the current Xcode 27.1 installation. It skips unless its runner environment contains `SOLIDUS_STORE_SCREENSHOTS=1`.

The app-shots renderer composed the set. Pixel validation and the read-only upload preflight passed against Apple's live catalog. The preflight adds three Duo placements, removes none, and leaves all other groups alone. The three screenshots were uploaded on October 24, 2026. All three placements are ACTIVE and their order was read back and verified. The operation journal is `upload-journal-2026-10-24.json`; `uploaded-placements.json` records the readback. Existing screenshots in other groups were preserved. The ZIP contains the finished PNGs.

```sh
app-shots --profile default render --manifest AppStore/1.4/shots.json --out AppStore/1.4/rendered
app-shots --profile default --json validate --manifest AppStore/1.4/rendered/manifest.json
app-shots --profile default --json upload --manifest AppStore/1.4/rendered/manifest.json --set en-US-duo --dry-run
```

## Build and validation

Release archive: `/tmp/Solidus-1.4.xcarchive`, version 1.4 (1), signed iPhone app with embedded Watch companion; `ARCHIVE SUCCEEDED`. App Store distribution upload succeeded on October 24, 2026. Apple validated version 1.4 (1), and that exact build was attached to the 1.4 release. The final build and review IDs are recorded in `release-status.json`. The upload used the existing local Apple Distribution identity with new App Store profiles for the iPhone and Watch bundles; cloud signing was unavailable for the API key. `ExportOptions.plist` records the signing configuration and `signing-profiles.json` records profile IDs without private signing material. App Review submission succeeded on October 24, 2026 at 11:08:48 UTC. The submission and version were read back as `WAITING_FOR_REVIEW`, and the approved release notes and build attachment were verified. The release remains configured for manual publication after approval.

Earlier validation: 39 calculation/layout unit tests, five regular-iPhone UI checks, and the exact portrait half-fold regression passed. See `../../TESTING.md` for scope and remaining release-matrix checks.

Xcode was updated from beta build 27A9269 to build 27A9275 during this session. Both old and new Device Hub processes remained open, and new GUI/hinge-readback control timed out. No new inner pose or multitasking validation is claimed from those attempts; the existing verified inner capture supplies this set.

Apple references:
- https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications
- https://developer.apple.com/app-store/asset-best-practices/

## Review submission tooling

The CLI initially inferred the live 1.3 version from the new empty submission. Direct Apple API inspection verified that its items list was empty; no 1.3 item was removed or changed. Version 1.4 was added with `POST /v1/reviewSubmissionItems` after its build became valid. The high-level submit command then succeeded and verified Waiting for Review for version 1.4.
