# Brand Color Guidelines

This document defines the brand color tokens, recommended uses, code snippets, accessibility notes, and common patterns to keep the product visually consistent.

## Colors (tokens)
- **Espresso Brown**: #3E2723 — Primary brand color (navigation, primary buttons)
- **Cream**: #F5E6D3 — Main background, cards, primary surfaces
- **Caramel**: #C17817 — Primary CTAs, active states, emphasis
- **Latte Foam**: #FDFBF7 — Alternate background, inputs, light surfaces
- **Mocha**: #6F4E37 — Secondary buttons, borders, icons
- **Cinnamon**: #D2691E — Rewards/points, promotions
- **Mint Green**: #98D8C8 — Success states, availability badges
- **Warm Red**: #D84315 — Urgency, live notifications, alerts
- **Steamed Milk**: #E8DCC4 — Disabled states, subtle dividers
- **Deep Espresso**: #1B0F0A — Primary text color
- **Medium Roast**: #5D4037 — Secondary text, captions
- **Light Foam**: #F9F5F0 — Subtle backgrounds, card overlays

## Quick usage map
- Primary surfaces: `Cream` background, `Espresso Brown` for primary text and key navigation
- CTAs / Emphasis: `Caramel` (use sparingly for primary CTAs)
- Secondary actions / controls: `Mocha`
- Success / availability: `Mint Green`
- Alerts / urgency: `Warm Red`
- Disabled / low emphasis: `Steamed Milk` or `Light Foam`

## Specific UI examples
- Hero sections & AI chat: `Cream` background + `Espresso Brown` headline text (strong, warm brand feel)
- Heatmap: Gradient from `Caramel` → `Warm Red` (low → high activity). Example stops: 0% `#C17817`, 60% `#D2691E`, 100% `#D84315`.
- Community forum: `Latte Foam` background; use `Mint Green` for active discussion badges and indicators.
- Reviews: `Caramel` stars on `Cream` background for consistent emphasis.
- Admin panel: Favor `Mocha` / `Espresso Brown` for controls and surfaces to convey a professional tone.

## Do / Don't
- Do: Use `Caramel` for the single primary CTA per screen. Keep accent colors to minimal elements (badges, icons).
- Do: Use `Mocha` for secondary buttons and borders; it pairs well with `Latte Foam`.
- Don't: Use `Warm Red` as a decorative color — reserve it for states that require urgent attention.
- Don't: Use `Deep Espresso` on very dark backgrounds; prefer `Cream` or `Light Foam` for legibility.

## Accessibility & contrast
- Aim for WCAG AA contrast for body text (4.5:1) and AA Large (3:1) for large text.
- Example contrasts (approx):
  - `Deep Espresso` (#1B0F0A) on `Cream` (#F5E6D3): strong contrast — good for body text.
  - `Espresso Brown` (#3E2723) on `Latte Foam` (#FDFBF7): good for prominent UI elements.
  - `Caramel` (#C17817) on `Cream` (#F5E6D3): borderline for small text; prefer using `Caramel` for icons/CTAs (not small body copy).
- For low-contrast decorative text, use `Medium Roast` or `Steamed Milk` appropriately and avoid conveying essential information solely with low-contrast text.

## Tokens — code snippets

Flutter (Dart)
```dart
class BrandColors {
  static const espressoBrown = Color(0xFF3E2723);
  static const cream = Color(0xFFF5E6D3);
  static const caramel = Color(0xFFC17817);
  static const latteFoam = Color(0xFFFDFBF7);
  static const mocha = Color(0xFF6F4E37);
  static const cinnamon = Color(0xFFD2691E);
  static const mintGreen = Color(0xFF98D8C8);
  static const warmRed = Color(0xFFD84315);
  static const steamedMilk = Color(0xFFE8DCC4);
  static const deepEspresso = Color(0xFF1B0F0A);
  static const mediumRoast = Color(0xFF5D4037);
  static const lightFoam = Color(0xFFF9F5F0);
}
```

CSS variables
```css
:root {
  --espresso-brown: #3E2723;
  --cream: #F5E6D3;
  --caramel: #C17817;
  --latte-foam: #FDFBF7;
  --mocha: #6F4E37;
  --cinnamon: #D2691E;
  --mint-green: #98D8C8;
  --warm-red: #D84315;
  --steamed-milk: #E8DCC4;
  --deep-espresso: #1B0F0A;
  --medium-roast: #5D4037;
  --light-foam: #F9F5F0;
}
```

Design tokens (JSON)
```json
{
  "color": {
    "espressoBrown": {"value": "#3E2723"},
    "cream": {"value": "#F5E6D3"},
    "caramel": {"value": "#C17817"}
  }
}
```

## Heatmap gradient example (CSS)
```css
.heatmap { background: linear-gradient(90deg, #C17817 0%, #D2691E 60%, #D84315 100%); }
```

## Implementation guidance
- Keep one dominant background per screen (prefer `Cream` or `Latte Foam`).
- Reserve `Caramel` for the single primary CTA; use `Mocha` for secondary CTAs.
- Use `Mint Green` only for positive states and availability badges — keep a single, consistent success color across the app.
- Use `Steamed Milk` for disabled UI and subtle dividers; do not use as primary background.
- When creating new components, pick 1 primary, 1 secondary, and 1 accent color from the tokens above; avoid introducing new hues without product/design approval.

## Tokens maintenance rules
- Store tokens in a single source of truth (design tokens JSON, Figma variables, or Flutter constants).
- When updating a hex value: update the source token, run a small visual check across hero/CTA/forum components, and ensure contrast checks pass.
- Add an entry to changelog with reasoning for changes to a color token.

---

For quick access, the file is saved as `docs/color-guidelines.md` in the repo. If you want, I can also:
- Add a `ThemeData` snippet to `lib/` applying these tokens in Flutter.
- Export tokens for Figma / JSON for the design system.
