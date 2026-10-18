"""Idempotent local project/catalog preparation; never builds or accesses a service."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
project = ROOT / 'native-ios/TarotDeck.xcodeproj/project.pbxproj'
text = project.read_text(encoding='utf-8')
sources = [('90', 'TarotAdConsent.swift', 'Internal'),
           ('91', 'SupportReminderStore.swift', 'Internal'),
           ('92', 'TarotBanner.swift', 'Components')]
for suffix, name, group in sources:
    a, b = 'A900000000000000000000' + suffix, 'B900000000000000000000' + suffix
    if f'/* {name} in Sources */' in text:
        continue
    text = text.replace('/* End PBXBuildFile section */',
        f'\t\t{a} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {b} /* {name} */; }};\n/* End PBXBuildFile section */')
    text = text.replace('/* End PBXFileReference section */',
        f'\t\t{b} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = "<group>"; }};\n/* End PBXFileReference section */')
    anchor = 'B80000000000000000000001 /* SupporterStore.swift */,' if group == 'Internal' else 'B10000000000000000000002 /* CeremonialBackdrop.swift */,'
    text = text.replace(anchor, anchor + f'\n\t\t\t\t{b} /* {name} */,')
    anchor = 'A80000000000000000000001 /* SupporterStore.swift in Sources */,'
    text = text.replace(anchor, anchor + f'\n\t\t\t\t{a} /* {name} in Sources */,')

packages = [('10', 'GoogleMobileAds', 'google-mobile-ads', '12.14.0'),
            ('11', 'GoogleUserMessagingPlatform', 'google-user-messaging-platform', '3.1.0')]
for suffix, product, slug, version in packages:
    ref, dep, build = ('F900000000000000000000' + suffix,
                       'F800000000000000000000' + suffix,
                       'A800000000000000000000' + suffix)
    if f'productName = {product};' in text:
        continue
    text = text.replace('/* End PBXBuildFile section */',
        f'\t\t{build} /* {product} in Frameworks */ = {{isa = PBXBuildFile; productRef = {dep} /* {product} */; }};\n/* End PBXBuildFile section */')
    anchor = 'A1000000000000000000000A /* TarotDeckCore in Frameworks */,'
    text = text.replace(anchor, anchor + f'\n\t\t\t\t{build} /* {product} in Frameworks */,')
    anchor = 'F10000000000000000000001 /* TarotDeckCore */,'
    text = text.replace(anchor, anchor + f'\n\t\t\t\t{dep} /* {product} */,')
    anchor = 'F10000000000000000000002 /* XCLocalSwiftPackageReference "." */,'
    text = text.replace(anchor, anchor + f'\n\t\t\t\t{ref} /* {product} */,')
    text = text.replace('/* Begin XCLocalSwiftPackageReference section */', f'''/* Begin XCRemoteSwiftPackageReference {product} */
        {ref} /* {product} */ = {{
            isa = XCRemoteSwiftPackageReference;
            repositoryURL = "https://github.com/googleads/swift-package-manager-{slug}.git";
            requirement = {{ kind = exactVersion; version = {version}; }};
        }};
/* End XCRemoteSwiftPackageReference {product} */

/* Begin XCLocalSwiftPackageReference section */''')
    text = text.replace('/* End XCSwiftPackageProductDependency section */',
        f'\t\t{dep} /* {product} */ = {{isa = XCSwiftPackageProductDependency; package = {ref} /* {product} */; productName = {product}; }};\n/* End XCSwiftPackageProductDependency section */')
if 'INFOPLIST_FILE = TarotDeckApp/Resources/Advertising.plist;' not in text:
    text = text.replace('GENERATE_INFOPLIST_FILE = YES;', 'GENERATE_INFOPLIST_FILE = YES;\n\t\t\t\tINFOPLIST_FILE = TarotDeckApp/Resources/Advertising.plist;\n\t\t\t\tOTHER_LDFLAGS = "$(inherited) -ObjC";')
project.write_text(text, encoding='utf-8', newline='\n')

translations = {
    'Advertisement': 'Anuncio',
    'Support the app without ads': 'Apoya la app sin anuncios',
    'Any monthly level removes ads while active. The full app stays free.': 'Cualquier nivel mensual retira los anuncios mientras esté activo. La app completa sigue siendo gratis.',
    'See support options': 'Ver opciones de apoyo',
    'Not now': 'Ahora no',
    "Don't ask again": 'No volver a preguntar',
    'Advertising choices': 'Opciones de publicidad',
    'Opens advertising privacy choices': 'Abre las opciones de privacidad publicitaria',
    'Advertising choices unavailable': 'Opciones de publicidad no disponibles',
    'Ads remain off. You can try again later.': 'Los anuncios siguen desactivados. Puedes intentarlo más tarde.'
}
catalog = ROOT / 'native-ios/TarotDeckApp/Resources/Localizable.xcstrings'
raw = catalog.read_text(encoding='utf-8')
existing = json.loads(raw)['strings']
for key, translation in translations.items():
    if key in existing:
        continue
    entry = json.dumps(key, ensure_ascii=False) + ' : ' + json.dumps(
        {'localizations': {'es': {'stringUnit': {'state': 'translated', 'value': translation}}}}, ensure_ascii=False)
    raw = raw.replace('"strings" : {', '"strings" : {\n    ' + entry + ',')
catalog.write_text(raw, encoding='utf-8', newline='\n')
manifest = ROOT / 'native-ios/TarotDeckApp/Resources/required-interface-keys.v1.json'
doc = json.loads(manifest.read_text(encoding='utf-8'))
doc['keys'] += [key for key in translations if key not in doc['keys']]
manifest.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

svg = ROOT / 'design/monetization-20261018/integration.svg'
(svg.parent / 'REFERENCE.md').write_text(
    '# Scoped integration reference\n\nCreated before UI implementation on 2026-10-18 under the delegated integration authority. '
    'Complete code-native composition study; ES governs EN layout. No global master is replaced.\n\n'
    'integration.svg — 1660×980, four complete 375×812 screen compositions; '
    'ordinary Learn/banner, full table/no space, Settings/reminder/privacy and active supporter/no ads. '
    'Preserve existing masters for all actual controls and artwork. This study documents the new footprint and copy only. '
    'Native screenshot comparison remains pending macOS/device; this is not runtime evidence.\n\nSHA-256: `'
    + hashlib.sha256(svg.read_bytes()).hexdigest() + '`\n', encoding='utf-8')
print('Prepared project references, exact SDK pins, EN/ES catalog and scoped visual manifest; no build/service action.')
