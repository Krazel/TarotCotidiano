# Reading-method methodology

Tarot began as a card game; divinatory reading developed later. There is no single official way to read a spread. The app therefore distinguishes three layers of authority:

1. **Documented tradition:** formulate a question, decide the layout before drawing, shuffle/cut, place cards in order, and interpret each card through its position and context. Waite documents multiple methods rather than one universal canon.
2. **Widespread modern practice:** One Card and flexible three-position spreads; card meaning is combined with position, question, imagery, and the other cards.
3. **Editorial adaptation:** upright-only reference, conditional language, privacy boundaries, and no automatic interpretation or verdict.

The four foundations and six reading tutorials use the following source base without copying source text:

- Arthur Edward Waite, *The Pictorial Key to the Tarot*, Part III, for documented historical procedures and the variety of methods.
- Joan Bunning, lessons on spreads, writing a question, and combining sources of meaning, for recognizable modern teaching practice.
- The Metropolitan Museum of Art's tarot history for the distinction between the historical game and later divinatory use.
- International Tarot Foundation ethics for consent, agency, privacy, uncertainty, and responsible limits.

## Existing Read presets

The app keeps exactly six presets:

1. `One Card`
2. `Past · Present · Possible Future`
3. `Situation · Challenge · Advice`
4. `You · The other person · Connection`
5. `Yes or No` (`For · Against · Outcome`)
6. `Freeform` (`Card 1 · Card 2 · Card 3`)

Tutorial wording may use `Possible Direction`, `Guidance`, and `Likely Outcome` to teach conditional, non-commanding interpretation. The Yes or No preset retains the language-neutral persisted ID `open` so existing local preferences and sessions migrate without loss. Freeform uses the distinct new ID `freeform` and neutral order labels without assigned roles.

## For, against, and outcome

The Yes or No preset follows a documented three-card structure found in printed deck instructions and contemporary teaching:

1. `For` — what supports a yes.
2. `Against` — what supports a no or creates resistance.
3. `Outcome` — the final answer inside the spread and the likely direction if current conditions continue.

The reader asks one concise closed question, keeps it in mind while shuffling, draws left to right, and reads the third card in light of the first two. No card has a universal yes/no classification and the app does not calculate a result. The reader stops rather than redrawing for a preferred answer. `Outcome` is not presented as immutable fate or certainty outside the reading.

Source basis: Emanuela Signorini's [booklet for *Romantic Tarot*](https://magicspot.eu/wp-content/uploads/doc/Romantic-Tarot-guidebook.pdf) documents `things in favour / things against / result`; Lou Siday documents [`Support / Opposition / Outcome`](https://tarottechnique.com/tarot-spreads/yes-or-no-tarot-spread-guide/) specifically for a yes-or-no question. [Lo Scarabeo's official record](https://www.loscarabeo.com/en/products/romantic-tarot) corroborates the printed deck and booklet. These establish the method without claiming a single official tarot canon.

The selected preset persists by a language-neutral ID. Labels localize to English or Spanish, while deck order, card IDs, draws, and reveal states remain unchanged.
