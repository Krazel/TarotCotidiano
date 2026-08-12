# Tarot Deck — Ceremonial Motion Specification

Status: approved automatically under A-021/A-054
Date: 2026-08-12
Target: iPhone, iOS 16+

## Governing reference

- Storyboard: `design/tarot-deck/reading-table-manual-placement-motion-storyboard-v4-a-ceremonial-obsidian.png`
- Reference ID: V-100
- Canvas: 1672×941
- SHA-256: `9286DB57DAFA170C87376634289BC5F311F108CFC3F9531A5B2164067DEA25B0`
- Sequence: `rest → press → cut with tracked old top → insert old top under packet → interleave → riffle with incoming top → square/new top`, followed by one placement per empty-slot tap and independent flips.
- V-100 supersedes V-089. V-089, V-048 and V-041 remain historical and are not deleted.

## Character

Motion is tactile, physical and contained. The deck has believable weight, cards travel deliberately, and every object settles without casino bounce. The camera, viewport, labels, slots and persistent controls remain fixed.

Do not add particles, magical trails, ambient loops, random wobble, elastic overshoot, ornamental pauses or brighter glow. Motion must never delay access to an already committed result.

## Durable-state contract

1. Press feedback may acknowledge contact immediately.
2. Split, interleave, riffle and square begin only after a fresh 78-card order persists.
3. Every additional deck tap before the first placement commits another complete shuffle and replays the same short choreography.
4. Tapping an empty position commits exactly the next card plus that position in one atomic session save before presentation begins.
5. Restoration may observe a valid partial layout and restores each card in its chosen position without replaying presentation.
6. Flip or conceal begins only after the new face state persists.
7. Meaning cannot open until reveal persistence succeeds.
8. A failed durable action produces no success motion or success haptic and leaves the previous durable state intact.
9. Presentation state never writes, rolls back, reorders, draws or reveals a card.

Restoration establishes the latest durable state as the visual baseline. It never replays shuffle, placement, flip or haptics.

## Timing

| Phase | Full motion | Reduce Motion / VoiceOver |
|---|---|---|
| Screen transition | 220 ms ease-out; opacity plus restrained 0.985→1 scale | 150 ms opacity only |
| Deck press | 80–110 ms restrained compression/release | 90–100 ms opacity only |
| Split / cut | 170 ms ease-in-out; two decorative packets, at most ±20 pt and ±2.5° | Omitted |
| Interleave | 220 ms ease-in-out toward the common anchor | Omitted |
| Riffle | 210 ms timing curve `(0.30, 0.00, 0.20, 1.00)` with small opposing rotations | Omitted |
| Square / settle | 190 ms restrained settle to the exact rest frame | 150 ms opacity pulse |
| Place next card | 310 ms to the tapped position along a shallow curved path | 120 ms cross-fade at the destination |
| Flip / conceal | 320 ms two-surface vertical-axis turn | 150 ms cross-fade |
| Meaning sheet | Native iOS sheet motion | Native iOS behavior |

There is no pause between shuffle phases. Placement and flip remain separate user actions.

## Controls and layout

- Before the first valid shuffle, the deck is active and empty positions do not place cards.
- After a valid shuffle and while zero cards are placed, the deck stays active for reshuffles and every empty position becomes actionable.
- The first successful placement disables reshuffle. The remaining deck stays as a static source until the final position is filled.
- After the final placement, the deck remains absent for the rest of that reading. Reset is the only quick restart.
- Press and decorative packets live inside the deck’s fixed outer frame and are hidden from accessibility.
- The deck, every slot and every placement overlay use stable anchors in the same coordinate space.
- Empty, face-down and face-up forms of one slot share identical final bounds and center.
- Ready, shuffled and complete references V-082–V-087 share the same stable table geometry.
- Dynamic Type accessibility sizes may use the approved scrollable composition; normal portrait and landscape must not scroll or jump.

## Placement privacy

- The animated object is always a generic card back.
- It must not load, label, log or expose the card identity before the durable reveal.
- The tapped destination slot stays reserved at full size during placement.
- At landing, overlay and destination exchange visibility in one frame without flash or duplicate edge.
- A source snapshot may remain until the final landing, but removing it cannot collapse or recenter the table.

## Flip privacy

- Back and front are independent surfaces in one fixed slot.
- During reveal, the front becomes visible only after the midpoint.
- During conceal, the order reverses.
- Text and artwork are never mirrored.
- A face-down identity stays absent from visible copy, accessibility, user-facing logs, recovery messages and navigation.

## Haptics

- Shuffle: one soft impact after square/settle.
- Placement: one medium impact after the card lands in the chosen position.
- Reveal: one light impact after the face is fully visible.
- Conceal: one soft impact after the back is fully visible.
- Failed, restored, cancelled or background-completed actions produce no success haptic.

A success haptic requires a successful durable commit, completed visual landing, a current presentation token and an active scene.

## Cancellation and accessibility

- Each choreography owns a cancellable task/token.
- Backgrounding, leaving the table, rotating or destroying the view cancels pending presentation and haptics.
- Cancellation renders the latest committed state directly and never rolls persistence back.
- Rapid repeated taps cannot overlap durable actions or presentations.
- Reduce Motion removes translation, scale and 3D rotation while preserving state order.
- VoiceOver uses the reduced path, announces only stable post-commit states and focuses real slots rather than decorative layers.
- All controls retain at least 44×44 pt hit targets.

## iOS 16 boundary

Use iOS 16-compatible `withAnimation`, `Animation`, `AnimatableModifier`, `rotation3DEffect`, geometry/preferences, cancellable `Task`, UIKit accessibility announcements and impact generators.

Do not use iOS 17-only `PhaseAnimator`, `KeyframeAnimator` or `sensoryFeedback`, and do not add a third-party animation runtime.

## Acceptance

Test One Card and all five Three Cards styles in portrait and landscape on iOS 16, including a small iPhone, Dynamic Type, VoiceOver and Reduce Motion.

The motion passes only when:

1. Ten consecutive shuffle/reshuffle, position-placement and flip sequences finish without hitch, flash, duplicate edge or stranded overlay.
2. Header, labels, unaffected slots and controls remain pixel-stable.
3. The viewport does not scroll, bounce or change height at normal text sizes.
4. Placement starts at the visible deck anchor and lands exactly in the tapped slot.
5. Flip never exposes mirrored or premature front artwork.
6. Success haptics occur exactly once after commit and landing.
7. Backgrounding and rotation return to the correct committed rest state without replay.
8. Three repeated shuffles produce valid complete orders and the first position tap uses the latest.
9. After the last placement, neither visible UI nor VoiceOver exposes a deck or Deal action.
10. No behavior depends on network access, ProMotion or a third-party runtime.
