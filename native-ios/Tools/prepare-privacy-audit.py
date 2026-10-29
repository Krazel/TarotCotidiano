#!/usr/bin/env python3
"""Disposable simulator-only privacy experiment; never prepare a distributable app."""
import argparse
import hashlib
import json
import os
import plistlib
import re
import subprocess
import time
from pathlib import Path


LEGACY = (
    "testLegacyNoUsageDescriptionOutsideEEAAllowsSampleBanner",
    "testLegacyNoUsageDescriptionEEAAllowsSampleBanner",
)
TRACKING = (
    "testNoRequestsBeforeFirstConsentChoice",
    "testNonEEAATTDenialAllowsTestBanner",
    "testNonEEAATTAuthorizationAllowsTestBanner",
    "testAcceptAndPersistChoiceAcrossRelaunch",
    "testRejectDoesNotBecomePersonalizationConsent",
    "testReopenAdvertisingChoicesAndRevokeAcceptedChoice",
)
USAGE = "NSUserTrackingUsageDescription"
APP_NAME = "TarotDeckInternal.app"


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def main_localized_info(app):
    return sorted(set(app.glob("*.lproj/InfoPlist.strings"))
                  | set(app.glob("*.lproj/InfoPlist.stringsdict")))


def resource_fingerprint(app, excluded):
    files = [(str(path.relative_to(app)), digest(path)) for path in sorted(app.rglob("*"))
             if path.is_file() and str(path.relative_to(app)) not in excluded]
    payload = json.dumps(files, separators=(",", ":")).encode("utf-8")
    return {"fileCount": len(files), "sha256": hashlib.sha256(payload).hexdigest()}


def read_plist(path):
    raw = path.read_bytes()
    try:
        value = plistlib.loads(raw)
    except plistlib.InvalidFileException:
        # Xcode can leave localized .strings in OpenStep format; use Apple's parser.
        raw = subprocess.check_output(
            ["plutil", "-convert", "xml1", "-o", "-", str(path)], timeout=30
        )
        value = plistlib.loads(raw)
    require(isinstance(value, dict), f"Expected a dictionary plist: {path}")
    return value


def write_plist(path, value):
    path.write_bytes(plistlib.dumps(value, fmt=plistlib.FMT_BINARY, sort_keys=False))
    require(read_plist(path) == value, f"Plist round-trip failed: {path}")


def contains_key(value, key):
    if isinstance(value, dict):
        return key in value or any(contains_key(v, key) for v in value.values())
    return isinstance(value, list) and any(contains_key(v, key) for v in value)


def remove_key(value, key):
    if isinstance(value, dict):
        value.pop(key, None)
        for child in value.values():
            remove_key(child, key)
    elif isinstance(value, list):
        for child in value:
            remove_key(child, key)


def collect_values(value, key):
    if isinstance(value, dict):
        return ([value[key]] if key in value else []) + [
            found for child in value.values() for found in collect_values(child, key)
        ]
    if isinstance(value, list):
        return [found for child in value for found in collect_values(child, key)]
    return []


def assert_sample_app(app):
    require(app.name == APP_NAME and app.is_dir(), "Expected the compiled audit app")
    info = read_plist(app / "Info.plist")
    for key, expected in {
        "CFBundleIdentifier": "com.krazel.tarotdeck.internal.provisional",
        "DTPlatformName": "iphonesimulator",
        "TarotAdvertisingMode": "test-only",
        "GADApplicationIdentifier": "ca-app-pub-3940256099942544~1458002511",
        "TarotBannerAdUnitID": "ca-app-pub-3940256099942544/2435281174",
    }.items():
        require(info.get(key) == expected, f"Unsafe audit app contract: {key}")
    require(not info.get("GADEnableNetworkTracing", False), "Raw network tracing is forbidden")
    return info


def inject_tests(args):
    source = args.source.read_text(encoding="utf-8")
    fragment = args.fragment.read_text(encoding="utf-8")
    methods = re.findall(r"\bfunc\s+(test\w+)\s*\(", fragment)
    require(set(methods) == set(LEGACY) and len(methods) == 2, "Expected exactly two audit test methods")
    require(all(name not in source for name in LEGACY), "Audit tests already injected")
    require(all(len(re.findall(r"\bfunc\s+" + name + r"\s*\(", source)) == 1 for name in TRACKING),
            "Expected the six original consent tests")
    require(source.count("final class TarotConsentUITests: XCTestCase") == 1, "Unexpected test class")
    require(len(re.findall(r"^}\s*$", source, re.M)) == 1 and source.rstrip().endswith("}"),
            "Test class must be the sole top-level closing brace")
    before = digest(args.source)
    patched = source.rstrip()[:-1] + "\n    // Runner-only privacy audit methods.\n" + fragment + "\n}\n"
    args.source.write_text(patched, encoding="utf-8")
    save(args.receipt, {"sourceBeforeSHA256": before, "sourceAfterSHA256": digest(args.source),
                        "fragmentSHA256": digest(args.fragment), "injectedTests": list(LEGACY),
                        "sourceCommit": os.environ.get("GITHUB_SHA"), "runnerOnly": True})


