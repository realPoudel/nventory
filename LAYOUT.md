# **nVentory Layout & Responsive Design Plan**

This document details the directory/component structure of the **nVentory** Flutter codebase and outlines our comprehensive plan for implementing premium, adaptive, and responsive layouts across all supported form factors: **Mobile**, **Tablet**, and **Desktop**.

---

## **1. App Directory Structure**

The codebase follows a modular design structure, separating core logic, domain models, custom widgets, state management (Riverpod), routing, and screen layouts.

```
lib/
├── core/                         # Core utilities, validation, and error handling
│   ├── errors.dart               # Domain errors & failure representations
│   ├── result.dart               # Functional Result pattern (Ok/Err)
│   └── validators.dart           # Input validation rules (SKU, email, numeric limits)
├── design/                       # UI design system and branding
│   ├── animations.dart           # Standardized micro-animations and transition durations
│   ├── app_color_scheme.dart     # Material Design 3 light/dark color definitions
│   ├── app_colors.dart           # Hex color definitions and functional palettes
│   ├── app_theme.dart            # Complete ThemeData definitions (light & dark modes)
│   └── typography.dart           # Headline, title, body, and caption text styles
├── models/                       # Domain models and persistent data stores
│   ├── category_model.dart       # Inventory categories (with custom colors)
│   ├── employee_model.dart       # Team members (roles, departments, active status)
│   ├── employee_repository.dart  # CRUD repository for employee objects
│   ├── item_model.dart           # Inventory items (SKUs, pricing, stock levels, unit types)
│   ├── repositories.dart         # Core database repositories
│   ├── stock_movement_model.dart # Log entries for stock-in, stock-out, adjustments
│   ├── stock_movement_repository.dart
│   └── task_model.dart           # Tasks assigned to workforce members
├── persistence/                  # Storage drivers and logs
│   ├── hive_manager.dart         # Hive DB initialization and management
│   └── write_ahead_log.dart      # Resiliency logs to prevent transaction loss
├── routing/                      # Application navigation and scaffold
│   ├── app_router.dart           # GoRouter definitions and paths
│   └── app_scaffold.dart         # Navigation shell (Bottom Navigation Bar / Nav Rail)
├── screens/                      # Screen layouts (Feature views)
│   ├── analytics_screen.dart     # KPI summaries, movement activity logs, workforce distribution
│   ├── dashboard_screen.dart     # Dashboard overview, low stock alerts, quick actions
│   ├── employee_detail_screen.dart # Employee stats, contact cards, task board
│   ├── employee_form_screen.dart   # Employee creation and edit forms
│   ├── employees_list_screen.dart  # Team directory with role filter
│   ├── inventory_list_screen.dart  # Searchable, filterable inventory item grid/list
│   ├── item_detail_screen.dart     # Item specifications, history, quick stock adjustment
│   ├── item_form_screen.dart       # Item creation and edit forms
│   ├── reports_screen.dart         # Filterable movement logs, low stock reports, valuation
│   └── settings_screen.dart        # Preferences, appearance toggles, company profile
├── ui/                           # Reusable layout elements
│   └── app_components.dart       # Standard headers, KPI cards, custom dialogs, snackbars
├── main.dart                     # Main entry point and theme router wrapper
├── providers.dart                # Riverpod state providers
└── responsive_breakpoints.dart   # Responsive utilities (breakpoints, extensions, builders)
```

---

## **2. Responsive Framework & Breakpoints**

Our layout decisions are driven by the guidelines in `lib/responsive_breakpoints.dart`:

| Breakpoint Range | Device Target | Navigation Scaffold | Layout Strategy |
|---|---|---|---|
| **< 600px** | Mobile | Bottom Navigation Bar (5 destinations) | Single-column stacked lists, bottom sheets, full-screen dialogs. |
| **600px - 1024px** | Tablet | Left Navigation Rail (Labels shown) | Dual-column grids, master-detail lists, side-by-side forms. |
| **>= 1024px** | Desktop | Left Navigation Rail / Navigation Drawer | Constrained max content width (1200px), multi-column responsive grids, nested split views. |

### **Key Utilities**
*   **`context.isMobile` / `context.isTablet` / `context.isDesktop`**: Used for global, macro-layout decisions (like changing from a NavigationBar to a NavigationRail).
*   **`ResponsiveBuilder`**: Conditionally builds mobile, tablet, or desktop trees.
*   **`ConstrainedContent`**: Centers and bounds the maximum width of list/form views to `Breakpoints.contentMaxWidth` (1200px) on wide displays to prevent text columns from stretching excessively.
*   **`context.gridColumns`**: Dynamically determines grid columns (1 for mobile, 2 for tablet, 3 for desktop).
*   **`context.responsivePadding`**: Scales page margins smoothly (Xs/Sm/Md on mobile, Lg on tablet, Xl on desktop).

---

## **3. Codebase Responsiveness Audit & Roadmap**

An audit of the codebase reveals several missing integrations and layout vulnerabilities on desktop or tablet sizes. Below is the proposed layout plan to address them:

### **A. Navigation Root Scaffold Fix**
*   **Issue**: `RootScaffold` is defined in `lib/main.dart` but is never referenced by the `GoRouter` configuration in `lib/routing/app_router.dart`. As a result, the bottom navigation bar and navigation rail never render, and screens display as standalone pages.
*   **Plan**: Refactor `appRouter` to use a `ShellRoute` (or `StatefulShellRoute`). The shell's builder will wrap sub-routes with `RootScaffold`, ensuring the persistent adaptive navigation layout (Bottom Bar vs Rail) renders correctly and responds dynamically to window resizing.

