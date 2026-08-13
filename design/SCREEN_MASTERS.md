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
- A-051 remains incorporated in `0.5`: Situation/Challenge/Guidance explains its purpose instead of merely restating labels. A-052 then replaces the affected selector, table and motion states with V-080–V-089.
- Accessibility adaptations allowed by `design/APPROVALS.md` remain valid, but they may not silently replace the composition.

## Current masters

| Master | Screen / state | Source approval | Path | Canvas | Orientation | Language | Approval date | SHA-256 |
|---|---|---|---|---:|---|---|---|---|
| M-S01-HOME-P | `S01.1 Read Home` — compact selector closed, deck hero | V-058, A-021/A-042 | `design/tarot-deck/read-home-compact-selector-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-11 | `9C0D453917EFC6D16DE3A6013E6B3BD3F45949F48D229F688C77A26E6FAA0C29` |
| M-S01-HOME-L | `S01.1 Read Home` — compact selector closed, deck hero | V-061, A-021/A-042 | `design/tarot-deck/read-home-compact-selector-landscape-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-11 | `C1E3AB1BCBC9E8F15E1D19D1C0E1F6BC51A85CF23D5A8A4C00BFF05F5E67879D` |
| M-S01-COUNT-L | `S01.2 Read Home` — one/three card selector with information | V-075, A-021/A-048 | `design/tarot-deck/read-home-reading-count-selector-info-landscape-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-11 | `77BCD0B4FA279E5A92E18D2B27B1E332E3788E5412B0EEE3BE7E28B515EAE943` |
| M-S01-STYLE-L | `S01.3 Read Home` — five three-card styles with information | V-077, A-021/A-048 | `design/tarot-deck/read-home-three-card-style-selector-free-info-landscape-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-11 | `B8F5598D312B7587CE31A2F3D86AD92246A4FB7DB0546E8A305B4701CF192FBE` |
| M-SHELL-TAB-P | Global primary tab bar material — `Read / Learn / Cards` | V-064, A-021/A-044 | `design/tarot-deck/read-shell-translucent-tabbar-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; material also governs English and all tab roots | 2026-08-11 | `C76D9D579AD0341E95C717DD0B834A8D29A609BB70DDCFEFCA2C9AF853E1AB9D` |
| M-S03-THREE-READY-P | `S03.1 Three Cards` — ready to shuffle; info/reset; Deal disabled | V-082, A-021/A-052 | `design/tarot-deck/reading-table-three-cards-ready-to-shuffle-controls-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-12 | `AFD4E9E6333C5A304F7D4D3E976440BF2C97B1C1E15914F2FED90D5AB667D4B9` |
| M-S03-THREE-READY-L | `S03.1 Three Cards` — ready to shuffle; info/reset; Deal disabled | V-083, A-021/A-052 | `design/tarot-deck/reading-table-three-cards-ready-to-shuffle-controls-landscape-v1-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-12 | `A9C1705BCB052D7DB05C75D4290715600500812057C89BB82B5E3A05E5860E22` |
| M-S03-THREE-SHUFFLED-P | `S03.2 Three Cards` — reshuffle or Deal | V-084, A-021/A-052 | `design/tarot-deck/reading-table-three-cards-shuffled-ready-deal-controls-v3-spanish-a-ceremonial-obsidian.png` | 860×1828 | Portrait | Spanish; layout also governs English | 2026-08-12 | `008D26EC5D6D7C64237B5F333B7D99B8F250AAB97D4623AAF8F487BB4B25C547` |
| M-S03-THREE-SHUFFLED-L | `S03.2 Three Cards` — reshuffle or Deal | V-085, A-021/A-052 | `design/tarot-deck/reading-table-three-cards-shuffled-ready-deal-controls-landscape-v3-spanish-a-ceremonial-obsidian.png` | 1846×852 | Landscape | Spanish; layout also governs English | 2026-08-12 | `77AF66B4D7E537EBCFFC1B075B81FA1BA89CEC00F509BB0F743A56EE63813437` |
| M-S03-THREE-COMPLETE-DOWN-P | `S03.5 Three Cards` — layout complete, all face down and centered | V-047, A-021/A-031 | `design/tarot-deck/reading-table-three-cards-face-down-centered-spanish-a-ceremonial-obsidian.png` | 862×1825 | Portrait | Spanish; layout also governs English | 2026-08-10 | `E2218EC5FFB80986B6A72D72DD0E710F8DFBCEB8D39060637F0A49CA0C26F77E` |
| M-S03-YESNO-DOWN-P | `S03.5 Yes or No` — all face down and centered | V-067, A-021/A-045 | `design/tarot-deck/reading-table-yes-no-face-down-spanish-a-ceremonial-obsidian.png` | 862×1825 | Portrait | Spanish; layout also governs English | 2026-08-11 | `E5B084EF0D98A1E5E9A7D79F49714A8FC8A98366149D0564A813A9F95D611574` |
| M-S03-YESNO-REVEALED-P | `S03.6 Yes or No` — all revealed; no deck; info/reset | V-086, A-021/A-052 | `design/tarot-deck/reading-table-yes-no-all-revealed-info-v2-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-12 | `C295B0F6C197FFFAE23B89BE3EED2B3D888F57BF1E568500BCAF334ACB955E2B` |
| M-S03-YESNO-REVEALED-L | `S03.6 Yes or No` — all revealed; no deck; info/reset | V-087, A-021/A-052 | `design/tarot-deck/reading-table-yes-no-all-revealed-info-landscape-v2-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-12 | `580079082489E69CA459AB598A976751A8403600E46EF0C15B6272A076BED89A` |
| M-S03-FREE-DOWN-P | `S03.5 Freeform` — all face down, neutral labels | V-078, A-021/A-048 | `design/tarot-deck/reading-table-free-three-cards-face-down-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-11 | `06A7E6172BBB0118C450E70CBB7B1D0AFFF26049C8AD0DC8E65B34415B2F3F64` |
| M-S03-FREE-DOWN-L | `S03.5 Freeform` — all face down, neutral labels | V-079, A-021/A-048 | `design/tarot-deck/reading-table-free-three-cards-face-down-landscape-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-11 | `237339897355BBA5CF0B985EE5D9536A8F0444AC03C773D89A0F33CDBFE82E3B` |
| M-S03-ONE-REVEALED-P | `S03.6 One Card` — revealed, quick restart | V-056, A-021/A-033 | `design/tarot-deck/reading-table-one-card-quick-restart-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-11 | `EDFCDC1C87D5F9D32194A58B7AD2F82862DAE9080467E4B44612DC2041628BF4` |
| M-S03-ONE-REVEALED-L | `S03.6 One Card` — revealed, quick restart | V-057, A-021/A-033 | `design/tarot-deck/reading-table-one-card-quick-restart-landscape-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-11 | `B6591843EB4670CACEBE297D8D8836411C8FF9CAD52321120B6795CA1DC9A7FB` |
| M-S05-LEARN-P | `S05.1 Learn Index` — foundations with Tutorials portal | V-072, A-021/A-048 | `design/tarot-deck/learn-index-foundations-with-tutorials-spanish-a-ceremonial-obsidian.png` | 862×1825 | Portrait | Spanish; layout also governs English | 2026-08-11 | `4A189CAF9A748D7ADF91C1E5B86A79B6CD7525CF79B34A8A105BD9064A4F80C6` |
| M-S05-TUTORIALS-P | `S05.3 Reading Tutorials Index` — six methods | V-073, A-021/A-048 | `design/tarot-deck/learn-reading-tutorials-index-spanish-a-ceremonial-obsidian.png` | 862×1824 | Portrait | Spanish; layout also governs English | 2026-08-11 | `75A1B78C069CD8FB5FB5DDB7931F949BE9BDCD5AFA6D5D374F3331370B73FF28` |
| M-S06-LEARN-ARTICLE-P | `S06.1 Learn Article` — concise three-section method | V-071, A-021/A-046 | `design/tarot-deck/learn-article-yes-no-concise-spanish-a-ceremonial-obsidian.png` | 862×1824 | Portrait | Spanish; layout also governs English | 2026-08-11 | `27E00A160EC05D0B04FA704CFB3E0F712AD6A6355E29AA8967A40EC4D43F0988` |
| M-S06-READ-CONTEXT-P | `S06.2 Tutorial from active reading` — return and Previous/Next | V-088, A-021/A-052 | `design/tarot-deck/read-contextual-tutorial-yes-no-v2-spanish-a-ceremonial-obsidian.png` | 862×1825 | Portrait | Spanish; layout also governs English | 2026-08-12 | `BEB6283ED6AD8FCCCA2F5F880F1AABC10FDC743608564A8D33E200DED39D0F31` |
| M-S07-FAVORITES-EMPTY-P | `S07.3 Cards Library` — Favorites empty | V-043, A-021/A-030 | `design/tarot-deck/cards-library-favorites-empty-a-ceremonial-obsidian.png` | 854×1840 | Portrait | English | 2026-08-10 | `62AED89CC28393E7FD2BC9B06F99240D576EA61FC90F39C8511DBDBA11FFCA87` |
| M-S09-SETTINGS-P | `S09.1 Settings` — language selector | V-045, A-021/A-031 | `design/tarot-deck/settings-language-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-10 | `559D2E73882A723A24C55EBFF038CEEA9452B1CB62BD4A1C9E4ABF8E20518615` |