def compiled_test_app(products):
    products = products.resolve()
    require(products.name == "Products" and products.parent.name == "Build", "Expected DerivedData/Build/Products")
    app = products / "Debug-iphonesimulator" / APP_NAME
    info = assert_sample_app(app)
    require(bool(info.get(USAGE)), "Baseline build must contain the ATT usage description")
    runs = list(products.rglob("*.xctestrun"))
    require(len(runs) == 1, f"Expected exactly one real .xctestrun; found {len(runs)}")
    run = runs[0].resolve()
    targets = collect_values(read_plist(run), "UITargetAppPath")
    require(len(targets) == 1 and isinstance(targets[0], str), "Expected one UI target app path")
    target = Path(targets[0].replace("__TESTROOT__", str(run.parent))).resolve()
    require(target == app.resolve(), "The .xctestrun must launch the app being patched")
    return app, info, run


def prepare_control(args):
    app, info, run = compiled_test_app(args.products)
    executable = app / info["CFBundleExecutable"]
    save(args.receipt, {"controlTest": "testNonEEAATTAuthorizationAllowsTestBanner",
                        "sourceCommit": os.environ.get("GITHUB_SHA"), "app": str(app),
                        "usageDescriptionPresent": True, "infoSHA256": digest(app / "Info.plist"),
                        "binary": str(executable), "binarySHA256": digest(executable),
                        "xctestrun": str(run), "xctestrunSHA256": digest(run),
                        "sampleInventoryOnly": True, "passed": False})
    with args.github_env.open("a", encoding="utf-8") as output:
        output.write(f"TAROT_AUDIT_CONTROL_XCTESTRUN={run}\n")


def verify_control(args):
    receipt = json.loads(args.receipt.read_text(encoding="utf-8"))
    app = Path(receipt["app"])
    info = assert_sample_app(app)
    require(bool(info.get(USAGE)), "Positive control must retain the ATT usage description")
    require(digest(app / "Info.plist") == receipt["infoSHA256"], "Positive-control Info.plist changed")
    require(digest(Path(receipt["binary"])) == receipt["binarySHA256"], "Positive-control executable changed")
    require(digest(Path(receipt["xctestrun"])) == receipt["xctestrunSHA256"], "Positive-control test configuration changed")
    receipt["observed"] = test_outcomes(args.log)
    receipt["logSHA256"] = digest(args.log)
    receipt["passed"] = receipt["observed"] == {receipt["controlTest"]: ["passed"]}
    save(args.receipt, receipt)
    require(receipt["passed"], "Real ATT authorization control must pass exactly once, with no other cases or skips")


