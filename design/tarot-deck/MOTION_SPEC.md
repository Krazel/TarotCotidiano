# Tarot Deck — Ceremonial Motion Specification

Status: approved automatically under A-021/A-031
Date: 2026-08-10
Target: iPhone, iOS 16+, SwiftUI

## Governing reference

- Storyboard: `design/tarot-deck/reading-table-professional-motion-storyboard-v2-a-ceremonial-obsidian.png`
- Reference ID: V-048
- Dimensions: 1672×941
- SHA-256: `937F89E3DF7D2161E6AD2C835A4201135161E6ADED083A4BE52B8773A58190F0`
- Role: six-keyframe reference for `rest → press → cut → interleave → deal → flip` on the existing approved reading table.
- Supersession: V-048 replaces V-041 as the governing motion reference. V-041 remains historical only.

V-048 defines motion, not a new screen. It does not authorize new controls, copy, navigation, art, card identities or reading behavior.

## Motion character

Motion is restrained, tactile and physical. The deck has believable weight; cards travel deliberately and settle without casino bounce. The camera, viewport, reading table, labels and controls remain still while a local object moves.

No particle burst, magical trail, continuous ambient movement, random wobble, elastic overshoot, ornamental pause or animation that delays access to a committed result is allowed. Gold emphasis may use the existing luminance only; motion must not introduce a brighter glow.

## Event and persistence contract

1. A press response may begin immediately because it only acknowledges contact with the deck control.
2. Cut/interleave begins only after shuffle persistence succeeds.
3. Deal begins only after draw persistence succeeds and the destination slot is reserved.
4. Flip or conceal begins only after the new face state persists successfully.
5. Meaning cannot open until reveal persistence succeeds.
6. A failed durable action releases the press state, shows the existing failure path and produces no cut, interleave, deal, flip or success haptic.
7. Presentation state never writes, rolls back, redraws, reorders or reveals a card. The durable model remains the sole source of card order and face state.

Restoration establishes the current durable state as the visual baseline. It never replays press, shuffle, deal, flip or haptics.

## Timing and easing

| Phase | Full motion | Reduced Motion / VoiceOver |
|---|---|---|
| Screen/state transition | 220 ms ease-out; opacity plus 0.985→1 scale. It must not move the table viewport. | 150 ms opacity only. |
| Deck press | 80 ms ease-out to 0.985 scale and 0.94 opacity; 100 ms ease-out release. | 90 ms opacity to 0.92; 100 ms opacity release; no scale. |
| Cut | 180 ms ease-in-out. Split the visual deck into two decorative packets, translate no more than ±14 pt horizontally and ±3 pt vertically, and rotate no more than ±1.5°. | Omitted. |
| Interleave | 240 ms ease-in-out. Return the packets toward the common deck anchor with one restrained overlap; packet edges may stagger by at most 40 ms. | Omitted. |
| Shuffle settle | 180 ms spring, response 0.32, damping 0.90, zero blend duration. End at the exact rest frame with no visible overshoot. | One 150 ms opacity pulse on the unchanged deck. |
| Deal | 380 ms timing curve `(0.20, 0.72, 0.18, 1.00)`. Move one face-down overlay from the deck anchor to the reserved slot along a shallow arc, scale 0.94→1 and rotate by at most 2°→0°. | 150 ms cross-fade at the destination; no translation, scale or rotation. |
| Flip / conceal | 320 ms ease-in-out. Two 160 ms halves around the vertical axis: outgoing surface 0°→90°, incoming surface −90°→0°. | 150 ms cross-fade between surfaces; no 3D rotation. |
| Meaning sheet | Native iOS sheet motion. | Native iOS Reduced Motion behavior. |

Cut, interleave and settle form one 600 ms shuffle choreography after the durable shuffle commit. There is no pause between phases. Deal and flip are separate user actions and never chain automatically.

The deal arc rises perpendicular to the straight deck-to-slot vector by `min(42 pt, distance × 0.12)` at its midpoint. Its end position, size and angle must equal the reserved slot exactly. The direction may mirror naturally for different slots; its duration and character do not change.

## Press, shuffle and deck control

- The visible deck is the primary control: before shuffle it shuffles; after shuffle it draws while a slot remains.
- Press feedback belongs to the deck's fixed outer frame. It must not resize the parent, alter hit testing or move neighboring content.
- Cut/interleave packets are decorative snapshots or layers inside an overlay. They never participate in layout and are hidden from accessibility.
- The underlying interactive deck remains one accessible button with one action. Decorative packets cannot receive taps or focus.
- Input may remain locked while the model is saving and during the short local cut/interleave/settle sequence. It unlocks immediately on stable completion or cancellation.

## Deal from deck anchor to reserved slot

- The deck and every reading slot expose stable visual anchors in the same coordinate space before an action begins.
- The destination slot retains its full final size throughout the action. It does not appear, expand or move as a side effect of the draw.
- The animated deal object is always a generic card back. It must not load, label, log or expose the drawn identity.
- Existing cards, empty slots, position labels, header, instructions and end-reading control do not move.
- On the final draw, a visual snapshot may remain at the source until the deal lands even if the logical deck is no longer actionable. Removing that snapshot must not collapse layout.
- At landing, the overlay and the durable destination exchange visibility in one frame. No duplicate edge, flash or size discontinuity may be visible.

## Two-surface flip and identity privacy

- The slot keeps one fixed frame and contains independent back and front surfaces.
- During reveal, only the back is visible from 0° through 90°. The front becomes visible only in the second half, beginning edge-on at −90°.
- During conceal, the sequence is reversed. The back carries no card identity.
- Never mirror text or artwork: each surface is hidden before its rotation would expose a reversed image.
- The front asset, card name and identity-based accessibility value are not visually or semantically exposed before the durable reveal commit.
- A face-down identity remains absent from visible copy, accessibility labels, user-facing logs, restoration status and navigation state.

