# Testing Solidus

The host-free `CalculatorStateTests` suite exercises production calculator code directly: Off/Of, rounding, zero and 100%, fractional and maximum inputs, deletion, mode switching, clearing, and independent calculations. It contains 29 tests.

```sh
xcodebuild -project Solidus.xcodeproj -scheme SolidusTests \
  -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
```

The eight `CalculatorFlowTests` use real SwiftUI controls. They cover calculation modes, fractional entry, backspace, full and individual clearing, percentage limits, long numbers, right-aligned totals, and retaining values, mode, and active input through rotation. Layout assertions check 44-point targets, hittability, window containment, and overlapping controls. A 0.001-point comparison tolerance accommodates floating-point accessibility-frame conversion.

```sh
xcodebuild -project Solidus.xcodeproj -scheme Solidus \
  -destination 'platform=iOS Simulator,id=YOUR-SIMULATOR-UDID' \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO test
```

UI tests launch `SolidusTestHost`, which shares the shipping app's entry point, view, calculator state, helpers, assets, launch screen, and Info.plist, with a separate bundle identifier and container. Review prompts are suppressed with launch arguments. The shipping app is separately built and installed; its Watch companion is now a single watchOS application target, preserving the companion bundle identifier and complication class module. The Watch UI and calculation implementation were not redesigned.

## Responsive layout

`CalculatorWorkspaceFrames` gives the calculation panel and keypad explicit, nonoverlapping frames. On iOS 27.1 and newer, the workspace queries active `ReservedRegion` divisions and includes their margins: a horizontal fold puts inputs above and keys below, and a vertical fold puts them on opposite sides. Both regions remain present; neither is optional secondary content. Without an active division, tall/narrow windows stack and landscape windows at least 560 points wide split horizontally. Only the background ignores safe areas, and no layout uses `UIScreen.main`, a model-name check, or private hinge APIs.

Calculator state belongs to `ContentView`, outside geometry changes. The Total value aligns with the trailing edge of the input values. Keypad width and height are capped, and each panel can scroll when an unusually small region or accessibility text size exceeds its available height.

## Validation on October 23, 2026

- Regular iPhone 17, iOS 27.0: 29 calculation tests and all eight UI tests passed. This exercises the older-system geometry layout, including portrait and landscape rotation. Separate final runs passed the stronger no-overlap guard and state/visibility checks through both landscape directions, upside-down portrait, and portrait.
- iPhone 16e, iOS 26.2: compact portrait layout inspected with all input fields, total, operation buttons, Clear all, and keypad visible. The initial UI automation run stalled during runner startup and was interrupted; it is not counted as a passing UI run.
- Duo simulator, iOS 27.1, fully open: 29 calculation tests passed. Seven UI flows passed on the first run; the touch-target guard identified an 18-point Clear all label hit area. After moving the 44-point frame inside the button label, that test passed on rerun.
- Duo outer display: long-number/right-alignment test passed. Touch-target, containment, and overlap checks passed after allowing for floating-point frame conversion. A 90-degree hinge run also passed the layout guard and rotation/state-preservation test; its rendered inner display remained landscape. That result did not validate a portrait window with a horizontal fold, and the subsequent user photo exposed that gap.
- Shipping iPhone app plus embedded Watch companion: simulator and signed physical-device Debug builds succeeded with Xcode 27.1.
- Duo Nips, iOS 27.2: installed successfully with the shipping bundle identifier `com.justinnipper.solidus`; Xcode Run confirmed a successful launch.

The beta toolchain sometimes logs `invalidDigitCount(94403)` / `invalidDigitCount(94401)` while recording iOS test metadata. Some completed runs initially left an `xcodebuild` process finalizing results. Where that happened, execution counts are taken from completed XCTest output, and only that owned process was stopped. The iPhone 17 full run and corrected Duo touch-target run both reported `TEST SUCCEEDED`.

## Release matrix

Before an App Store submission, also validate all system multitasking divider positions and placements, stacked-video layouts, asymmetric camera regions, spatial tabletop/standing poses, VoiceOver, accessibility text sizes, and continuous resizing/folding while editing. A hinge-only command establishes an angle, not a spatial pose. Build/install success and the tests above do not establish that every permutation has been visually reviewed. The native resizable-session CLI did not establish a running session, so split-window placements are not counted as validated. The Watch migration has been build-validated; Watch interaction and release archive validation remain separate release checks.

