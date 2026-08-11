# Canonical Screen Masters

Updated: 2026-08-11
Authority: A-038 in `DECISIONS.md`
Repository root: `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative`

## Purpose

This is the canonical manifest of complete approved images that currently govern Tarot Deck's real screen compositions. `design/APPROVALS.md` and `DECISIONS.md` preserve approval history; this file answers which single master is current for each covered screen, state, orientation, and language.

All paths below are repository-relative. Every listed SHA-256 and canvas size was recomputed from the PNG on 2026-08-11. A current master is a visual specification, not a screenshot from the running app. Embedded Rider-Waite-Smith card faces remain release-blocking candidate art under the content-rights audit; their presence does not approve those card-face assets for distribution.

## Status rules

- `CURRENT` is the only status that governs final implementation and visual comparison.
- `APPROVED, NOT ACTIVE` records an approved future surface that is not part of the current build.
- `REPLACED` and `NOT SELECTED` never govern implementation, even when their files remain in the repository.
- One PNG may govern two states only where the approved component deliberately keeps one fixed composition. The current progressive Home selector has separate masters for closed, count-choice, and style-choice states.
- A localized master governs the named language exactly. Where the decision register says that the other language uses the same composition, it governs layout only; runtime copy must still come from the verified localization bundle.
- A-050 is a copy-only correction inside existing compositions: wherever V-067/V-068/V-069 or V-071 visibly says `Outcome / Resultado`, runtime `0.4.1` must say `Destiny / Destino`. Those PNGs continue to govern layout, materials and hierarchy; their superseded word does not govern localized copy.
- A-051 is a copy-only correction inside the existing selector and Learn article compositions: runtime `0.4.2` must explain the purpose of Situation/Challenge/Guidance instead of merely restating its three labels. Existing PNGs continue to govern layout, materials and hierarchy.
- Accessibility adaptations allowed by `design/APPROVALS.md` remain valid, but they may not silently replace the composition.

## Current masters