### **B. List Screens (`InventoryListScreen`, `EmployeesListScreen`)**
*   **Issue**: Both list screens default to a full-screen vertical `ListView.builder`. On large desktop monitors, lists span the full screen width, resulting in poorly aligned text, awkward proportions, and excessive blank space.
*   **Plan**: 
    1.  Wrap the body of both screens in `ConstrainedContent` to cap content width at 1200px.
    2.  Replace the rigid `ListView` with a responsive grid layout using `GridView.builder`.
    3.  Compute grid columns using `context.gridColumns` (1 for Mobile, 2 for Tablet, 3 for Desktop).
    4.  Create a responsive Card-based layout for items and employees that scales elegantly when presented in a grid.

### **C. Form Screens (`ItemFormScreen`, `EmployeeFormScreen`)**
*   **Issue**: Form fields are stacked vertically in a single column stretching the entire width of the display. Dropdowns and text inputs look bizarre when stretched over 1000px.
*   **Plan**:
    1.  Wrap the screen body in `ConstrainedContent` (capped at 800px max width for forms to keep visual focus centered).
    2.  On tablet and desktop, group related fields side-by-side inside `Row` structures (e.g., First Name & Last Name, Cost Price & Selling Price, Quantity & Unit).
    3.  Adjust margins and field paddings using `context.responsivePadding`.

### **D. Detail Screens (`ItemDetailScreen`, `EmployeeDetailScreen`)**
*   **Issue**: Detailed cards and timestamps span the entire screen width. Quick adjustment dialogs lack maximum width constraints in certain states.
*   **Plan**:
    1.  Apply `ConstrainedContent` (capped at 900px) to wrap the scrollable detail layout.
    2.  For Tablet & Desktop, split details into a two-column layout:
        *   **Left Column (60% width)**: Primary details, descriptions, action widgets.
        *   **Right Column (40% width)**: History charts, activity logs, or administrative meta-data (timestamps, audit trail).
    3.  Ensure dialog sheets use `AppDialog.show` to enforce a maximum modal width of 480px.

### **E. Analytics & Reports Screens (`AnalyticsScreen`, `ReportsScreen`)**
*   **Issue**: KPI metrics cards and tables are stacked vertically, causing layout overflow or unnecessary scrolling on desktop screens.
*   **Plan**:
    1.  Apply `ConstrainedContent` (capped at 1200px).
    2.  For dashboard stats and KPI summary metrics, replace standard `Column`/`Row` with `GridView` using `context.gridColumns`.
    3.  Lay out category breakdowns (LinearProgressIndicators) and movement tables side-by-side in a `Row` on desktop screens, rather than stacked vertically.

---

## **4. Unified Responsive Mapping Matrix**

The table below defines how each screen transforms between viewports:

| Screen Name | Mobile Layout (<600px) | Tablet Layout (600px-1024px) | Desktop Layout (>=1024px) | Key Responsive Widgets |
|---|---|---|---|---|
| **App Navigation** | Bottom Nav Bar (No labels) | Left Nav Rail (Icons & Labels) | Wide Nav Rail + Expanded Scopes | `AppScaffold`, `NavigationRail` |
| **Dashboard** | 1-Col Stats, Stacked Alert List | 3-Col KPI cards, Stacked alerts | Grid KPIs (4 columns), Side-by-side lists | `ResponsiveBuilder`, `KpiCard` |
| **Inventory List** | Vertical `ListView` (ListTile) | 2-Column `GridView` (Compact card) | 3-Column `GridView` (Expanded card) | `GridView.builder`, `ConstrainedContent` |
| **Item Details** | Vertical Scroll (Stats Cards) | Split View (60/40 Stats & Adjustments) | Split View (50/50 Stats & History) | `ConstrainedContent`, `Row` |
| **Item Form** | Vertical fields, compact spacing | Multi-col groups, standard margins | Centered form, dual-col sections | `ConstrainedContent`, `Row` |
| **Employee List** | Vertical `ListView` (Initials Avatar) | 2-Column Grid (Grid cards) | 3-Column Grid (Detailed card) | `GridView.builder`, `ConstrainedContent` |
| **Employee Details**| Single-column profile & tasks | Dual-column profile & task board | Dual-column (Left Profile, Right Tasks) | `Row`, `Expanded`, `Flex` |
| **Employee Form** | Vertical forms, default keypad | Multi-col personal / job info | Capped centered panel (800px width) | `ConstrainedContent`, `Row` |
| **Analytics** | Stacked metrics and details | 2-Column metrics grid, simple stats | Multi-column metrics + side-by-side charts | `GridView`, `ResponsiveBuilder` |
| **Reports** | Stacked reports, bottom sheets | Side-by-side reports, modal sheets | Side-by-side tables, permanent filter pane| `Row`, `Expanded`, `AppDialog` |
| **Settings** | Single-column grouped cards | Single-column centered cards | Centered cards (800px max width) | `ConstrainedContent` |

---

## **5. Layout Best Practices for nVentory**

1.  **Do Not Hardcode Dimensions**: Use `MediaQuery` or `BoxConstraints` to calculate sizes. Avoid fixed double values for container widths.
2.  **Ensure Safe Areas**: Wrap critical overlays and margins with `SafeArea` to handle device notches and screen curves.
3.  **Use Flex Factors**: Distribute remaining space inside rows or columns using `Flexible` and `Expanded` widgets.
4.  **Enforce Multi-Column Inputs**: Always group related form fields using `Row` elements when screen width exceeds `Breakpoints.mobile`.
5.  **Always Constrain Content**: Never let screens stretch across the full width of widescreen monitors. Wrap page contents in `ConstrainedContent` to ensure clean readability.