def patch_app(args):
    app, info, run = compiled_test_app(args.products)
    executable = app / info["CFBundleExecutable"]
    binary_sha = digest(executable)
    sdk_manifests = {str(p.relative_to(app)): digest(p) for p in app.rglob("PrivacyInfo.xcprivacy")
                     if p.parent != app}
    root_manifest_sha = digest(app / "PrivacyInfo.xcprivacy")
    touched = [app / "Info.plist"]
    if args.case == "legacy_no_usage":
        touched += main_localized_info(app)
    else:
        touched.append(app / "PrivacyInfo.xcprivacy")
    protected_exclusions = {str(p.relative_to(app)) for p in touched} | {str(executable.relative_to(app))}
    resources_before = resource_fingerprint(app, protected_exclusions)
    before = {str(touched[0].relative_to(app)): digest(touched[0])}
    domains = None
    if args.case == "legacy_no_usage":
        for path in touched:
            before[str(path.relative_to(app))] = digest(path)
            data = read_plist(path)
            remove_key(data, USAGE)
            write_plist(path, data)
            require(not contains_key(read_plist(path), USAGE), f"Localized usage description remains: {path}")
    else:
        config = json.loads(args.domains.read_text(encoding="utf-8"))
        domains = config.get("domains") if isinstance(config, dict) else config
        require(isinstance(domains, list) and domains and len(domains) == len(set(domains)),
                "Expected a nonempty unique domains array")
        require(all(isinstance(d, str) and re.fullmatch(r"(?=.{1,253}$)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?", d)
                    for d in domains), "Domains must be literal lowercase hostnames; no paths, wildcards or schemes")
        manifest = app / "PrivacyInfo.xcprivacy"
        before[manifest.name] = digest(manifest)
        data = read_plist(manifest)
        data["NSPrivacyTracking"] = True
        data["NSPrivacyTrackingDomains"] = domains
        write_plist(manifest, data)
    require(digest(executable) == binary_sha, "Audit must not modify the executable")
    require(resource_fingerprint(app, protected_exclusions) == resources_before,
            "Audit must preserve every resource outside its explicit main-bundle patch")
    assert_sample_app(app)
    receipt = {"case": args.case, "sourceCommit": os.environ.get("GITHUB_SHA"), "app": str(app),
               "xctestrun": str(run), "xctestrunSHA256": digest(run), "binary": str(executable),
               "binarySHA256": binary_sha, "beforeSHA256": before,
               "afterSHA256": {str(p.relative_to(app)): digest(p) for p in touched},
               "unchangedSDKManifestsSHA256": sdk_manifests,
               "unchangedResources": resources_before, "resourceExclusions": sorted(protected_exclusions),
               "domains": domains, "sampleInventoryOnly": True, "distributionEligible": False}
    if args.case == "tracking_domains":
        receipt["domainsSourceSHA256"] = digest(args.domains)
    else:
        receipt["unchangedRootManifestSHA256"] = root_manifest_sha
    save(args.receipt, receipt)
    if args.github_env:
        with args.github_env.open("a", encoding="utf-8") as output:
            output.write(f"TAROT_AUDIT_XCTESTRUN={run}\nTAROT_AUDIT_APP={app}\n")


def verify_app(args):
    receipt = json.loads(args.receipt.read_text(encoding="utf-8"))
    app = Path(receipt["app"])
    assert_sample_app(app)
    require(digest(Path(receipt["binary"])) == receipt["binarySHA256"], "Executable changed after patch")
    require(digest(Path(receipt["xctestrun"])) == receipt["xctestrunSHA256"], "Test run configuration changed")
    sdk_manifests = {str(p.relative_to(app)): digest(p) for p in app.rglob("PrivacyInfo.xcprivacy")
                     if p.parent != app}
    require(sdk_manifests == receipt["unchangedSDKManifestsSHA256"], "SDK manifests must remain untouched")
    require(resource_fingerprint(app, set(receipt["resourceExclusions"])) == receipt["unchangedResources"],
            "Unpatched bundle resources changed, appeared or disappeared")
    for relative, expected in receipt["afterSHA256"].items():
        require(digest(app / relative) == expected, f"Patched resource changed: {relative}")
    if receipt["case"] == "legacy_no_usage":
        require(digest(app / "PrivacyInfo.xcprivacy") == receipt["unchangedRootManifestSHA256"],
                "Legacy experiment must preserve the root privacy manifest")
        for path in [app / "Info.plist", *main_localized_info(app)]:
            require(not contains_key(read_plist(path), USAGE), f"Usage description remains: {path}")
    else:
        data = read_plist(app / "PrivacyInfo.xcprivacy")
        require(data.get("NSPrivacyTracking") is True and data.get("NSPrivacyTrackingDomains") == receipt["domains"],
                "Tracking manifest patch was not preserved")


def test_outcomes(log):
    outcomes = {}
    for line in log.read_text(encoding="utf-8", errors="replace").splitlines():
        if not re.search(r"\bTest [Cc]ase\b", line):
            continue
        name = re.search(r"\b(test[A-Z]\w+)\b", line)
        outcome = re.search(r"\b(passed|failed|skipped)\b", line, re.I)
        if name and outcome:
            outcomes.setdefault(name[1], []).append(outcome[1].lower())
    return outcomes


def verify_results(args):
    expected = set(LEGACY if args.case == "legacy_no_usage" else TRACKING)
    outcomes = test_outcomes(args.log)
    save(args.receipt, {"expected": sorted(expected), "observed": outcomes,
                        "logSHA256": digest(args.log), "case": args.case})
    require(set(outcomes) == expected, "Executed case names do not match the selected experiment")
    require(all(status == ["passed"] for status in outcomes.values()), "Each selected test must pass exactly once; no skips/retries")