| Master | Screen / state | Source approval | Path | Canvas | Orientation | Language | Approval date | SHA-256 |
|---|---|---|---|---:|---|---|---|---|
| M-S01-HOME-P | `S01.1 Read Home` — compact selector closed, deck hero | V-058, A-021/A-042 | `design/tarot-deck/read-home-compact-selector-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-11 | `9C0D453917EFC6D16DE3A6013E6B3BD3F45949F48D229F688C77A26E6FAA0C29` |
| M-S01-COUNT-P | `S01.2 Read Home` — one/three card selector with information | V-074, A-021/A-048 | `design/tarot-deck/read-home-reading-count-selector-info-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-11 | `8AD118426B2D1B7BDA0F00F4012EF59DF85A2152791510F4E8BC41BDFAECA576` |
| M-S01-STYLE-P | `S01.3 Read Home` — five three-card styles with information | V-076, A-021/A-048 | `design/tarot-deck/read-home-three-card-style-selector-free-info-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-11 | `95057F7A6F6BAE859088D7D2EE806130EFBB88B8635A05DADDD455466DD6E503` |
| M-S01-HOME-L | `S01.1 Read Home` — compact selector closed, deck hero | V-061, A-021/A-042 | `design/tarot-deck/read-home-compact-selector-landscape-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-11 | `C1E3AB1BCBC9E8F15E1D19D1C0E1F6BC51A85CF23D5A8A4C00BFF05F5E67879D` |
| M-S01-COUNT-L | `S01.2 Read Home` — one/three card selector with information | V-075, A-021/A-048 | `design/tarot-deck/read-home-reading-count-selector-info-landscape-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-11 | `77BCD0B4FA279E5A92E18D2B27B1E332E3788E5412B0EEE3BE7E28B515EAE943` |
| M-S01-STYLE-L | `S01.3 Read Home` — five three-card styles with information | V-077, A-021/A-048 | `design/tarot-deck/read-home-three-card-style-selector-free-info-landscape-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-11 | `B8F5598D312B7587CE31A2F3D86AD92246A4FB7DB0546E8A305B4701CF192FBE` |
| M-SHELL-TAB-P | Global primary tab bar material — `Read / Learn / Cards` | V-064, A-021/A-044 | `design/tarot-deck/read-shell-translucent-tabbar-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; material also governs English and all tab roots | 2026-08-11 | `C76D9D579AD0341E95C717DD0B834A8D29A609BB70DDCFEFCA2C9AF853E1AB9D` |
| M-S03-THREE-READY-P | `S03.1 Three Cards` — ready; deck is the shuffle control | V-046, A-021/A-031 | `design/tarot-deck/reading-table-three-cards-deck-tap-ready-spanish-a-ceremonial-obsidian.png` | 861×1827 | Portrait | Spanish; layout also governs English | 2026-08-10 | `C05A106C77884EEA07C28B5E2BA677875F678E4FAD5F97AAAAF553D636082BBD` |
| M-S03-THREE-COMPLETE-DOWN-P | `S03.5 Three Cards` — layout complete, all face down and centered | V-047, A-021/A-031 | `design/tarot-deck/reading-table-three-cards-face-down-centered-spanish-a-ceremonial-obsidian.png` | 862×1825 | Portrait | Spanish; layout also governs English | 2026-08-10 | `E2218EC5FFB80986B6A72D72DD0E710F8DFBCEB8D39060637F0A49CA0C26F77E` |
| M-S03-THREE-REVEALED-P | `S03.6 Three Cards` — all revealed, quick restart | V-052, A-021/A-033 | `design/tarot-deck/reading-table-three-cards-quick-restart-all-revealed-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-11 | `D30E951A91CE53049D5871E964DB05D4E9215B59BCECED12C159CA63E4E777E9` |
| M-S03-THREE-REVEALED-L | `S03.6 Three Cards` — all revealed, quick restart | V-053, A-021/A-033 | `design/tarot-deck/reading-table-three-cards-quick-restart-landscape-spanish-a-ceremonial-obsidian.png` | 1846×852 | Landscape | Spanish; layout also governs English | 2026-08-11 | `1A7749728BA62E51D1E2F75463B077329E9397AA04E30C856998E04FE242FE10` |
| M-S03-YESNO-DOWN-P | `S03.5 Yes or No` — all face down and centered | V-067, A-021/A-045 | `design/tarot-deck/reading-table-yes-no-face-down-spanish-a-ceremonial-obsidian.png` | 862×1825 | Portrait | Spanish; layout also governs English | 2026-08-11 | `E5B084EF0D98A1E5E9A7D79F49714A8FC8A98366149D0564A813A9F95D611574` |
| M-S03-YESNO-REVEALED-P | `S03.6 Yes or No` — all revealed, quick restart | V-068, A-021/A-045 | `design/tarot-deck/reading-table-yes-no-all-revealed-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-11 | `96A99F433CB0AC959AF43DABFA78F935B8263CC19D61DC20407EA2F2E82FE7C9` |
| M-S03-YESNO-REVEALED-L | `S03.6 Yes or No` — all revealed, quick restart | V-069, A-021/A-045 | `design/tarot-deck/reading-table-yes-no-all-revealed-landscape-spanish-a-ceremonial-obsidian.png` | 1846×852 | Landscape | Spanish; layout also governs English | 2026-08-11 | `EB02233108B1CAEAAB77FDFF5EE2D4242930F7671FE6CE14F6F7D09866E8E24D` |
| M-S03-FREE-DOWN-P | `S03.5 Freeform` — all face down, neutral labels | V-078, A-021/A-048 | `design/tarot-deck/reading-table-free-three-cards-face-down-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-11 | `06A7E6172BBB0118C450E70CBB7B1D0AFFF26049C8AD0DC8E65B34415B2F3F64` |
| M-S03-FREE-DOWN-L | `S03.5 Freeform` — all face down, neutral labels | V-079, A-021/A-048 | `design/tarot-deck/reading-table-free-three-cards-face-down-landscape-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-11 | `237339897355BBA5CF0B985EE5D9536A8F0444AC03C773D89A0F33CDBFE82E3B` |
| M-S03-ONE-REVEALED-P | `S03.6 One Card` — revealed, quick restart | V-056, A-021/A-033 | `design/tarot-deck/reading-table-one-card-quick-restart-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-11 | `EDFCDC1C87D5F9D32194A58B7AD2F82862DAE9080467E4B44612DC2041628BF4` |
| M-S03-ONE-REVEALED-L | `S03.6 One Card` — revealed, quick restart | V-057, A-021/A-033 | `design/tarot-deck/reading-table-one-card-quick-restart-landscape-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-11 | `B6591843EB4670CACEBE297D8D8836411C8FF9CAD52321120B6795CA1DC9A7FB` |
| M-S05-LEARN-P | `S05.1 Learn Index` — foundations with Tutorials portal | V-072, A-021/A-048 | `design/tarot-deck/learn-index-foundations-with-tutorials-spanish-a-ceremonial-obsidian.png` | 862×1825 | Portrait | Spanish; layout also governs English | 2026-08-11 | `4A189CAF9A748D7ADF91C1E5B86A79B6CD7525CF79B34A8A105BD9064A4F80C6` |
| M-S05-TUTORIALS-P | `S05.3 Reading Tutorials Index` — six methods | V-073, A-021/A-048 | `design/tarot-deck/learn-reading-tutorials-index-spanish-a-ceremonial-obsidian.png` | 862×1824 | Portrait | Spanish; layout also governs English | 2026-08-11 | `75A1B78C069CD8FB5FB5DDB7931F949BE9BDCD5AFA6D5D374F3331370B73FF28` |
| M-S06-LEARN-ARTICLE-P | `S06.1 Learn Article` — concise three-section method | V-071, A-021/A-046 | `design/tarot-deck/learn-article-yes-no-concise-spanish-a-ceremonial-obsidian.png` | 862×1824 | Portrait | Spanish; layout also governs English | 2026-08-11 | `27E00A160EC05D0B04FA704CFB3E0F712AD6A6355E29AA8967A40EC4D43F0988` |
| M-S07-FAVORITES-EMPTY-P | `S07.3 Cards Library` — Favorites empty | V-043, A-021/A-030 | `design/tarot-deck/cards-library-favorites-empty-a-ceremonial-obsidian.png` | 854×1840 | Portrait | English | 2026-08-10 | `62AED89CC28393E7FD2BC9B06F99240D576EA61FC90F39C8511DBDBA11FFCA87` |
| M-S09-SETTINGS-P | `S09.1 Settings` — language selector | V-045, A-021/A-031 | `design/tarot-deck/settings-language-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-10 | `559D2E73882A723A24C55EBFF038CEEA9452B1CB62BD4A1C9E4ABF8E20518615` |