## A-053 approved masters (implementation pending build comparison)

| Master | Screen / state | Source approval | Path | Canvas | Orientation | Language | Approval date | SHA-256 |
|---|---|---|---|---:|---|---|---|---|
| M-S03-SIX-READY-P | `S03.7` Six-Card Guidance ready | V-091, A-021/A-053 | `design/tarot-deck/reading-table-six-card-guidance-ready-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-12 | `043F4821259B78AAD194267A23B4F40418973DC33E08CE10F1A377366AEFD7F1` |
| M-S01-CUSTOM-LIBRARY-P | `S01.4` custom library populated | V-092, A-021/A-053 | `design/tarot-deck/custom-spreads-library-populated-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-12 | `98190E49BF9635DDEA9C78C1E74B7E96CAA6D65C735E631DD2F511844F52ABA3` |
| M-S01-CUSTOM-EDITOR-P | `S01.5` custom editor with six slots | V-093, A-021/A-053 | `design/tarot-deck/custom-spread-editor-six-cards-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-12 | `AA6407E22700752161F833F3B622C64206C24F498F97AD8718A0681F57BE6B5C` |
| M-S01-CUSTOM-EMPTY-P | `S01.4` custom library empty | V-094, A-021/A-053 | `design/tarot-deck/custom-spreads-library-empty-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-12 | `5415923F62C77CE62785D8E4DDFCBA0D6519720FED7BEE44759E844B50FA0FF0` |
| M-S01-CUSTOM-ARRANGE-P | `S01.5` arrange visual sheet | V-095, A-021/A-053 | `design/tarot-deck/custom-spread-editor-arrange-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-12 | `67B73CF00C8B4C2501AD798129462570D31316AF4CCE743639237846628DD248` |
| M-S03-CUSTOM7-READY-L | `S03.8` custom seven-card table ready | V-096, A-021/A-053 | `design/tarot-deck/reading-table-custom-seven-card-landscape-v1-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-12 | `7B5626E2FCB80452010FC31B4875FB31F0185B25D731CF524473F5DCDBE76238` |

