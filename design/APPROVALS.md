# Visual Approval Register

Updated: 2026-08-10

> Historical scope notice: the owner replaced Daily Tarot with the Tarot Deck product on 2026-08-09. The approvals below remain valid records of the former product and visual language, but they do not authorize implementation of any Tarot Deck screen. New approvals are tracked from `S03.2` onward in `design/TAROT_DECK_VISUAL_BRIEF.md` and `DECISIONS.md`.

> Current implementation masters are consolidated in [`design/SCREEN_MASTERS.md`](SCREEN_MASTERS.md); this file remains the approval-history register.

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
| V-026 | Support the app, not active | `design/tarot-deck/support-the-app-a-ceremonial-obsidian.png` | Historical; illustrative prices and inactive StoreKit were replaced by V-133/V-134. |
| V-027 | Support the app, launch-skill copy | `design/tarot-deck/support-the-app-a-ceremonial-obsidian-v2.png` | Historical; replaced by the seven-level live-price V-133/V-134 surface. |
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

| V-058 | Read Home compact selector, portrait | `design/tarot-deck/read-home-compact-selector-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-042; 853×1844; SHA-256 `9C0D453917EFC6D16DE3A6013E6B3BD3F45949F48D229F688C77A26E6FAA0C29`; replaces V-054. |
| V-059 | Read Home one/three card selector, portrait | `design/tarot-deck/read-home-reading-count-selector-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-042; 853×1844; SHA-256 `07C576509A7D1EAD797AEC45F70E4BE9846104CBBC439473FF92DE57EA6B02A4`. |
| V-060 | Read Home three-card style selector, portrait | `design/tarot-deck/read-home-three-card-style-selector-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-042; 853×1844; SHA-256 `27C88125F761A813EF3D69FCFFF8D63CD70AE9688B7B0E4CA1CC871250BCC33F`. |
| V-061 | Read Home compact selector, landscape | `design/tarot-deck/read-home-compact-selector-landscape-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-042; 1844×853; SHA-256 `C1E3AB1BCBC9E8F15E1D19D1C0E1F6BC51A85CF23D5A8A4C00BFF05F5E67879D`; replaces V-055. |
| V-062 | Read Home one/three card selector, landscape | `design/tarot-deck/read-home-reading-count-selector-landscape-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-042; 1844×853; SHA-256 `E8DC2B15607B4E7F762B12F76BFAB7DDA6D51C40125D9692885CB4DBA4BD5973`. |
| V-063 | Read Home three-card style selector, landscape | `design/tarot-deck/read-home-three-card-style-selector-landscape-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-042; 1844×853; SHA-256 `9E984B16F97181A8189CF851E66F94667394600F212BE0BF34BBE2701D62A944`. |
| V-065 | Read Home three-card style selector with Yes or No, portrait | `design/tarot-deck/read-home-three-card-style-selector-yes-no-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-045; 853×1844; SHA-256 `96B3F2DF08B1668AAB57219904C91C87851E37F76B6290AC7CF70B3DC787E071`; supersedes V-060. |
| V-066 | Read Home three-card style selector with Yes or No, landscape | `design/tarot-deck/read-home-three-card-style-selector-yes-no-landscape-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-045; 1844×853; SHA-256 `04316D9C557A8E530BFC622FC31158F6AF5AC9DB9D4466779C2D0302B1FFD0F7`; supersedes V-063. |
| V-067 | Yes or No table, all face down, portrait | `design/tarot-deck/reading-table-yes-no-face-down-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-045; 862×1825; SHA-256 `E5B084EF0D98A1E5E9A7D79F49714A8FC8A98366149D0564A813A9F95D611574`. |
| V-068 | Yes or No table, all revealed, portrait | `design/tarot-deck/reading-table-yes-no-all-revealed-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-045; 853×1844; SHA-256 `96A99F433CB0AC959AF43DABFA78F935B8263CC19D61DC20407EA2F2E82FE7C9`. |
| V-069 | Yes or No table, all revealed, landscape | `design/tarot-deck/reading-table-yes-no-all-revealed-landscape-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-045; 1846×852; SHA-256 `EB02233108B1CAEAAB77FDFF5EE2D4242930F7671FE6CE14F6F7D09866E8E24D`. |
| V-070 | Learn index, unified tutorials, Spanish | `design/tarot-deck/learn-index-tutorials-unified-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-046; 862×1824; SHA-256 `737A04E2AFC027B7A7AAE2EB48700C721DF3666196CCD6E3AE31A2A38595E03C`; supersedes V-020. |
| V-071 | Learn article, concise Yes or No, Spanish | `design/tarot-deck/learn-article-yes-no-concise-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-046; 862×1824; SHA-256 `27E00A160EC05D0B04FA704CFB3E0F712AD6A6355E29AA8967A40EC4D43F0988`; supersedes V-021. |

A-050 preserves the compositions of V-067/V-068/V-069 and V-071 but supersedes their visible `Outcome / Resultado` wording with runtime copy `Destiny / Destino`. No layout, asset, motion or hierarchy changes; localized production copy is authoritative for this correction.

A-051 preserves the compositions of the existing Read selector and concise Learn article but supersedes the short Situation/Challenge/Guidance summary with purpose-led runtime copy. No layout, asset, motion or hierarchy changes; localized production copy is authoritative for this correction.
| V-072 | Learn index, foundations with Tutorials portal, Spanish | `design/tarot-deck/learn-index-foundations-with-tutorials-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-048; 862×1825; SHA-256 `4A189CAF9A748D7ADF91C1E5B86A79B6CD7525CF79B34A8A105BD9064A4F80C6`; supersedes V-070 for Learn Index. |
| V-073 | Reading Tutorials index, Spanish | `design/tarot-deck/learn-reading-tutorials-index-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-048; 862×1824; SHA-256 `75A1B78C069CD8FB5FB5DDB7931F949BE9BDCD5AFA6D5D374F3331370B73FF28`. |
| V-074 | Read Home one/three card selector with information, portrait | `design/tarot-deck/read-home-reading-count-selector-info-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-048; 853×1844; SHA-256 `8AD118426B2D1B7BDA0F00F4012EF59DF85A2152791510F4E8BC41BDFAECA576`; supersedes V-059. |
| V-075 | Read Home one/three card selector with information, landscape | `design/tarot-deck/read-home-reading-count-selector-info-landscape-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-048; 1844×853; SHA-256 `77BCD0B4FA279E5A92E18D2B27B1E332E3788E5412B0EEE3BE7E28B515EAE943`; supersedes V-062. |
| V-076 | Read Home five-style selector with information, portrait | `design/tarot-deck/read-home-three-card-style-selector-free-info-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-048; 853×1844; SHA-256 `95057F7A6F6BAE859088D7D2EE806130EFBB88B8635A05DADDD455466DD6E503`; supersedes V-065. |
| V-077 | Read Home five-style selector with information, landscape | `design/tarot-deck/read-home-three-card-style-selector-free-info-landscape-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-048; 1844×853; SHA-256 `B8F5598D312B7587CE31A2F3D86AD92246A4FB7DB0546E8A305B4701CF192FBE`; supersedes V-066. |
| V-078 | Freeform table, all face down, portrait | `design/tarot-deck/reading-table-free-three-cards-face-down-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-048; 853×1844; SHA-256 `06A7E6172BBB0118C450E70CBB7B1D0AFFF26049C8AD0DC8E65B34415B2F3F64`. |
| V-079 | Freeform table, all face down, landscape | `design/tarot-deck/reading-table-free-three-cards-face-down-landscape-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-048; 1844×853; SHA-256 `237339897355BBA5CF0B985EE5D9536A8F0444AC03C773D89A0F33CDBFE82E3B`. |
| V-080 | Read Home one/three selector, smaller information control | `design/tarot-deck/read-home-reading-count-selector-info-small-v2-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-052; 853×1844; SHA-256 `8FFA3087C0AE2102C3E138926242AFA7EE6E1A802C730037375B84B0603D46E5`; supersedes V-074 portrait. |
| V-081 | Read Home five-style selector, compact grid and neutral state | `design/tarot-deck/read-home-three-card-style-selector-grid-five-neutral-v4-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-052; 853×1844; SHA-256 `5A5B0D1F6206C6F0575646F44BB11991D5AC1C397DCDEDFD4D1E9342F0E87230`; supersedes V-076 portrait. |
| V-082 | Three Cards ready to shuffle with info/reset, portrait | `design/tarot-deck/reading-table-three-cards-ready-to-shuffle-controls-v1-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-052; 853×1844; SHA-256 `AFD4E9E6333C5A304F7D4D3E976440BF2C97B1C1E15914F2FED90D5AB667D4B9`; Deal is disabled. |
| V-083 | Three Cards ready to shuffle with info/reset, landscape | `design/tarot-deck/reading-table-three-cards-ready-to-shuffle-controls-landscape-v1-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-052; 1844×853; SHA-256 `A9C1705BCB052D7DB05C75D4290715600500812057C89BB82B5E3A05E5860E22`. |
| V-084 | Three Cards shuffled, reshuffle or Deal, portrait | `design/tarot-deck/reading-table-three-cards-shuffled-ready-deal-controls-v3-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-052; 860×1828; SHA-256 `008D26EC5D6D7C64237B5F333B7D99B8F250AAB97D4623AAF8F487BB4B25C547`. |
| V-085 | Three Cards shuffled, reshuffle or Deal, landscape | `design/tarot-deck/reading-table-three-cards-shuffled-ready-deal-controls-landscape-v3-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-052; 1846×852; SHA-256 `77AF66B4D7E537EBCFFC1B075B81FA1BA89CEC00F509BB0F743A56EE63813437`. |
| V-086 | Yes or No complete, no deck, contextual info, portrait | `design/tarot-deck/reading-table-yes-no-all-revealed-info-v2-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-052; 853×1844; SHA-256 `C295B0F6C197FFFAE23B89BE3EED2B3D888F57BF1E568500BCAF334ACB955E2B`; supersedes V-068. |
| V-087 | Yes or No complete, no deck, contextual info, landscape | `design/tarot-deck/reading-table-yes-no-all-revealed-info-landscape-v2-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-052; 1844×853; SHA-256 `580079082489E69CA459AB598A976751A8403600E46EF0C15B6272A076BED89A`; supersedes V-069. |
| V-088 | Tutorial opened from active reading | `design/tarot-deck/read-contextual-tutorial-yes-no-v2-spanish-a-ceremonial-obsidian.png` | Approved by A-021/A-052; 862×1825; SHA-256 `BEB6283ED6AD8FCCCA2F5F880F1AABC10FDC743608564A8D33E200DED39D0F31`; Back returns to the unchanged table and Previous/Next browse tutorials. |
| V-089 | Repeatable physical shuffle motion V3 | `design/tarot-deck/reading-table-repeatable-shuffle-motion-storyboard-v3-a-ceremonial-obsidian.png` | Approved by A-021/A-052; 1672×941; SHA-256 `6E8FB19E641A6747F68696529B0E378C38FFCDB88AFE4281469DBAC7EE902544`; supersedes V-048. |

## A-053 — Six cards and Custom Spreads (2026-08-12)

Approved automatically under A-021 after the owner's direct product instruction. Spanish masters govern composition; English uses the same layout with verified localized copy.

| Ref | Screen/state | Path | Canvas | Orientation | SHA-256 | Status |
|---|---|---|---:|---|---|---|
| V-090 | Reading-kind selector: One/Three/Six/Custom; info left, check right | `design/tarot-deck/read-home-reading-kind-selector-four-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | `8EA2FCEBE0A9351CAD9B71FBEB540D37D466331A5B6054D6D31E2868BBCC32FF` | REPLACED BY V-107; historical image incorrectly showed seven cards and One Card selected. |
| V-091 | Six-Card Guidance table, ready to shuffle | `design/tarot-deck/reading-table-six-card-guidance-ready-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | `043F4821259B78AAD194267A23B4F40418973DC33E08CE10F1A377366AEFD7F1` | APPROVED/CURRENT |
| V-092 | Custom Spreads library, populated | `design/tarot-deck/custom-spreads-library-populated-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | `98190E49BF9635DDEA9C78C1E74B7E96CAA6D65C735E631DD2F511844F52ABA3` | APPROVED/CURRENT |
| V-093 | Custom Spread editor, six slots | `design/tarot-deck/custom-spread-editor-six-cards-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | `AA6407E22700752161F833F3B622C64206C24F498F97AD8718A0681F57BE6B5C` | APPROVED/CURRENT |
| V-094 | Custom Spreads library, empty | `design/tarot-deck/custom-spreads-library-empty-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | `5415923F62C77CE62785D8E4DDFCBA0D6519720FED7BEE44759E844B50FA0FF0` | APPROVED/CURRENT |
| V-095 | Custom editor Arrange visual sheet | `design/tarot-deck/custom-spread-editor-arrange-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | `67B73CF00C8B4C2501AD798129462570D31316AF4CCE743639237846628DD248` | APPROVED/CURRENT |
| V-096 | Custom seven-card table, ready to shuffle | `design/tarot-deck/reading-table-custom-seven-card-landscape-v1-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | `7B5626E2FCB80452010FC31B4875FB31F0185B25D731CF524473F5DCDBE76238` | APPROVED/CURRENT |