## Approved but not active in the current build

| Reference | Planned screen / state | Status | Path | Canvas | Orientation | Language | Approval date | SHA-256 |
|---|---|---|---|---:|---|---|---|---|
| V-027 | `S10.1 Support the App` — not active | `APPROVED, NOT ACTIVE`; StoreKit products, live prices, contracts and purchase flow remain unauthorized | `design/tarot-deck/support-the-app-a-ceremonial-obsidian-v2.png` | 853×1844 | Portrait | English | 2026-08-09 | `12411E9486B44B619F438669CEA04143EDDBCC0967F85758C0D5277E5ACD6C7A` |

## Approved supporting specification, not a screen master

| Reference | Purpose | Status | Path | Canvas | Date | SHA-256 |
|---|---|---|---|---:|---|---|
| V-048 | Reading Table principal-motion storyboard and keyframes | `CURRENT SUPPORTING SPEC`; governs motion with `design/tarot-deck/MOTION_SPEC.md`, but is not a complete app screen or store capture | `design/tarot-deck/reading-table-professional-motion-storyboard-v2-a-ceremonial-obsidian.png` | 1672×941 | 2026-08-10 | `937F89E3DF7D2161E6AD2C835A4201135161E6ADED083A4BE52B8773A58190F0` |

## Replacement ledger