## A-054 historical masters (replaced by A-059)

| Master ID | Screen/state | Approval | Path | Canvas | Orientation | Language | Date | SHA-256 |
|---|---|---|---|---:|---|---|---|---|
| M-S03-THREE-SHUFFLED-TAP-P | `S03` Three Cards shuffled, empty positions actionable | V-097, A-021/A-054 | `design/tarot-deck/reading-table-three-cards-shuffled-tap-position-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-12 | `1CEB2D510ABB6652EF60BEC0B9984E843F3DB8B632C088430E78167D9B3FDF0B` |
| M-S03-THREE-PARTIAL-P | `S03` Three Cards partial, center chosen first | V-098, A-021/A-054 | `design/tarot-deck/reading-table-three-cards-partial-middle-first-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-12 | `A7F3B0604708E7858AD7864D2912B0436BFC0D5211436D22F35CB63A333D1481` |
| M-S03-THREE-PARTIAL-L | `S03` Three Cards partial, center chosen first | V-099, A-021/A-054 | `design/tarot-deck/reading-table-three-cards-partial-middle-first-landscape-v1-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-12 | `73BFC33AEC64E89D60932E5D4A30B59CDAFFBAD953380A56C970E7A6EADECF26` |
| M-MOTION-MANUAL-DEAL-V4 | Shuffle top-card continuity and tap-position placement | V-100, A-021/A-054 | `design/tarot-deck/reading-table-manual-placement-motion-storyboard-v4-a-ceremonial-obsidian.png` | 1672×941 | Landscape storyboard | English motion labels | 2026-08-12 | `9286DB57DAFA170C87376634289BC5F311F108CFC3F9531A5B2164067DEA25B0` |
| M-S03-SIX-PARTIAL-P | `S03` Six-Card Guidance partial, Action chosen first | V-101, A-021/A-054 | `design/tarot-deck/reading-table-six-card-partial-action-first-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-12 | `EE3D40472A08DD8878C403AE022C233879F1740C626230216337F7BB11B203D5` |
| M-S03-CUSTOM7-PARTIAL-L | `S03` Custom seven-card partial | V-102, A-021/A-054 | `design/tarot-deck/reading-table-custom-seven-partial-v1-landscape-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-12 | `805ED5688AEF2E5C5841DEEF8539C4FBF8D59226E6BC3825F2224EFAFDA9878E` |

V-097–V-102 remain preserved as the A-054 historical record. A-059 replaces their conflicting shuffle availability, deck visibility and complete-state behavior through V-108–V-119.

## A-055 historical masters (replaced where A-059 changes the table)

| Master ID | Screen/state | Approval | Path | Canvas | Orientation | Language | Date | SHA-256 |
|---|---|---|---|---:|---|---|---|---|
| M-S03-THREE-SHUFFLED-COMPACT-L | Three Cards shuffled, compact landscape | V-103, A-021/A-055 | `design/tarot-deck/reading-table-three-card-shuffled-compact-landscape-v1-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-12 | `0F8A809716E64A3B2EF6F177CE2FAFD676A8413F903C8EAF9F01F4960B69EB20` |
| M-S03-THREE-PARTIAL-COMPACT-L | Three Cards partial, shared geometry | V-104, A-021/A-055 | `design/tarot-deck/reading-table-three-card-partial-compact-landscape-v1-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-12 | `245B43A48017D8DDBC7D1F2CEECF1FF6EC94F3B0D0058FF3AF3C99E4F79929D5` |
| M-S03-THREE-COMPLETE-COMPACT-L | Three Cards complete face down, shared geometry | V-105, A-021/A-055 | `design/tarot-deck/reading-table-three-card-complete-compact-landscape-v1-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish; layout also governs English | 2026-08-12 | `8551828AD92F4661C73011147F66080596B818A2DF0EEFB334260B33363F05B8` |
| M-S03-MULTI-ORIENTATION-HINT-P | Multi-card portrait orientation recommendation | V-106, A-021/A-055 | `design/tarot-deck/reading-table-three-card-portrait-orientation-hint-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout also governs English | 2026-08-12 | `1C3286E78D7E55FEDC6ADE3F9917B9793589739A33B3AAE9A2AC99FA4DB0C47A` |

V-103–V-106 remain preserved. A-059 replaces their table composition and orientation-hint behavior, while retaining the shared-slot geometry and minimum 14-point visible gap.

## A-059 current Reading Table masters

| Master ID | Screen/state | Approval | Path | Canvas | Orientation | Language | Date | SHA-256 |
|---|---|---|---|---:|---|---|---|---|
| M-S03-AUTO-SHUFFLE-P-ES | New/reset reading; automatic shuffle | V-108, A-021/A-059 | `design/tarot-deck/reading-table-auto-shuffle-entry-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish | 2026-08-13 | `E7D657FB3B9110F73FD4A71573B72FD83D5692176815B1F943A6BE0AC1CC86C3` |
| M-S03-AUTO-SHUFFLE-P-EN | New/reset reading; automatic shuffle | V-109, A-021/A-059 | `design/tarot-deck/reading-table-auto-shuffle-entry-v1-english-a-ceremonial-obsidian.png` | 853×1844 | Portrait | English | 2026-08-13 | `1A2CF3136E6E5B8A72002539774411DFB3EE1FCB63CD4627D5011D32D57D11D1` |
| M-S03-PERSISTENT-EMPTY-P-ES | Empty layout; persistent deck and Shuffle | V-110, A-021/A-059 | `design/tarot-deck/reading-table-persistent-deck-steady-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish | 2026-08-13 | `577EFC738E85766E3AF648352D2CA3D9EDDBA223C73B618C116A2257EEDD553A` |
| M-S03-PERSISTENT-EMPTY-P-EN | Empty layout; persistent deck and Shuffle | V-111, A-021/A-059 | `design/tarot-deck/reading-table-persistent-deck-steady-v1-english-a-ceremonial-obsidian.png` | 853×1844 | Portrait | English | 2026-08-13 | `32D125B93F749D7DED06E00FEE03D60DCFE0B2209168E3DF168B896EF5D317A2` |
| M-S03-PERSISTENT-PARTIAL-P-ES | Partial placement; persistent deck | V-112, A-021/A-059 | `design/tarot-deck/reading-table-persistent-deck-partial-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish | 2026-08-13 | `F9F0D347689A708672D9C628CE8E8C68A344CEE9FFE7AF1D123E8AAABCDA5F9D` |
| M-S03-PERSISTENT-PARTIAL-P-EN | Partial placement; persistent deck | V-113, A-021/A-059 | `design/tarot-deck/reading-table-persistent-deck-partial-v1-english-a-ceremonial-obsidian.png` | 853×1844 | Portrait | English | 2026-08-13 | `A3C2023073C780F2099AD23BD17AF362E9D2B4BA45C11FB205FE907FFE564FBD` |
| M-S03-PERSISTENT-COMPLETE-P-ES | Complete layout; persistent deck | V-114, A-021/A-059 | `design/tarot-deck/reading-table-persistent-deck-complete-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish | 2026-08-13 | `78F8F91E8C00B2BC736E0D057EDF12AF0B1216E4FCB20B986C68E3ACFC83F37E` |
| M-S03-PERSISTENT-COMPLETE-P-EN | Complete layout; persistent deck | V-115, A-021/A-059 | `design/tarot-deck/reading-table-persistent-deck-complete-v1-english-a-ceremonial-obsidian.png` | 853×1844 | Portrait | English | 2026-08-13 | `8E8766CF7BEB31290388028251E89ABB39CAAD25994B9B071CE44612851E87EF` |
| M-S03-PERSISTENT-EMPTY-L-ES | Empty layout; raised compact landscape header | V-116, A-021/A-059 | `design/tarot-deck/reading-table-persistent-deck-steady-compact-landscape-v1-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish | 2026-08-13 | `B0FD82215F73CE687E83D3A7AB95BAFA5EE8D802091B911F1C487927DD25990C` |
| M-S03-PERSISTENT-EMPTY-L-EN | Empty layout; raised compact landscape header | V-117, A-021/A-059 | `design/tarot-deck/reading-table-persistent-deck-steady-compact-landscape-v1-english-a-ceremonial-obsidian.png` | 1844×853 | Landscape | English | 2026-08-13 | `40C4B0402890442A352B830AD5021C0BA4EBC8FC5F6C3C656E8A24D107AAADFA` |
| M-S03-PERSISTENT-COMPLETE-L-ES | Complete layout; persistent deck and raised compact header | V-118, A-021/A-059 | `design/tarot-deck/reading-table-persistent-deck-complete-compact-landscape-v1-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish | 2026-08-13 | `1CD5C0758FCC63A97E0DCD04860950A7EC0D23CFE3D4542D2746734FD360F196` |

V-108–V-118 are the current complete Reading Table masters for A-059. They replace conflicting no-deck, manual-entry-shuffle and landscape-rail behavior in V-086/V-087/V-097–V-106. The persistent deck, small independent Shuffle control, no-dimming presentation and temporary orientation hint are mandatory; stable slot geometry and the ≥14-point visible gap remain inherited requirements.

## A-060 current selector and Cards Library masters

| Master ID | Screen/state | Approval | Path | Canvas | Orientation | Language | Date | SHA-256 |
|---|---|---|---|---:|---|---|---|---|
| M-S01-KIND4-P | `S01.2` four reading kinds; 22-point visible information controls | V-120, A-021/A-060 | `design/tarot-deck/read-home-reading-kind-selector-info-extra-small-v4-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout governs English | 2026-08-13 | `4856C7C92510D702195472E0D8E147E38AC6C9338C59C82F93FA433F83E07E60` |
| M-S01-STYLE-P | `S01.3` five styles; 22-point visible information controls | V-121, A-021/A-060 | `design/tarot-deck/read-home-three-card-style-selector-info-extra-small-v5-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout governs English | 2026-08-13 | `1981978F24B52E61B5F9F0D5FC958AEA50BD4781FFF9F31E4C7A4C0B1B25BDEC` |
| M-S07-ALL-P | `S07.1` Cards Library; discoverable horizontal categories | V-122, A-021/A-060 | `design/tarot-deck/cards-library-filter-scroll-affordance-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout governs English | 2026-08-13 | `92FEF9B73F8A4AC4DBBF86993F4A0A253A381047042A1027249F14628CF24D4A` |