## A-054 — Manual placement and physical top-card shuffle (2026-08-12)

Approved automatically under A-021 after the owner's direct instruction. These masters replace the affected Deal-based table states without deleting the historical references. Spanish governs composition; English uses the same layout with localized copy.

| Ref | Screen/state | Path | Canvas | Orientation | SHA-256 | Status |
|---|---|---|---:|---|---|---|
| V-097 | Three Cards shuffled; tap an empty position; no Deal | `design/tarot-deck/reading-table-three-cards-shuffled-tap-position-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | `1CEB2D510ABB6652EF60BEC0B9984E843F3DB8B632C088430E78167D9B3FDF0B` | APPROVED/CURRENT |
| V-098 | Three Cards partial; center position chosen first | `design/tarot-deck/reading-table-three-cards-partial-middle-first-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | `A7F3B0604708E7858AD7864D2912B0436BFC0D5211436D22F35CB63A333D1481` | APPROVED/CURRENT |
| V-099 | Three Cards partial; center position chosen first | `design/tarot-deck/reading-table-three-cards-partial-middle-first-landscape-v1-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | `73BFC33AEC64E89D60932E5D4A30B59CDAFFBAD953380A56C970E7A6EADECF26` | APPROVED/CURRENT |
| V-100 | Shuffle V4 plus tap-position placement storyboard | `design/tarot-deck/reading-table-manual-placement-motion-storyboard-v4-a-ceremonial-obsidian.png` | 1672×941 | Landscape storyboard | `9286DB57DAFA170C87376634289BC5F311F108CFC3F9531A5B2164067DEA25B0` | REPLACED BY V-119; preserved historical motion reference. |
| V-101 | Six-Card Guidance partial; Action chosen first | `design/tarot-deck/reading-table-six-card-partial-action-first-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | `EE3D40472A08DD8878C403AE022C233879F1740C626230216337F7BB11B203D5` | APPROVED/CURRENT |
| V-102 | Custom seven-card table partial | `design/tarot-deck/reading-table-custom-seven-partial-v1-landscape-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | `805ED5688AEF2E5C5841DEEF8539C4FBF8D59226E6BC3825F2224EFAFDA9878E` | APPROVED/CURRENT |

V-097–V-102 supersede Deal-based behavior in V-084/V-085/V-089/V-091/V-096. V-086/V-087 remain current for a complete table without a deck. V-088 remains current for contextual tutorial navigation.

## A-055 — Compact landscape table and shared slot geometry (2026-08-12)

Approved automatically under A-021 after the owner's direct device feedback. These references remove the saturated landscape rail, enlarge the deck and define a shared non-overlapping slot frame. Spanish governs composition; English uses the same layout with localized copy.

| Ref | Screen/state | Path | Canvas | Orientation | SHA-256 | Status |
|---|---|---|---:|---|---|---|
| V-103 | Three Cards shuffled; compact landscape, large deck | `design/tarot-deck/reading-table-three-card-shuffled-compact-landscape-v1-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | `0F8A809716E64A3B2EF6F177CE2FAFD676A8413F903C8EAF9F01F4960B69EB20` | APPROVED/CURRENT |
| V-104 | Three Cards partial; shared frames, no overlap | `design/tarot-deck/reading-table-three-card-partial-compact-landscape-v1-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | `245B43A48017D8DDBC7D1F2CEECF1FF6EC94F3B0D0058FF3AF3C99E4F79929D5` | APPROVED/CURRENT |
| V-105 | Three Cards complete face down; shared frames | `design/tarot-deck/reading-table-three-card-complete-compact-landscape-v1-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | `8551828AD92F4661C73011147F66080596B818A2DF0EEFB334260B33363F05B8` | APPROVED/CURRENT |
| V-106 | Multi-card portrait orientation recommendation | `design/tarot-deck/reading-table-three-card-portrait-orientation-hint-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | `1C3286E78D7E55FEDC6ADE3F9917B9793589739A33B3AAE9A2AC99FA4DB0C47A` | APPROVED/CURRENT |

V-103–V-105 supersede V-099 and any landscape rail composition for equivalent Three Cards states. V-106 adds only a secondary portrait recommendation for multi-card readings; it does not change navigation or state.

## A-056 — Three Cards first-install default and corrected Six Cards glyph (2026-08-12)

Approved automatically under A-021 after the owner's direct correction. The option order remains One/Three/Six/Custom; only a clean installation starts with Three Cards selected, while every saved choice and active reading remains authoritative.

| Ref | Screen/state | Path | Canvas | Orientation | SHA-256 | Status |
|---|---|---|---:|---|---|---|
| V-107 | Reading-kind selector: Three Cards default; Six Cards glyph is exactly 2×3 | `design/tarot-deck/read-home-reading-kind-selector-three-default-six-corrected-v3-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | `439C1AA94EFD6E9501BDD44ABA03178CFA6984DF7FA38240A176917F802DC701` | APPROVED/CURRENT; replaces V-090. The compact Home selector and open sheet both show Three Cards. |