The files below remain preserved, but none is current. A replacement can govern only the same state it actually depicts; when no exact replacement exists, the state is listed under coverage gaps instead of promoting a different image.

| Replaced / retired reference | Historical surface | Replacement or disposition |
|---|---|---|
| V-001, V-004 | Daily Tarot screens | Historical product only after A-014; no Tarot Deck master. |
| V-013 | Read Home, empty | Replaced by V-024, then V-044, V-054, and current V-058/V-061. |
| V-014 | Separate Layout Choice | Retired by A-033; current progressive visual selector V-058–V-063 owns preset selection. |
| V-005–V-012, V-015/V-016 | Earlier Three Cards table states | V-046/V-047/V-052/V-053 replace only the exact states they depict. A-031/A-033 also retired the separate primary buttons and `End Reading`; the remaining old states have no exact current master. V-040 separately replaced the old landscape proportions before V-053 replaced its complete all-revealed state. |
| V-017, V-018 | Three Cards, all revealed | Replaced by current V-052/V-053 with quick restart. |
| V-019, V-023, V-042 | Card meaning/detail states | A-031 makes `Upright / Al derecho` a plain editorial heading, not the pill shown in these images. No exact replacement master is registered. |
| V-020, V-021 | Learn index/article | V-020 was replaced by V-070 and then current V-072, which restores its hierarchy with concise copy and a Tutorials portal. V-021 remains replaced by V-071 for article structure. |
| V-022 | Cards Library / All | A-030 added Favorites as a first-class filter; only the V-043 Favorites-empty state has a current exact master. |
| V-024 | Read Home with Settings access | Replaced by V-044, V-054, and current V-058/V-061. |
| V-025 | Settings | Replaced by current V-045 with the internal language selector. |
| V-026 | Support the App | Replaced by V-027; V-027 remains approved but inactive. |
| V-028 | Active-reading Home | Retired by A-033; restoration returns directly to the table and Home uses V-058–V-063. |
| V-029–V-038 | Earlier One Card ready, shuffled, face-down and revealed states | V-056/V-057 replace only the exact revealed state. A-031/A-033 retired the separate primary buttons and `End Reading`; ready, shuffled and face-down states have no exact current master. |
| V-039 | Separate Three Cards spread choice | Retired by A-033; preset selection now uses current V-058–V-063. |
| V-040 | Three Cards large landscape, all revealed | Replaced for the complete all-revealed state by current V-053. |
| V-041 | Reading Table motion storyboard | Replaced by current supporting specification V-048. |
| V-044 | Read Home compact deck CTA | Replaced by V-054 and then current V-058/V-061. |
| V-049, V-050 | Home dropdown, portrait closed/open | Rejected as a vertical text selector; later V-054 was also replaced by current V-058–V-060. |
| V-051 | Home dropdown, landscape | Replaced by V-055 and then current V-061–V-063. |
| V-054, V-055 | Home visual preset carousel, portrait/landscape | Replaced by V-058–V-063 after owner QA: the carousel occupied too much permanent space and made the deck too small. Preserved as historical references. |
| V-060, V-063 | Home three-card style selector with `Open reading / Tirada abierta` | Replaced by current V-065/V-066 after A-045 made the documented Yes or No spread the fifth preset. |
| V-059, V-062 | Home one/three selector without information | Replaced by current V-074/V-075. |
| V-065, V-066 | Home four-style selector with Yes or No | Replaced by current V-076/V-077 after A-048 added Freeform and tutorial information actions. |
| V-070 | Learn index with all tutorials flattened | Replaced by current V-072; V-073 now owns the separate tutorial collection. |