V-120–V-122 are the current masters for the changed surfaces. V-107 and V-081 remain historical selector references; V-022 remains the historical Cards Library reference.

## Approved but not active in the current build

| Reference | Planned screen / state | Status | Path | Canvas | Orientation | Language | Approval date | SHA-256 |
|---|---|---|---|---:|---|---|---|---|
| V-027 | `S10.1 Support the App` — not active | `APPROVED, NOT ACTIVE`; StoreKit products, live prices, contracts and purchase flow remain unauthorized | `design/tarot-deck/support-the-app-a-ceremonial-obsidian-v2.png` | 853×1844 | Portrait | English | 2026-08-09 | `12411E9486B44B619F438669CEA04143EDDBCC0967F85758C0D5277E5ACD6C7A` |

## Approved supporting specification, not a screen master

| Reference | Purpose | Status | Path | Canvas | Date | SHA-256 |
|---|---|---|---|---:|---|---|
| V-119 | Reading Table auto/repeated shuffle, direct placement and persistent-deck storyboard | `CURRENT SUPPORTING SPEC`; governs A-059 motion and interaction, but is not a complete app screen or store capture | `design/tarot-deck/reading-table-auto-shuffle-persistent-deck-motion-storyboard-v5-a-ceremonial-obsidian.png` | 1672×941 | 2026-08-13 | `F5BCE2191D0188CD171BCD2B8915517B8A67ABA9D5348FAAD2B35A721243DF31` |