Accessibility adaptations remain allowed: safe areas, Dynamic Type, VoiceOver, contrast, 44-point targets, Reduced Motion and native scrolling, while preserving hierarchy, copy and Ceremonial Obsidian character.

## A-059 — Automatic shuffle, persistent deck and direct placement (2026-08-13)

Approved automatically under A-021 after the owner's direct instruction. These complete references replace the prior table behavior where shuffling had to be initiated manually, shuffling stopped after the first placement, or the deck disappeared when the layout was complete. English and Spanish are both canonical localized renders; the extra partial-landscape exploration remains a proposal and does not govern implementation.

| Ref | Screen/state | Path | Canvas | Orientation | Language | SHA-256 | Status |
|---|---|---|---:|---|---|---|---|
| V-108 | Reading Table entry, automatic shuffle in progress | `design/tarot-deck/reading-table-auto-shuffle-entry-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish | `E7D657FB3B9110F73FD4A71573B72FD83D5692176815B1F943A6BE0AC1CC86C3` | APPROVED/CURRENT |
| V-109 | Reading Table entry, automatic shuffle in progress | `design/tarot-deck/reading-table-auto-shuffle-entry-v1-english-a-ceremonial-obsidian.png` | 853×1844 | Portrait | English | `1A2CF3136E6E5B8A72002539774411DFB3EE1FCB63CD4627D5011D32D57D11D1` | APPROVED/CURRENT |
| V-110 | Reading Table steady, empty layout and persistent deck | `design/tarot-deck/reading-table-persistent-deck-steady-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish | `577EFC738E85766E3AF648352D2CA3D9EDDBA223C73B618C116A2257EEDD553A` | APPROVED/CURRENT |
| V-111 | Reading Table steady, empty layout and persistent deck | `design/tarot-deck/reading-table-persistent-deck-steady-v1-english-a-ceremonial-obsidian.png` | 853×1844 | Portrait | English | `32D125B93F749D7DED06E00FEE03D60DCFE0B2209168E3DF168B896EF5D317A2` | APPROVED/CURRENT |
| V-112 | Reading Table partial placement and persistent deck | `design/tarot-deck/reading-table-persistent-deck-partial-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish | `F9F0D347689A708672D9C628CE8E8C68A344CEE9FFE7AF1D123E8AAABCDA5F9D` | APPROVED/CURRENT |
| V-113 | Reading Table partial placement and persistent deck | `design/tarot-deck/reading-table-persistent-deck-partial-v1-english-a-ceremonial-obsidian.png` | 853×1844 | Portrait | English | `A3C2023073C780F2099AD23BD17AF362E9D2B4BA45C11FB205FE907FFE564FBD` | APPROVED/CURRENT |
| V-114 | Reading Table complete and persistent deck | `design/tarot-deck/reading-table-persistent-deck-complete-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish | `78F8F91E8C00B2BC736E0D057EDF12AF0B1216E4FCB20B986C68E3ACFC83F37E` | APPROVED/CURRENT |
| V-115 | Reading Table complete and persistent deck | `design/tarot-deck/reading-table-persistent-deck-complete-v1-english-a-ceremonial-obsidian.png` | 853×1844 | Portrait | English | `8E8766CF7BEB31290388028251E89ABB39CAAD25994B9B071CE44612851E87EF` | APPROVED/CURRENT |
| V-116 | Reading Table steady, raised compact landscape header | `design/tarot-deck/reading-table-persistent-deck-steady-compact-landscape-v1-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish | `B0FD82215F73CE687E83D3A7AB95BAFA5EE8D802091B911F1C487927DD25990C` | APPROVED/CURRENT |
| V-117 | Reading Table steady, raised compact landscape header | `design/tarot-deck/reading-table-persistent-deck-steady-compact-landscape-v1-english-a-ceremonial-obsidian.png` | 1844×853 | Landscape | English | `40C4B0402890442A352B830AD5021C0BA4EBC8FC5F6C3C656E8A24D107AAADFA` | APPROVED/CURRENT |
| V-118 | Reading Table complete, persistent deck and compact landscape header | `design/tarot-deck/reading-table-persistent-deck-complete-compact-landscape-v1-spanish-a-ceremonial-obsidian.png` | 1844×853 | Landscape | Spanish | `1CD5C0758FCC63A97E0DCD04860950A7EC0D23CFE3D4542D2746734FD360F196` | APPROVED/CURRENT |
| V-119 | Automatic/repeated shuffle, direct placement and persistent-deck motion storyboard V5 | `design/tarot-deck/reading-table-auto-shuffle-persistent-deck-motion-storyboard-v5-a-ceremonial-obsidian.png` | 1672×941 | Landscape storyboard | English motion labels | `F5BCE2191D0188CD171BCD2B8915517B8A67ABA9D5348FAAD2B35A721243DF31` | APPROVED/CURRENT SUPPORTING SPEC |

V-108–V-119 supersede V-097–V-106 and V-100 wherever those references conflict with automatic entry shuffle, an independently repeatable Shuffle control, a deck that stays visible, the temporary `phone / teléfono` hint, or the raised landscape header. Earlier images remain preserved as historical references. The implementation may adapt safe-area spacing and accessibility presentation, but it must not reintroduce visual dimming during shuffle or remove the persistent deck.

## A-060 — Smaller information glyphs and discoverable Cards filters (2026-08-13)

Approved automatically under A-021 after direct owner feedback. Spanish governs composition; English uses the same layout with localized copy. The 22-point visual information circle always retains a 44×44-point target.

| Ref | Screen/state | Path | Canvas | Orientation | Language | SHA-256 | Status |
|---|---|---|---:|---|---|---|---|
| V-120 | Reading-kind selector; extra-small information glyphs | `design/tarot-deck/read-home-reading-kind-selector-info-extra-small-v4-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout governs English | `4856C7C92510D702195472E0D8E147E38AC6C9338C59C82F93FA433F83E07E60` | APPROVED/REPLACED by V-123/V-124; preserves V-107's exact 2×3 Six Cards glyph and default state. |
| V-121 | Three-card style selector; extra-small information glyphs | `design/tarot-deck/read-home-three-card-style-selector-info-extra-small-v5-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout governs English | `1981978F24B52E61B5F9F0D5FC958AEA50BD4781FFF9F31E4C7A4C0B1B25BDEC` | APPROVED/REPLACED by V-125/V-126. |
| V-122 | Cards Library; discoverable horizontal filter row | `design/tarot-deck/cards-library-filter-scroll-affordance-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish; layout governs English | `92FEF9B73F8A4AC4DBBF86993F4A0A253A381047042A1027249F14628CF24D4A` | APPROVED/CURRENT; replaces V-022 for S07 All. Partial next chip, edge fade/chevron and native indicator communicate horizontal scrolling. |