An earlier hinge-restoration attempt timed out. A later cleanup verified the dedicated Duo at 0 degrees before shutdown.

## Title and keypad follow-up

Removed the in-app title/header and moved Clear all into the darker keypad tray. Its button label retains a 44-point minimum height. The keypad reserves space for this row while maintaining 48-point number keys; unusually short regions retain the existing scrolling fallback.

The signed iPhone/Watch Debug build succeeded and was installed and launched on Duo Nips. On iPhone 17 (iOS 27.0), clearing/restarting, target size/containment/overlap, and rotation/state preservation all passed (3 tests). The compact layout was also visually inspected. The initial Duo follow-up run stalled before XCTest execution and was interrupted; that attempt is not counted as a passing run.

The Duo retry with the inner display active passed clearing/restarting and the touch-target, containment, and overlap guard (2 tests). The open layout was visually inspected. Follow-up result logs: `/tmp/solidus-keypad-clear-iphone.log` and `/tmp/solidus-keypad-clear-duo-retry.log`.

## Missing keypad in portrait half-fold

The user reported a blank lower region in a tall half-fold. The keypad was secondary content in `ArrangementView`, whose adaptive presentation may collapse a region. The replacement assigns explicit frames to both essential regions and uses the public reserved-division geometry, including fold margins.

Ten `CalculatorWorkspaceFramesTests` cover the reported 669 × 951 portrait half-fold, a horizontal fold in a wide window, a book fold, off-center and zero-height divisions, a division outside a narrow workspace, ordinary phone/flat Duo/wide layouts, and resize/unfold transitions. All 39 unit tests (29 calculation + 10 layout) passed. Five regular-iPhone UI regressions passed: modes/calculation, clearing, long totals, target size/containment/overlap, and rotation/state preservation. Simulator and signed physical iPhone/Watch builds succeeded. The fix was installed and launched on Duo Nips.

Exact-pose validation subsequently passed after the Mac was unlocked. Device Hub's Rotate Right control established a tall inner display with a horizontal fold, and `duo-sim` verified a 90-degree hinge. `FoldedPortraitTests.testHalfFoldKeepsEveryKeyVisibleAndWorking` passed with zero failures, and the complete keypad was visually inspected below the fold. The earlier orientation CLI and debugger requests had not rotated the rendered display; those attempts remain excluded from passing coverage.

Configure a dedicated Duo simulator at a 90-degree hinge with the **inner display actually in portrait**, then run:

```sh
python3 Scripts/test-folded-portrait.py --udid YOUR-DUO-SIMULATOR-UDID
```

The runner first verifies the hinge sample, builds the UI tests, and explicitly enables `FoldedPortraitTests` through the generated test-run configuration. That test preserves the configured pose, requires a genuinely tall window, checks every key is present, hittable, inside the lower half, and at least 44 points in both dimensions, checks the total stays above the fold, then performs a discount calculation and clears it. It skips during ordinary phone runs unless explicitly enabled, so unconfigured runs cannot be reported as passing this pose. The exact-pose run reported `TEST EXECUTE SUCCEEDED`; its log is `/tmp/solidus-portrait-unlocked-tests.log`.

## App Store 1.4 preparation

The signed iPhone/Watch release archive succeeded with Xcode 27.1 build 27A9275. `StoreScreenshotTests` is an opt-in real-control capture workflow covering 25% Off 128 = 96.00 and 18% Of 86 = 15.48. Its final run passed one test with zero failures; it waits briefly after key release so captured keys are not highlighted. It skips during ordinary runs unless `SOLIDUS_STORE_SCREENSHOTS=1` is present in the UI test runner environment. Final result: `/tmp/solidus-store-outer-final.xcresult`.

The three-image Duo set in `AppStore/1.4` passed app-shots pixel validation and live-catalog upload preflight. The inner portrait image comes from the earlier exact-pose validation, with unchanged UI. New Device Hub and hinge readback attempts after the Xcode update timed out and are not counted as additional pose coverage. The screenshot simulator was shut down after capture; its hinge was not changed during this capture session.