## Proposals and unselected files

These PNGs are deliberately outside the current-master table. They have no active V identifier or were explicitly not selected.

| Status | Path | Canvas | Language | SHA-256 | Reason |
|---|---|---:|---|---|---|
| `NOT SELECTED` | `design/tarot-deck/cards-library-all-a-ceremonial-obsidian.png` | 863×1823 | English | `93DB75D03B27D4849A882B17F762DBFF70708F0BE3B3D839927F8AF0855F73FA` | Initial library/search variant; V-022 points to the v2 image instead. |
| `NOT SELECTED` | `design/tarot-deck/three-card-spread-choice-spanish-a-ceremonial-obsidian.png` | 862×1825 | Spanish | `3E5735C2912284C69655194E1522970E574FA32E9D62910DBECA420666D63894` | Initial spread-choice variant; V-039 pointed to v2 before that screen was retired. |
| `NOT SELECTED` | `design/tarot-deck/reading-table-three-cards-quick-restart-spanish-a-ceremonial-obsidian.png` | 862×1825 | Spanish | `D4650207183752445A82755B3406CDFF13C7C3B0752CCA1BC2830419ACBD843A` | Earlier quick-restart exploration; current portrait master is V-052. |
| `NOT SELECTED` | `design/tarot-deck/read-home-visual-preset-carousel-six-spanish-a-ceremonial-obsidian.png` | 862×1824 | Spanish | `78A16F15D9333460EAB9DA98BF1CD08CD73500067836E2D57164517104C01A60` | Six-preset exploration rejected by A-034; A-042 later retired permanent Home carousels altogether. |
| `NOT SELECTED` | `design/tarot-deck/read-home-visual-preset-carousel-six-landscape-spanish-a-ceremonial-obsidian.png` | 1844×853 | Spanish | `3BB4FAD8F849388258B5189537DA428E5167D22B9E76300C0EDB8C04C2848BD1` | Landscape companion to the rejected six-preset exploration; A-042 later retired permanent Home carousels altogether. |

## Known canonical coverage gaps

No substitute is invented for a state whose older image was replaced. As of 2026-08-11, this manifest has no current complete master for:

- `S00` restore/recovery states;
- exact current Three Cards masters for `S03.1` landscape, `S03.2`, `S03.3`, `S03.4`, and `S03.5` mixed; and the all-face-down `S03.5` landscape state;
- exact current One Card masters for `S03.1`, `S03.2`, and `S03.3` in both orientations;
- `S04` card meaning after the plain-heading change in A-031;
- `S05` and `S06` after the seven-tutorial Yes or No content change in A-045;
- `S07.1/S07.2` library states after the Favorites filter change in A-030;
- `S08` card detail after the plain-heading change in A-031;
- landscape composition for current V-043 and V-045, where only portrait masters are registered;
- separate English raster masters for Spanish-led V-045/V-046/V-047/V-052–V-057, or separate Spanish raster masters for English-led references;
- `S10.2` through `S10.5`, and a current-build master for `S10.1` while commerce remains inactive;
- custom error or confirmation compositions that depart from standard native iOS presentation.

These gaps do not make a replaced image current. A new complete in-scope image must be generated, registered under A-021/A-038, hashed, and added here before it can become the final visual reference for that exact surface.

## App Store capture linkage

Concept masters provide art direction only. Every final App Store screenshot must start from an actual app-build capture, not from a concept PNG or a reconstructed mockup. The capture record must include:

- the source app version and build;
- commit SHA and, when applicable, CI run;
- real capture path, device/simulator and pixel canvas;
- orientation and language;
- capture date and SHA-256;
- the `M-*` master ID used for visual direction and the comparison result.

No final App Store base capture is registered as of 2026-08-11. Store artwork must not be marked ready until the build capture and its master linkage are added to this manifest.
