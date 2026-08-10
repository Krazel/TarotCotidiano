# Visual Approval Register

Updated: 2026-08-10

> Historical scope notice: the owner replaced Daily Tarot with the Tarot Deck product on 2026-08-09. The approvals below remain valid records of the former product and visual language, but they do not authorize implementation of any Tarot Deck screen. New approvals are tracked from `S03.2` onward in `design/TAROT_DECK_VISUAL_BRIEF.md` and `DECISIONS.md`.

## Daily Card — revealed

- Direction: A — Ceremonial Obsidian.
- Image: `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\concepts\daily-card-a-ceremonial-obsidian.png`
- Approved: 2026-08-08.
- Requested changes: none.
- Status: definitive; do not reopen.
- Scope: revealed `Daily Card` only.

## Today / Daily Card — unrevealed

- Direction: A — Ceremonial Obsidian.
- Image: `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\concepts\today-unrevealed-a-ceremonial-obsidian.png`
- SHA-256: `48B53E8A64857206771224D90155603944283DC829C0829161AD6EBE1BB209F9`
- Approved: 2026-08-08.
- Approval statement: owner explicitly answered yes and instructed implementation to begin.
- Requested changes: none.
- Accessibility adaptations allowed: safe-area adjustments, Dynamic Type, VoiceOver labels and hints, contrast corrections, minimum 44-point touch targets, SF Symbols, and Reduced Motion behavior, while preserving hierarchy, palette, proportions, copy, and ceremonial character.
- Scope: unrevealed `Today / Daily Card` only.

## Current implementation boundary

The two historical Daily Tarot approvals no longer open an implementation task because their product flow was superseded. Tarot Deck S03.2–S03.4 are authorized under A-017/A-018/A-019 and implemented in the provisional iOS target. S03.5 and every later state remain closed until their own complete images receive explicit approval.

## Tarot Deck — S03.2 three-card table, shuffled

- Direction: A — Ceremonial Obsidian.
- Image: `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-shuffled-a-ceremonial-obsidian.png`
- Dimensions: 863×1823.
- SHA-256: `2469CA34B3BEC37AD56E5D3E46891EE3CDE0252BEFB0212F24AE1B6002996F68`.
- Generated: 2026-08-09 with the built-in image generation tool, using the two historical Ceremonial Obsidian screens as style references.
- Status: **approved under A-017 on 2026-08-09**.
- Owner response: `PERF, SIGUE` after reviewing portrait and landscape together.
- Scope if approved: `S03.2 Reading Table — Three Cards / shuffled / no card drawn` only.
- Implementation boundary: structural engine/data/tests may proceed under A-016; final SwiftUI layout, art treatment and principal motion remain blocked.

## Tarot Deck — S03.2 three-card table, shuffled, landscape

- Direction: A — Ceremonial Obsidian.
- Image: `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-shuffled-landscape-a-ceremonial-obsidian.png`
- Dimensions: 1844×853.
- SHA-256: `5F4E1ED763806AC3CD436B0DE8D0B70AE5CD24A58E569BDCB4A170452692D553`.
- Generated: 2026-08-09 with the built-in image generation tool, using the portrait S03.2 candidate and historical Ceremonial Obsidian screen as references.
- Status: **approved under A-017 on 2026-08-09**.
- Scope if approved: responsive landscape companion for `S03.2` only.
- Implementation boundary: does not approve any revealed-card state, final motion, icon, store capture or other screen.

## Tarot Deck — S03.3 first card drawn face down, portrait

- Image: `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-first-drawn-face-down-a-ceremonial-obsidian.png`
- Dimensions: 863×1823.
- SHA-256: `806C422F6C0941C2F23965B5ACD5B7DA88DF5AFE144CFA13F798E054E1C9E601`.
- Status: **approved under A-018 on 2026-08-09**.
- Scope if approved: S03.3 portrait only as part of a responsive pair.