## Replacement ledger

The files below remain preserved, but none is current. A replacement can govern only the same state it actually depicts; when no exact replacement exists, the state is listed under coverage gaps instead of promoting a different image.

| Replaced / retired reference | Historical surface | Replacement or disposition |
|---|---|---|
| V-001, V-004 | Daily Tarot screens | Historical product only after A-014; no Tarot Deck master. |
| V-013 | Read Home, empty | Replaced by V-024, then V-044, V-054, and current V-058/V-061. |
| V-014 | Separate Layout Choice | Retired by A-033; current progressive visual selector V-058–V-063 owns preset selection. |
| V-005–V-012, V-015/V-018 | Earlier Three Cards table states | V-082–V-087 replace ready, shuffled and complete states. V-047 remains the current face-down geometry reference where not materially changed. Separate draw buttons, `End Reading` and the reappearing deck are retired. |
| V-019, V-023, V-042 | Card meaning/detail states | A-031 makes `Upright / Al derecho` a plain editorial heading, not the pill shown in these images. No exact replacement master is registered. |
| V-020, V-021 | Learn index/article | V-020 was replaced by V-070 and then current V-072, which restores its hierarchy with concise copy and a Tutorials portal. V-021 remains replaced by V-071 for article structure. |
| V-022 | Cards Library / All without an explicit horizontal-scroll affordance | Replaced by current V-122; V-043 remains current for Favorites empty. |
| V-024 | Read Home with Settings access | Replaced by V-044, V-054, and current V-058/V-061. |
| V-025 | Settings | Replaced by current V-045 with the internal language selector. |
| V-026 | Support the App | Replaced by V-027; V-027 remains approved but inactive. |
| V-028 | Active-reading Home | Retired by A-033; restoration returns directly to the table and Home uses V-058–V-063. |
| V-029–V-038 | Earlier One Card ready, shuffled, face-down and revealed states | Their card scale remains reference where applicable, but A-054 replaces draw/Deal behavior with shuffle, tap-position placement and reset. |
| V-039 | Separate Three Cards spread choice | Retired by A-033; preset selection now uses current V-058–V-063. |
| V-040, V-052/V-053, V-056/V-057, V-068/V-069 | Complete tables with quick-restart deck | Replaced behaviorally by V-086/V-087 and A-054: after the final placement the deck never reappears; reset is the only quick restart. |
| V-041, V-048, V-089, V-100 | Earlier Reading Table motion storyboards | Replaced by current V-119 and `design/tarot-deck/MOTION_SPEC.md`. |
| V-086/V-087, V-097–V-106 | Complete no-deck, manual-entry-shuffle, partial placement, compact landscape and persistent-hint table states | Replaced in conflicting A-059 aspects by current V-108–V-118. Preserved as historical references. |
| V-044 | Read Home compact deck CTA | Replaced by V-054 and then current V-058/V-061. |
| V-049, V-050 | Home dropdown, portrait closed/open | Rejected as a vertical text selector; later V-054 was also replaced by current V-058–V-060. |
| V-051 | Home dropdown, landscape | Replaced by V-055 and then current V-061–V-063. |
| V-054, V-055 | Home visual preset carousel, portrait/landscape | Replaced by V-058–V-063 after owner QA: the carousel occupied too much permanent space and made the deck too small. Preserved as historical references. |
| V-060, V-063 | Home three-card style selector with `Open reading / Tirada abierta` | Replaced by current V-065/V-066 after A-045 made the documented Yes or No spread the fifth preset. |
| V-059, V-062 | Home one/three selector without information | Replaced by current V-074/V-075. |
| V-065, V-066 | Home four-style selector with Yes or No | Replaced by current V-076/V-077 after A-048 added Freeform and tutorial information actions. |
| V-070 | Learn index with all tutorials flattened | Replaced by current V-072; V-073 now owns the separate tutorial collection. |
| V-080/V-081, V-107 | Earlier selector masters with larger visible information controls | Replaced by current V-120/V-121. V-120 preserves V-107's exact Six Cards glyph and Three Cards default. |

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
