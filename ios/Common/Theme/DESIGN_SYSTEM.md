# Design System

This app uses a lightweight, code‑first design system centered around a global, observable theme. The theme is injected into the SwiftUI environment and can be read and updated from anywhere.

## Core Types

- `AppTheme` (see `ios/Common/Theme/AppTheme.swift`):
  - `mode`: `.system | .light | .dark` — determines whether to follow system color scheme or force a palette.
  - `Palette`: `primary`, `secondary`, `accent` colors for semantic usage across the UI.
  - `light` / `dark`: independent palettes for each appearance.
  - Mutation APIs: `setMode(_:)`, `setPrimary(_:forDarkMode:)`, `setSecondary(_:forDarkMode:)`, `setAccent(_:forDarkMode:)`.

## Environment Injection

Inject a single `AppTheme` instance as early as possible (app/root view) so all screens share it:

```
@State private var theme = AppTheme()

var body: some View {
  RootView()
    .environment(theme)
}
```

Read it anywhere:

```
@Environment(AppTheme.self) var theme
@Environment(\.colorScheme) var colorScheme
let palette = theme.palette(for: colorScheme)
```

Update globally (propagates live):

```
theme.setMode(.dark)
theme.setAccent(.pink)
theme.setPrimary(.black, forDarkMode: false)
```

## Usage Guidelines

- Colors
  - Use `palette.primary` for primary text and high‑emphasis elements.
  - Use `palette.secondary` for secondary text and chrome.
  - Use `palette.accent` for interactive or attention‑drawing affordances (buttons, highlights, chips).
  - Avoid hard‑coding `Color.*` directly in feature code. If needed, wrap as computed colors in the theme.

- Typography
  - Default font is the system monospaced design at the screen level (see Calendar), but features may opt out where readability requires proportional type.
  - Title: `title3`–`title2` for event titles/section primaries.
  - Meta/time: `subheadline` with medium weight; use `palette.accent` to improve scannability.
  - Secondary copy: `footnote` with `palette.secondary`.

- Spacing & Layout
  - Lists: prefer `.listStyle(.plain)`; create separation using subtle cards (rounded corners, low‑alpha strokes) rather than heavy dividers.
  - Section headers: `subheadline.weight(.medium)` with `palette.secondary` and minimal accessories.
  - Event rows: include a thin accent rail for quick visual orientation.

## Example: Event Row

`EventRowView` demonstrates the pattern:

- Accent rail uses `palette.accent`.
- Title uses `palette.primary` and `title3.semibold`.
- Time uses `subheadline.medium` in `palette.accent`.
- Description uses `footnote` in `palette.secondary`.

## Extending the Theme

If new semantic roles arise (e.g., `warning`, `success`), extend `Palette` with additional colors and add corresponding setters on `AppTheme`. Favor semantic names over raw colors in feature code.

## Testing

- Prefer snapshot/testing of business logic; for UI you can verify that views read `AppTheme` and render with palette colors.
- When testing deterministic colors, pass a `theme` with fixed palettes into `.environment(theme)`.