## Tarot Deck — S03.3 first card drawn face down, landscape

- Image: `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-first-drawn-face-down-landscape-a-ceremonial-obsidian.png`
- Dimensions: 1844×853.
- SHA-256: `0D78321B380A876DA58D4EBC1FE3D168048C4BF0638909B8CAE0C09352C135D4`.
- Status: **approved under A-018 on 2026-08-09**.
- Scope if approved: S03.3 landscape only as part of a responsive pair.

## Tarot Deck — S03.4 mixed reveal, portrait

- Direction: A — Ceremonial Obsidian.
- Image: `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-mixed-the-moon-a-ceremonial-obsidian.png`
- Dimensions: 863×1823.
- SHA-256: `C73EDB6E46CA9032A812528FDA75E6247470647179ECEA2C3C6607BA8B3E6B2D`.
- Generated: 2026-08-09 with the built-in image generation tool, using the approved S03.2/S03.3 layouts, approved Ceremonial Obsidian card back, and the locally verified historical TaionWC `The Moon` candidate as references.
- Status: **approved under A-019 on 2026-08-09**.
- Owner response: `perfecto` after reviewing portrait and landscape together.
- Scope if approved: S03.4 portrait only as part of the responsive pair: position one revealed as `The Moon`, position two face down, position three empty, and `Draw Final Card`.
- Boundary: no interpretation, reversed meaning, daily framing, final motion, icon, store capture, or other state is approved by this proposal.

## Tarot Deck — S03.4 mixed reveal, landscape

- Direction: A — Ceremonial Obsidian.
- Image: `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-mixed-the-moon-landscape-a-ceremonial-obsidian.png`
- Dimensions: 1844×853.
- SHA-256: `DEDA9F1B6E88E91620D1C3B8EA52CFA1C0D7BE09D235C823A6F1BD91DF39A0BC`.
- Generated: 2026-08-09 with the built-in image generation tool from the same approved and verified references as V-009.
- Status: **approved under A-019 on 2026-08-09**.
- Owner response: `perfecto` after reviewing portrait and landscape together.
- Scope if approved: S03.4 landscape only as part of the responsive pair.
- Recommendation: approve V-009 and V-010 together so portrait and landscape remain two presentations of one interaction state.

## Tarot Deck — S03.5 complete layout with mixed faces, portrait

- Direction: A — Ceremonial Obsidian.
- Image: `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-complete-mixed-the-moon-a-ceremonial-obsidian.png`
- Dimensions: 863×1823.
- SHA-256: `E7A63D1EBEE8E81F662A59C31DFDE733806B846D3C9627035219B8A2BEA0C24A`.
- Generated: 2026-08-09 with the built-in image generation tool by editing the approved S03.4 responsive system.
- Status: **approved under A-021 on 2026-08-09**.
- Owner response: `sí, lo apruebo todo` after reviewing V-011/V-012; standing approval also applies to subsequent MVP images generated by this project brain.
- Scope if approved: S03.5 portrait only as part of the responsive pair: all three positions occupied, `The Moon` revealed first, positions two and three face down, no remaining deck and no draw action.

## Tarot Deck — S03.5 complete layout with mixed faces, landscape

- Direction: A — Ceremonial Obsidian.
- Image: `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-complete-mixed-the-moon-landscape-a-ceremonial-obsidian.png`
- Dimensions: 1844×853.
- SHA-256: `2725EF3242260FCBBA1277E59D90DDB8599ABEA1FC74E58CB60ECB80D8D66BD4`.
- Generated: 2026-08-09 with the built-in image generation tool by editing the approved S03.4 landscape composition.
- Status: **approved under A-021 on 2026-08-09**.
- Owner response: `sí, lo apruebo todo` after reviewing V-011/V-012.
- Scope if approved: S03.5 landscape only as part of the responsive pair.
- Recommendation: approve V-011 and V-012 together; completing the spread removes the deck and draw action while preserving independent reveal control.