## A-061 — Higher information controls and publication preparation (2026-08-18)

Approved automatically under A-021 after the owner's direct correction. These masters move only the visible information control higher and farther left while preserving the 22-point circle, the independent 44×44-point target, the selection mark on the right, the exact Six Cards 2×3 glyph and the existing selector hierarchy. English and Spanish are both canonical localized renders.

| Ref | Screen/state | Path | Canvas | Orientation | Language | SHA-256 | Status |
|---|---|---|---:|---|---|---|---|
| V-123 | Reading-kind selector; information control higher at upper-left | `design/tarot-deck/read-home-reading-kind-selector-info-upper-left-v5-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish | `89D5D65C45DB562ADB20CB9AC1577AB68B21434E2FB8C9AF3FECE0E9FE9B96A9` | APPROVED/CURRENT; replaces V-120 for Spanish selector presentation. |
| V-124 | Reading-kind selector; information control higher at upper-left | `design/tarot-deck/read-home-reading-kind-selector-info-upper-left-v5-english-a-ceremonial-obsidian.png` | 853×1844 | Portrait | English | `F1956DC881E4E3198B9AA33F26C23769BADE3644E4C650E23DE75BBB2861C2F2` | APPROVED/CURRENT; English companion to V-123. |
| V-125 | Three-card style selector; information control higher at upper-left | `design/tarot-deck/read-home-three-card-style-selector-info-upper-left-v6-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish | `044A2E387998DAA784BFB61BBD69561DFBD8013C32068BC2C7331A83B2186323` | APPROVED/CURRENT; replaces V-121 for Spanish selector presentation. |
| V-126 | Three-card style selector; information control higher at upper-left | `design/tarot-deck/read-home-three-card-style-selector-info-upper-left-v6-english-a-ceremonial-obsidian.png` | 853×1844 | Portrait | English | `7D04EA78C99C8CFF7F48DDFA82F0645950263598D6C48DA58F12DEEF8CA762D8` | APPROVED/CURRENT; English companion to V-125. |
| V-127 | Settings; release-ready minimal destinations | `design/tarot-deck/settings-release-ready-minimal-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish | `BE96308502FC8E76948643A033A9B793182D9FE75C471842322D8A126DB6DC40` | APPROVED/REPLACED by V-131 after A-064 activated StoreKit support. |
| V-128 | Settings; release-ready minimal destinations | `design/tarot-deck/settings-release-ready-minimal-v1-english-a-ceremonial-obsidian.png` | 853×1844 | Portrait | English | `F8A1E43F20766530746505E1A832A533F4D3B19A273ED8252E3BA901A21A1931` | APPROVED/REPLACED by V-132 after A-064 activated StoreKit support. |

V-120/V-121 and V-045 remain preserved as historical references. A-061 changes no selector action, selection persistence, information destination or accessibility target. Settings retains language selection and exposes only functional release destinations: Rate the App, Privacy and Support.

## A-062 — Inline orientation guidance and right-side landscape deck (2026-08-18)

Approved automatically under A-021 after the owner's direct correction. The orientation recommendation is ordinary transient instruction copy, never a toast, capsule, banner or overlay. It is offered once when a new or reset multi-card reading enters portrait, shares the same stable instruction corridor as the reading cues, and is then replaced by the current contextual cue. Restoring or revisiting that reading does not offer it again. Landscape keeps the persistent deck physically on the right.

| Ref | Screen/state | Path | Canvas | Orientation | Language | SHA-256 | Status |
|---|---|---|---:|---|---|---|---|
| V-129 | Reading Table entry; inline orientation instruction | `design/tarot-deck/reading-table-orientation-hint-inline-entry-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish | `BBC7EAE7ED4FD8B0C496D1DC3D73742CAD4DABF70FC0FC1BF8374A12A6CA7D2A` | APPROVED/CURRENT; replaces V-108 only for orientation-hint presentation. |
| V-130 | Reading Table entry; inline orientation instruction | `design/tarot-deck/reading-table-orientation-hint-inline-entry-v1-english-a-ceremonial-obsidian.png` | 853×1844 | Portrait | English | `381286F3BCCFC416AF9091424A16280982F7C050C60820E525BA1FC5EE66B223` | APPROVED/CURRENT; English companion to V-129. |