def create_simulator(args):
    def version(value):
        return tuple(([int(n) for n in value.split(".")] + [0, 0, 0])[:3])
    runtimes = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "runtimes", "-j"]))
    save(args.output / "runtimes.json", runtimes)
    sdk = subprocess.check_output(["xcrun", "--sdk", "iphonesimulator", "--show-sdk-version"], text=True).strip()
    compatible = [r for r in runtimes["runtimes"] if r.get("isAvailable")
                  and r["identifier"].startswith("com.apple.CoreSimulator.SimRuntime.iOS-")
                  and version(r["version"]) <= version(sdk)]
    require(compatible, "No compatible iOS simulator runtime")
    runtime = max(compatible, key=lambda r: version(r["version"]))
    phones = [d for d in runtime.get("supportedDeviceTypes", []) if d.get("productFamily") == "iPhone"]
    require(phones, "No compatible iPhone type")
    device_type = next((d for d in phones if d["name"] == "iPhone 17 Pro"), sorted(phones, key=lambda d: d["identifier"])[0])
    name = f"TarotPrivacy-{args.case}-{args.output.name}-{os.environ.get('GITHUB_RUN_ID', 'local')}"
    device = subprocess.check_output(["xcrun", "simctl", "create", name, device_type["identifier"], runtime["identifier"]], text=True, timeout=60).strip()
    save(args.output / "device.json", {"udid": device, "runtime": runtime["identifier"], "sdk": sdk, "deviceType": device_type["identifier"]})
    with args.github_env.open("a", encoding="utf-8") as output:
        output.write(f"TAROT_AUDIT_DEVICE_ID={device}\n")
    started = time.monotonic()
    with (args.output / "boot.log").open("w", encoding="utf-8") as log:
        subprocess.run(["xcrun", "simctl", "boot", device], stdout=log, stderr=subprocess.STDOUT, timeout=60, check=True)
        subprocess.run(["xcrun", "simctl", "bootstatus", device, "-b"], stdout=log, stderr=subprocess.STDOUT,
                       timeout=max(1, 600 - (time.monotonic() - started)), check=True)
    devices = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "devices", "-j"]))
    require(any(d["udid"] == device and d["state"] == "Booted" for group in devices["devices"].values() for d in group), "Created simulator did not boot")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_subparsers(dest="mode", required=True)
    inject = modes.add_parser("inject-tests")
    inject.add_argument("--source", type=Path, required=True)
    inject.add_argument("--fragment", type=Path, required=True)
    inject.add_argument("--receipt", type=Path, required=True)
    control = modes.add_parser("prepare-control")
    control.add_argument("--products", type=Path, required=True)
    control.add_argument("--receipt", type=Path, required=True)
    control.add_argument("--github-env", type=Path, required=True)
    control_result = modes.add_parser("verify-control")
    control_result.add_argument("--receipt", type=Path, required=True)
    control_result.add_argument("--log", type=Path, required=True)
    patch = modes.add_parser("patch-app")
    patch.add_argument("--products", type=Path, required=True)
    patch.add_argument("--domains", type=Path, required=True)
    patch.add_argument("--github-env", type=Path)
    patch.add_argument("--receipt", type=Path, required=True)
    patch.add_argument("--case", choices=("legacy_no_usage", "tracking_domains"), required=True)
    verify = modes.add_parser("verify-app")
    verify.add_argument("--receipt", type=Path, required=True)
    results = modes.add_parser("verify-results")
    results.add_argument("--case", choices=("legacy_no_usage", "tracking_domains"), required=True)
    results.add_argument("--log", type=Path, required=True)
    results.add_argument("--receipt", type=Path, required=True)
    simulator = modes.add_parser("create-simulator")
    simulator.add_argument("--case", choices=("legacy_no_usage", "tracking_domains"), required=True)
    simulator.add_argument("--output", type=Path, required=True)
    simulator.add_argument("--github-env", type=Path, required=True)
    cases = modes.add_parser("cases")
    cases.add_argument("--case", choices=("legacy_no_usage", "tracking_domains"), required=True)
    args = parser.parse_args()
    if args.mode == "cases":
        for name in LEGACY if args.case == "legacy_no_usage" else TRACKING:
            print("-only-testing:TarotConsentUITests/TarotConsentUITests/" + name)
    else:
        globals()[args.mode.replace("-", "_")](args)


if __name__ == "__main__":
    main()