## Fixed viewport and layout invariants

- The safe-area viewport, background, header, reading stage, slot frames, position labels and bottom control region keep fixed bounds for the entire local animation.
- Shuffle, draw and flip do not change `ScrollView` content height or offset. No automatic scroll or focus-driven visual scroll is allowed for non-VoiceOver use.
- A deck, button or instruction becoming inactive must use a reserved frame or overlay so its removal cannot reflow the table.
- Empty, face-down and face-up representations of a given occupied slot share the same final bounds and center.
- Corrected V-046 and V-047 share the same labelled slot geometry: equal card widths, equal horizontal gaps, a mathematically centered horizontal group and one unchanged vertical slot anchor. Removing the deck after the final draw leaves its reserved stage space empty; it never recenters the slots vertically.
- Only the affected deck packet or card moves. Existing cards, labels and controls remain pixel-stable.
- Rotation may select the approved portrait or landscape composition, but it does not mutate session state, replay motion or interpolate through a hybrid layout.
- Dynamic Type accessibility sizes may use the approved vertical scrolling composition. Its reading order and stable state after each action remain unchanged.

## Haptics

- Deck press: no haptic.
- Shuffle success: one soft impact when settle reaches the exact rest frame.
- Draw success: one medium impact when the dealt card lands in the reserved slot.
- Reveal success: one light impact when the front reaches its final face-up frame.
- Conceal success: one soft impact when the back reaches its final face-down frame.
- Error alerts use native alert behavior; no celebratory or repeated haptic is added.

A success haptic requires both a successful durable commit and the corresponding visual landing. Immediately before firing, the presentation must confirm that its task is not cancelled and `scenePhase == .active`. Reduced Motion uses the same one-haptic-at-completion rule. Restoration, rotation, foreground return and cancelled or failed actions produce no success haptic.

## Cancellation, backgrounding and replay

- Each local choreography owns a cancellable presentation task or equivalent token.
- Backgrounding, leaving the table, changing orientation or destroying the view cancels pending phases and scheduled haptics.
- Cancellation clears decorative packets and deal overlays, then renders the latest committed state directly in its stable rest frame without animation.
- The visual baseline is updated when a durable state arrives, before testing whether the scene is active. Returning to foreground therefore cannot replay an event committed in the background.
- A stale task cannot complete into a newer session, slot or face state. Presentation tokens must be associated with the relevant session and durable event.
- Cancellation never rolls back persistence and never starts a replacement action automatically.

## Accessibility

- `accessibilityReduceMotion` removes translation, scale and 3D rotation and uses the reduced variants above.
- VoiceOver uses the same reduced variants so focus and semantics remain stable.
- After a committed draw or turn, VoiceOver focus moves to the affected reading position after the new semantic element exists. It does not focus a decorative animation layer.
- The face-down label announces position and state only. The face-up label announces position, identity and its available meaning action.
- Decorative cut, interleave and deal layers are hidden from accessibility and cannot change reading order.
- Buttons retain a minimum 44×44 pt target during every phase. Disabling interaction does not remove their label, hint or current state.

## iOS 16 implementation boundary

Use iOS 16-compatible primitives such as `withAnimation`, `Animation`, `AnimatableModifier`, `rotation3DEffect`, `GeometryReader` or preferences for stable anchors, cancellable `Task`, and `UIImpactFeedbackGenerator`.

Do not use iOS 17-only `PhaseAnimator`, `KeyframeAnimator`, `sensoryFeedback` or another API that raises the deployment target. Avoid broad implicit `.animation` modifiers on the whole reading row or viewport; drive only the local presentation state for the affected object.

## Physical acceptance criteria

Test One Card and every Three Cards spread in portrait and landscape on a 60 Hz iPhone running iOS 16, including a small-width device and a notched device.

The motion passes only when all of the following are true:

1. Ten consecutive shuffle, draw and flip actions complete without a visible hitch, flash, duplicated card edge or unfinished overlay.
2. Header, position labels, unaffected slots, existing cards and end-reading control do not move by more than one rendered pixel during any local action.
3. The portrait and landscape viewport does not scroll, bounce or change content height on shuffle, intermediate draw or final draw.
4. The dealt card begins at the visible deck anchor and lands with its center, bounds and angle matching the reserved slot within one rendered pixel.
5. Flip never shows mirrored artwork, a blank full-width frame or the front face during the first 160 ms.
6. Each successful action produces exactly its specified haptic after commit and landing; failed, restored, cancelled or background-completed actions produce none.
7. Backgrounding during press, cut, interleave, deal and flip returns to the correct committed rest state without replay on foreground.
8. Rotation during every phase selects a stable approved orientation without drawing, revealing, reshuffling or replaying a haptic.
9. Reduce Motion and VoiceOver show only the reduced variants, keep reading order stable and focus the newly committed slot without exposing a face-down identity.
10. Rapid repeated taps cannot produce two durable actions, overlapping cards, a stale landing or more than one success haptic.
11. Motion remains clear at 60 Hz and does not depend on ProMotion, network access or a third-party animation runtime.

## Visual invariants

- Preserve Ceremonial Obsidian background, antique-gold edges, approved card proportions and the registered portrait/landscape compositions.
- Preserve the approved compact, centered reading hierarchy and the deck-as-control behavior.
- Do not introduce new art, copy, controls, navigation, brighter glow or animation outside the reading interaction described here.