V-110/V-111 remain current for the same portrait table after the transient instruction disappears. V-116/V-117 remain current for landscape and explicitly govern the physical right-side deck. All earlier masters remain preserved.

## A-064 — Seven equivalent monthly supporter levels (2026-08-18)

Approved automatically under A-021 after the owner's direct instruction to implement subscriptions like Voice Recorder. Settings keeps support voluntary and secondary; the Support screen shows seven equivalent monthly StoreKit levels, live localized prices, free-app disclosure, restoration, management, Privacy and Terms. No option is marked as better and no functionality is gated.

| Ref | Screen/state | Path | Canvas | Orientation | Language | SHA-256 | Status |
|---|---|---|---:|---|---|---|---|
| V-131 | Settings with active Support the App row | `design/tarot-deck/settings-monthly-support-v2-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish | `281251C279C6C4D7E0D0F10B88B433E8B7F5C26F41BCF8B1DD29DD0132CAD7C2` | APPROVED/CURRENT; replaces V-127. |
| V-132 | Settings with active Support the App row | `design/tarot-deck/settings-monthly-support-v2-english-a-ceremonial-obsidian.png` | 853×1844 | Portrait | English | `25013A9049221F86F752E56E6047A9EEB5BF504C33F400D478606BCFCC574212` | APPROVED/CURRENT; replaces V-128. |
| V-133 | Support the App; seven monthly levels, not active | `design/tarot-deck/support-the-app-seven-levels-v1-spanish-a-ceremonial-obsidian.png` | 853×1844 | Portrait | Spanish | `BE58CB9C7E0BEEA0C87DA61205EAC7284A9E7CBCA86395EA1980010DC6FF29E6` | APPROVED/CURRENT; replaces inactive V-027. |
| V-134 | Support the App; seven monthly levels, not active | `design/tarot-deck/support-the-app-seven-levels-v1-english-a-ceremonial-obsidian.png` | 853×1844 | Portrait | English | `67B486722A3398631CE7AAC079E5738EF77C5A512DA23DDF62A6A88C29DA3024` | APPROVED/CURRENT; English companion to V-133. |
