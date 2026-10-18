"""Read-only official SDK archive audit. No installation, build or service configuration."""
import hashlib
import io
import json
from pathlib import Path
import plistlib
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parents[2]
sdks = [
    ('GoogleMobileAds', '12.14.0',
     'https://dl.google.com/googleadmobadssdk/c8c5523373ed76aa/googlemobileadsios-spm-12.14.0.zip',
     'c8c5523373ed76aa6da7bbe1324458e680981bd4593271cca5958fc8e8ffc5e7'),
    ('UserMessagingPlatform', '3.1.0',
     'https://dl.google.com/googleadmobadssdk/90fe6bf3b0f4ce0d/googleusermessagingplatformios-spm-3.1.0.zip',
     '90fe6bf3b0f4ce0d0199628c0871de58b6f673375148b98d52348aecc86db231')
]
report = {'auditDate': '2026-10-18', 'action': 'Official archives read into memory; not installed or executed', 'sdks': []}
for name, version, url, expected in sdks:
    data = urllib.request.urlopen(url, timeout=30).read()
    digest = hashlib.sha256(data).hexdigest()
    assert digest == expected, f'{name} archive does not match official Swift package checksum'
    archive = zipfile.ZipFile(io.BytesIO(data))
    manifests = []
    headers = []
    for member in archive.namelist():
        if member.endswith('PrivacyInfo.xcprivacy'):
            manifests.append({'path': member, 'manifest': plistlib.loads(archive.read(member))})
        if member.endswith('.h') and '/ios-arm64/' in member:
            contents = archive.read(member).decode('utf-8')
            for symbol in ['GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth',
                           'publisherPrivacyPersonalizationState', 'setPublisherFirstPartyIDEnabled',
                           'GADDelayAppMeasurementInit']:
                if symbol in contents:
                    headers.append({'path': member, 'verifiedSymbol': symbol})
    assert manifests, f'{name} privacy manifest absent'
    report['sdks'].append({'name': name, 'version': version, 'url': url, 'sha256': digest,
                          'bytes': len(data), 'privacyManifests': manifests, 'headerSymbols': headers})
out = ROOT / 'docs/technical/monetization-20261018/SDK_AUDIT.json'
out.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print('Verified two official SDK checksums and extracted bundled privacy manifests; no binaries retained.')
