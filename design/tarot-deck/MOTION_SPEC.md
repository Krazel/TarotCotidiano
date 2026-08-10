# Tarot Deck — Ceremonial Motion Specification

Status: approved automatically under A-021/A-029
Date: 2026-08-10
Target: iPhone, iOS 16+, SwiftUI

## Reference

- Storyboard: `design/tarot-deck/reading-table-motion-storyboard-a-ceremonial-obsidian.png`
- Dimensions: 1774×887
- SHA-256: `30D49233D041893FAC2783D72F90A9C737BA49F74A25EE547EC022D31CBC3E64`
- Role: four-keyframe motion reference for the existing approved reading table; it does not add a screen or change layout.

## Motion character

Motion is restrained, tactile and editorial. It communicates state and preserves the feeling of a physical deck. No particle burst, casino bounce, continuous ambient movement, random wobble or ornamental delay is allowed.

## Timing and easing

| Interaction | Full motion | Reduced Motion |
|---|---|---|
| Screen/state transition | 220 ms ease-out; opacity plus 0.985→1 scale | 150 ms opacity only |
| Primary-button press | 90 ms ease-out to 0.985 scale | 150 ms opacity response only |
| Shuffle | 480 ms settle; two restrained lateral cuts, up to ±10 pt and ±2° | No deck displacement; 150 ms opacity pulse |
| Draw | 380 ms spring, response 0.38, damping 0.88; short move from deck direction, 0.92→1 scale | 150 ms opacity only |
| Reveal/conceal | 320 ms ease-in-out 3D turn around vertical axis | 150 ms cross-fade |
| Meaning sheet | Native iOS sheet motion | Native Reduced Motion behavior |

## Haptics

- Shuffle success: one soft impact.
- Draw success: one medium impact.
- Reveal success: one light impact.
- Conceal success: one soft impact.
- Error alerts use native alert behavior; no celebratory or repeated haptic.

Haptics occur only after the durable action succeeds. They never substitute visible or VoiceOver feedback.

## State and privacy rules

- A face-down identity remains absent from accessibility labels and is never shown during shuffle or draw.
- Draw animation starts from the deck direction but does not require the deck and card to share a visual identity.
- Only the affected card moves. Existing cards, labels and controls remain stable.
- Reveal cannot run until draw persistence succeeds; meaning cannot open until reveal persistence succeeds.
- Restoring an existing session does not replay shuffle, draw or reveal.
- Rotation does not mutate session state and an orientation change does not restart motion.
- Interaction is locked only for the short local shuffle choreography or while the model is already saving.

## Accessibility

- `accessibilityReduceMotion` replaces displacement, scale and 3D rotation with short opacity transitions.
- VoiceOver uses the same reduced variants so focus and semantics remain stable.
- Backgrounding, leaving the table or rotating never replays state motion; transient shuffle layers are cancelled.
- VoiceOver receives the same semantic labels and actions before and after animation.
- After a committed draw or turn, VoiceOver focus moves to the affected reading position and announces its new face-down or face-up semantics.
- Decorative shuffle layers are hidden from accessibility.
- Dynamic Type continues to use the vertical scrolling composition; animation never changes reading order.

## Visual invariants

- Preserve Ceremonial Obsidian background, antique-gold edges, card proportions and approved portrait/landscape layouts.
- Do not introduce glow brighter than the existing gold, new art, new copy, new controls or new navigation.
- Motion must remain legible at 60 Hz and must not depend on ProMotion.