## Standing approval — expanded MVP

On 2026-08-09 the owner approved V-011/V-012 and explicitly authorized subsequent MVP illustrations created by the project brain. Under A-021 each complete in-scope image below is approved on generation and registration; visual-first still requires the image to exist before implementation.

| ID | Surface | Image | Status |
|---|---|---|---|
| V-013 | Read Home, empty | `design/tarot-deck/read-home-empty-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-014 | Layout Choice | `design/tarot-deck/layout-choice-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-015 | Three Cards, ready to shuffle, portrait | `design/tarot-deck/reading-table-three-cards-ready-to-shuffle-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-016 | Three Cards, ready to shuffle, landscape | `design/tarot-deck/reading-table-three-cards-ready-to-shuffle-landscape-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-017 | Three Cards, all revealed, portrait | `design/tarot-deck/reading-table-three-cards-all-revealed-hermit-moon-sun-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-018 | Three Cards, all revealed, landscape | `design/tarot-deck/reading-table-three-cards-all-revealed-hermit-moon-sun-landscape-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-019 | Meaning from reading | `design/tarot-deck/card-detail-the-moon-meaning-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-020 | Learn Index | `design/tarot-deck/learn-index-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-021 | Learn Article | `design/tarot-deck/learn-article-read-three-cards-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-022 | Cards Library / All | `design/tarot-deck/cards-library-all-a-ceremonial-obsidian-v2.png` | Approved by A-021; the earlier search variant is not the target. |
| V-023 | Card Detail from library | `design/tarot-deck/card-detail-library-the-moon-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-024 | Read Home with Settings access | `design/tarot-deck/read-home-empty-settings-a-ceremonial-obsidian.png` | Approved by A-021; supersedes V-013. |
| V-025 | Settings | `design/tarot-deck/settings-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-026 | Support the app, not active | `design/tarot-deck/support-the-app-a-ceremonial-obsidian.png` | Approved visually by A-021; prices are illustrative and StoreKit setup remains unauthorized. |
| V-027 | Support the app, launch-skill copy | `design/tarot-deck/support-the-app-a-ceremonial-obsidian-v2.png` | Approved by A-021; supersedes V-026, while prices remain illustrative and StoreKit setup unauthorized. |
| V-028 | Read Home, active Three Cards reading | `design/tarot-deck/read-home-active-three-cards-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-029 | One Card ready, portrait | `design/tarot-deck/reading-table-one-card-ready-to-shuffle-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-030 | One Card ready, landscape | `design/tarot-deck/reading-table-one-card-ready-to-shuffle-landscape-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-031 | One Card shuffled, portrait | `design/tarot-deck/reading-table-one-card-shuffled-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-032 | One Card shuffled, landscape | `design/tarot-deck/reading-table-one-card-shuffled-landscape-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-033 | One Card drawn face down, portrait | `design/tarot-deck/reading-table-one-card-drawn-face-down-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-034 | One Card drawn face down, landscape | `design/tarot-deck/reading-table-one-card-drawn-face-down-landscape-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-035 | One Card The Hermit revealed, portrait | `design/tarot-deck/reading-table-one-card-revealed-the-hermit-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-036 | One Card The Hermit revealed, landscape | `design/tarot-deck/reading-table-one-card-revealed-the-hermit-landscape-a-ceremonial-obsidian.png` | Approved by A-021. |
| V-037 | One Card drawn face down, portrait, complete layout | `design/tarot-deck/reading-table-one-card-drawn-face-down-a-ceremonial-obsidian-v2.png` | Approved by A-021; supersedes V-033 and removes the remaining deck. |
| V-038 | One Card drawn face down, landscape, complete layout | `design/tarot-deck/reading-table-one-card-drawn-face-down-landscape-a-ceremonial-obsidian-v2.png` | Approved by A-021; supersedes V-034 and removes the remaining deck. |
| V-039 | Three Cards spread choice, Spanish | `design/tarot-deck/three-card-spread-choice-spanish-a-ceremonial-obsidian-v2.png` | Approved by A-021/A-027/A-028; 862×1824; SHA-256 `B6496DF1318B31B268A477D7129C933D6BAC1CD0281DFB8F1C221FF0F90590AD`. The English version uses the same composition. |
| V-040 | Three Cards large landscape, Spanish | `design/tarot-deck/reading-table-three-cards-large-landscape-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-027/A-028; 1844×853; SHA-256 `13B682D552E58B6D662B140F77A999FB8555A4C79EE386C981E9810AD45F941B`. Supersedes prior Three Cards landscape proportions. |
| V-041 | Reading Table motion storyboard | `design/tarot-deck/reading-table-motion-storyboard-a-ceremonial-obsidian.png` | Approved by A-021/A-029; 1774×887; SHA-256 `30D49233D041893FAC2783D72F90A9C737BA49F74A25EE547EC022D31CBC3E64`. Defines rest, shuffle, draw and reveal keyframes; implementation follows `design/tarot-deck/MOTION_SPEC.md`. |
| V-042 | Card Detail, favorite saved | `design/tarot-deck/card-detail-library-favorite-saved-a-ceremonial-obsidian.png` | Approved by A-021/A-030; 862×1824; SHA-256 `5794D4C345BAF1BB52F783DE9C3D49D7D64DAA31BDA4083770AF3E2B8A957389`. |
| V-043 | Cards, Favorites empty | `design/tarot-deck/cards-library-favorites-empty-a-ceremonial-obsidian.png` | Approved by A-021/A-030; 854×1840; SHA-256 `62AED89CC28393E7FD2BC9B06F99240D576EA61FC90F39C8511DBDBA11FFCA87`. |
| V-044 | Read Home, compact deck CTA, Spanish | `design/tarot-deck/read-home-compact-deck-cta-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-031; 864×1821; SHA-256 `392546D9B7B676E8348B42000206070ACDA5753867AED635DBC8C60C80619E5E`. Supersedes V-024 for empty Home; English uses the same composition. |
| V-045 | Settings with language selector, Spanish | `design/tarot-deck/settings-language-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-031; 853×1844; SHA-256 `559D2E73882A723A24C55EBFF038CEEA9452B1CB62BD4A1C9E4ABF8E20518615`. Supersedes V-025. |
| V-046 | Three Cards ready, deck tap, Spanish | `design/tarot-deck/reading-table-three-cards-deck-tap-ready-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-031; corrected 2026-08-10 to show `Pasado / Presente / Futuro` and the shared fixed slot anchor; 861×1827; SHA-256 `C05A106C77884EEA07C28B5E2BA677875F678E4FAD5F97AAAAF553D636082BBD`. Supersedes V-015 portrait interaction. |
| V-047 | Three Cards, all face down and centered, Spanish | `design/tarot-deck/reading-table-three-cards-face-down-centered-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-031; corrected 2026-08-10 so the three labelled cards retain V-046's exact horizontal group and vertical slot anchor after the deck disappears; 862×1825; SHA-256 `E2218EC5FFB80986B6A72D72DD0E710F8DFBCEB8D39060637F0A49CA0C26F77E`. |
| V-048 | Professional reading motion V2 | `design/tarot-deck/reading-table-professional-motion-storyboard-v2-a-ceremonial-obsidian.png` | Approved by A-021/A-031; 1672×941; SHA-256 `937F89E3DF7D2161E6AD2C835A4201135161E6ADED083A4BE52B8773A58190F0`. Supersedes V-041. |

Accessibility adaptations remain allowed: safe areas, Dynamic Type, VoiceOver, contrast, 44-point targets, Reduced Motion and native scrolling, while preserving hierarchy, copy and Ceremonial Obsidian character.
