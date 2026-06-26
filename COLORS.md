# nVentory Color System — Material Design 3 Color Roles

## Seed Token

**Olive Drab** `#6B8E23` — the canonical root from which all tonal variants derive.

---

## Light Mode Hierarchy (Seed: #6B8E23)

| MD3 Role | Hex | Use Case |
|---|---|---|
| `primary` | `#4C662B` | FABs, main action buttons, active states |
| `onPrimary` | `#FFFFFF` | Text/icons over primary backgrounds |
| `primaryContainer` | `#CDEDA3` | Chips, search bar highlights, accent banners |
| `onPrimaryContainer` | `#102000` | Titles/labels inside primary containers |
| `secondary` | `#8FBC8F` | Supportive elements, secondary buttons |
| `secondaryContainer` | `#E8F5E9` | Secondary accent backgrounds |
| `tertiary` | `#9ACD32` | Accent highlights, badges |
| `surface` | `#FAFAF5` | App background |
| `surfaceContainer` | `#F3F6EB` | Standard card surfaces, sheets, system bars |
| `surfaceContainerHighest` | `#F0F0EB` | Elevated card surfaces |
| `onSurface` | `#1A1C18` | Primary text on surfaces |
| `onSurfaceVariant` | `#49454F` | Secondary text, metadata |
| `outline` | `#75796C` | Input field boundaries, borders, splitters |
| `outlineVariant` | `#C5C5BA` | Subtle dividers |
| `inverseSurface` | `#1A1C18` | Dark contrast surface (snackbars) |
| `inversePrimary` | `#B2D189` | Light primary for dark mode inversion |
| `error` | `#D32F2F` | Error states, destructive actions |
| `onError` | `#FFCDD2` | Text on error backgrounds |

## Dark Mode Hierarchy

| MD3 Role | Hex | Use Case |
|---|---|---|
| `primary` | `#B2D189` | Dominant elements requiring emphasis in low light |
| `onPrimary` | `#1F3701` | Dark text mapping safely over light primary blocks |
| `primaryContainer` | `#354E16` | Subtle accent banners, structural contextual layouts |
| `onPrimaryContainer` | `#CDEDA3` | High readability content on dark containers |
| `secondary` | `#B8D8B8` | Secondary elements in dark mode |
| `surface` | `#1A1C18` | App background |
| `surfaceContainer` | `#1D2118` | Card surfaces in dark mode |
| `surfaceContainerHighest` | `#2A2C26` | Elevated card surfaces |
| `onSurface` | `#E6E1E5` | Primary text on dark surfaces |
| `onSurfaceVariant` | `#CAC4D0` | Secondary text in dark mode |
| `outline` | `#4A4A3E` | Input boundaries in dark mode |
| `inverseSurface` | `#FAFAF5` | Light contrast surface |
| `inversePrimary` | `#4C662B` | Dark primary for light mode inversion |
| `error` | `#FFB4AB` | Softer error for dark backgrounds |

---

## Component Role Cheat Sheet

| UI Component | Background | Foreground |
|---|---|---|
| App Top Bar | `colorScheme.surface` | `colorScheme.onSurface` |
| FAB | `colorScheme.primary` | `colorScheme.onPrimary` |
| Action Chips (inactive) | `colorScheme.surfaceContainerLow` | `colorScheme.onSurfaceVariant` |
| Action Chips (selected) | `colorScheme.secondaryContainer` | `colorScheme.onSecondaryContainer` |
| Form Input Border | `colorScheme.outline` | — |
| Form Input Focus | `colorScheme.primary` (2px) | — |
| Form Validation Error | `colorScheme.error` | `colorScheme.onErrorContainer` |
| Card Surfaces | `colorScheme.surfaceContainerHighest` | `colorScheme.onSurface` |
| Navigation Bar | `colorScheme.surface` | `colorScheme.onSurface` (selected) |
| Navigation Rail | `colorScheme.surface` | `colorScheme.onSurfaceVariant` (unselected) |
| Snackbar | `colorScheme.inverseSurface` | `colorScheme.onInverseSurface` |
| Destructive Button | `colorScheme.error` | `colorScheme.onError` |

---

## Architecture

```
lib/design/
├── app_colors.dart       ← Static hex definitions (seed + tonal hierarchy)
├── app_color_scheme.dart ← Full MD3 ColorScheme (light + dark)
├── app_theme.dart        ← ThemeData with component overrides (PRIMARY)
├── olive_theme.dart      ← Seed-based alternative via ColorScheme.fromSeed()
└── typography.dart       ← Text styles (font-agnostic of color)
```

**Two theme strategies:**
1. **`AppTheme`** (primary) — hand-crafted values for maximum brand control
2. **`OliveTheme`** (alternative) — algorithmic `ColorScheme.fromSeed()` for guaranteed contrast

Both produce identical component styling; only the color palette generation method differs.
