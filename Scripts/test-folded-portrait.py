#!/usr/bin/env python3
"""Run the opt-in UI regression on an already configured Duo portrait half-fold."""
import argparse
import json
from pathlib import Path
import plistlib
import subprocess
import tempfile


def enable_folded_test(document):
    if "TestConfigurations" in document:
        targets = [target for configuration in document["TestConfigurations"]
                   for target in configuration.get("TestTargets", [])
                   if target.get("BlueprintName") == "SolidusUITests"]
    else:
        targets = [document["SolidusUITests"]] if "SolidusUITests" in document else []
    if not targets:
        raise ValueError("SolidusUITests is missing from the generated test run.")
    for target in targets:
        target.setdefault("EnvironmentVariables", {})["SOLIDUS_FOLDED_PORTRAIT_TEST"] = "1"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--udid", required=True, help="Dedicated, booted Duo simulator UDID")
    parser.add_argument("--derived-data", type=Path)
    parser.add_argument("--prepare-only", action="store_true")
    args = parser.parse_args()
    pose = json.loads(subprocess.check_output(
        ["duo-sim", "hinge", "get", "--udid", args.udid], text=True))
    if not pose.get("ok") or not pose.get("sampleValid") or abs(pose.get("angle", -999) - 90) > 1:
        parser.error("Configure a booted Duo at 90 degrees and rotate its inner display to portrait first.")
    root = Path(__file__).resolve().parent.parent
    derived = (args.derived_data or Path(tempfile.mkdtemp(prefix="solidus-folded-tests-"))).resolve()
    destination = f"platform=iOS Simulator,id={args.udid}"
    selected_test = "-only-testing:SolidusUITests/FoldedPortraitTests"
    subprocess.run(["xcodebuild", "-project", str(root / "Solidus.xcodeproj"),
                    "-scheme", "Solidus", "-destination", destination,
                    "-derivedDataPath", str(derived), selected_test,
                    "CODE_SIGNING_ALLOWED=NO", "build-for-testing"], check=True, cwd=root)
    products = derived / "Build" / "Products"
    candidates = [path for path in products.glob("*.xctestrun")
                  if path.name != "SolidusFoldedPortrait.xctestrun"]
    if not candidates:
        raise RuntimeError("Xcode did not generate an .xctestrun file.")
    generated = max(candidates, key=lambda path: path.stat().st_mtime)
    with generated.open("rb") as source:
        document = plistlib.load(source)
    enable_folded_test(document)
    # Keep the copy alongside the original so __TESTROOT__ still resolves correctly.
    configured = products / "SolidusFoldedPortrait.xctestrun"
    with configured.open("wb") as output:
        plistlib.dump(document, output)
    print(f"Configured pose regression: {configured}", flush=True)
    if not args.prepare_only:
        subprocess.run(["xcodebuild", "-xctestrun", str(configured),
                        "-destination", destination, selected_test,
                        "-parallel-testing-enabled", "NO", "test-without-building"], check=True, cwd=root)


if __name__ == "__main__":
    main()
