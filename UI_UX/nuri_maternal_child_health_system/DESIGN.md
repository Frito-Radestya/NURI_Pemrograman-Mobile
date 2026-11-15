---
name: NURI Maternal & Child Health System
colors:
  surface: '#f9f9ff'
  surface-dim: '#cfdaf2'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eeff'
  surface-container-high: '#dee8ff'
  surface-container-highest: '#d8e3fb'
  on-surface: '#111c2d'
  on-surface-variant: '#40493d'
  inverse-surface: '#263143'
  inverse-on-surface: '#ecf1ff'
  outline: '#707a6c'
  outline-variant: '#bfcaba'
  surface-tint: '#1b6d24'
  primary: '#0d631b'
  on-primary: '#ffffff'
  primary-container: '#2e7d32'
  on-primary-container: '#cbffc2'
  inverse-primary: '#88d982'
  secondary: '#3e6a00'
  on-secondary: '#ffffff'
  secondary-container: '#b9f474'
  on-secondary-container: '#437000'
  tertiary: '#006419'
  on-tertiary: '#ffffff'
  tertiary-container: '#127f26'
  on-tertiary-container: '#caffc2'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a3f69c'
  primary-fixed-dim: '#88d982'
  on-primary-fixed: '#002204'
  on-primary-fixed-variant: '#005312'
  secondary-fixed: '#b9f474'
  secondary-fixed-dim: '#9ed75b'
  on-secondary-fixed: '#0f2000'
  on-secondary-fixed-variant: '#2e4f00'
  tertiary-fixed: '#94f990'
  tertiary-fixed-dim: '#78dc77'
  on-tertiary-fixed: '#002204'
  on-tertiary-fixed-variant: '#005313'
  background: '#f9f9ff'
  on-background: '#111c2d'
  surface-variant: '#d8e3fb'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 36px
    fontWeight: '800'
    lineHeight: 44px
  headline-xl-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '800'
    lineHeight: 36px
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 30px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1.25rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system translates the nurturing, vital role of maternal and child healthcare into an approachable, trustworthy, and modern mobile experience. Designed for mothers, families, and frontline Posyandu healthcare cadres, the interface projects growth, clarity, empathy, and safety.

The visual style is **Soft Modern Organic**:
- **Organic Curvature & Fresh Gradients:** Inspired by foliage and vitality, generous organic curved header panels (wave gradients) anchor the top viewport, creating warmth without visual clutter.
- **Approachable Clarity:** Interfaces balance high readability with gentle tactile feedback, reducing cognitive friction for healthcare workers recording field data and mothers monitoring child milestones under varied lighting conditions.
- **Friendly Professionalism:** Clean white foreground containers with soft perimeter definition foster confidence, clinical accuracy, and emotional reassurance.

## Colors

The palette balances lush organic greens representing life and vitality with soft clinical neutrals for effortless legibility.

- **Primary (`#2E7D32` - Forest Emerald):** The foundational anchor for major CTAs, active states, key data highlights, and prominent header backgrounds. Conveys clinical reliability and grounded maternal care.
- **Secondary (`#8BC34A` - Leaf Lime):** Used for lively accents, progress metrics (e.g., standard growth curves), positive indicators, and gentle gradient blends.
- **Tertiary (`#4CAF50` - Vitality Green):** Mid-tone bridging green for secondary action buttons, interactive pills, and banner backdrops.
- **Neutral Palette:**
  - Base Background: `#F8FAF8` (warm off-white tinted with gentle leaf undertones to reduce eye strain).
  - Surface Card: `#FFFFFF` (crisp white for distinct hierarchy over tinted backgrounds).
  - Text Primary: `#1E293B` (deep charcoal-slate providing accessible contrast above WCAG AAA standards).
  - Text Muted: `#64748B` (refined slate for labels, helper strings, and inactive states).
  - Border Subdued: `#E2E8F0` with a hint of olive (`#E5EBE3`).
- **Semantic Accents:**
  - Growth Warning / Alert: `#F59E0B` (Amber) and `#EF4444` (Coral Red).
  - Immunization / Scheduled: `#0284C7` (Sky Blue) and `#8B5CF6` (Lavender).

## Typography

The typography leverages **Plus Jakarta Sans** across all roles to combine geometric cleanliness with open, approachable letterforms. This ensures instant comprehension of vital health statistics, infant weights, vaccination dates, and nutritional guidelines.

- Headings use medium to bold weights (`600` to `800`) to provide instant visual scanning.
- Numbers within tables and medical metric summaries leverage tabular numerical alignment where needed.
- Letter spacing remains tight on display titles (`-0.02em`) to maintain cohesion and slightly relaxed on labels (`+0.01em`) for legibility on small screens.

## Layout & Spacing

The layout is built upon an 8pt spatial grid designed for mobile-first handheld usage by cadres and mothers:

- **Mobile Viewport (360px - 480px):** 4-column layout with `1rem` (16px) margins and `0.75rem` (12px) gutters. Essential controls remain in the lower two-thirds reach zone.
- **Tablet / Large Screen (768px+):** 8-column layout with `1.5rem` (24px) gutters, centering max-width card containers (up to 640px for single flows or 960px for split-pane cadre registry views).
- **Curved Header Panels:** Top canvas features an organic downward convex curve (`border-bottom-left-radius: 2rem; border-bottom-right-radius: 2rem`) containing high-priority user status, search, and navigation controls.

## Elevation & Depth

Visual hierarchy uses a hybrid of organic tonal layering, subtle gradient depth, and warm diffused shadows:

- **Level 0 (Flat Ground):** Background surfaces tinted `#F8FAF8` or primary gradient bands (`linear-gradient(135deg, #2E7D32 0%, #4CAF50 60%, #8BC34A 100%)`).
- **Level 1 (Card Surfaces):** Crisp `#FFFFFF` containers styled with a soft perimeter line (`border: 1px solid #EBF1EA`) paired with a diffused ambient shadow: `box-shadow: 0 4px 16px -2px rgba(46, 125, 50, 0.06), 0 2px 6px -1px rgba(0, 0, 0, 0.03)`.
- **Level 2 (Interactive Floating Elements):** Action buttons, category circles, and dialogs: `box-shadow: 0 8px 24px -4px rgba(46, 125, 50, 0.16)`.
- **Level 3 (Floating Bottom Bar & Central Action Button):** Bottom navigation floats over the base canvas with `0 12px 32px rgba(30, 41, 59, 0.08)`. The prominent central circular action button uses an energetic gradient overlay with an amplified glow: `box-shadow: 0 8px 20px rgba(46, 125, 50, 0.35)`.

## Shapes

The design system adopts a welcoming **Rounded** language (Level 2) with selective pill-shaped accents:
- **Cards and Containers:** `1rem` (16px) to `1.5rem` (24px) border radius, giving cards a friendly, non-intimidating appearance.
- **Badges, Filter Chips, and Primary Input Fields:** Full pill roundedness (`9999px`) to match the soft approachable visual language seen in modern lifestyle and consumer health applications.
- **Top Bar Curve:** Large organic arc spanning the bottom of the top header (`1.75rem` - `2rem`).
- **Floating Bottom Navigation Bar:** `1.5rem` (24px) rounded dock with an elevated circular cutout for the primary central button.

## Components

### 1. Buttons
- **Primary Action Button:** Gradient pill or rounded rect (`#2E7D32` to `#4CAF50`), white bold text, minimum height 48px for thumb comfort during field entry. Hover/press shifts brightness by 6% with subtle scale feedback (`0.98`).
- **Center Floating Action Button (FAB):** Circular (56px × 56px), protruding above the bottom navigation bar. Vibrant gradient fill with an icon (e.g., Quick Add Child Record or Weigh-in).
- **Secondary / Ghost Button:** Light mint background (`#E8F5E9`), dark green text (`#2E7D32`), 0px border.

### 2. Status Chips & Filter Pills
- Fully rounded pills (`border-radius: 9999px`) with generous horizontal padding (`12px` to `16px`).
- Inactive: `#F1F5F0` background with `#4B5563` text.
- Active: Vibrant gradient (`#2E7D32` to `#4CAF50`) with `#FFFFFF` text and subtle lift.
- Health status variants (e.g., "Gizi Baik", "Jadwal Imunisasi", "Perlu Perhatian"): Soft pastel backings (e.g., `#DCFCE7` with `#166534` text; `#FEF3C7` with `#B45309` text).

### 3. Cards (Baby & Mother Profile, Metric Cards)
- Pure white `#FFFFFF` surface with `1.25rem` (20px) radius and gentle border `#EAEFE9`.
- Includes avatar thumbnail with green status ring, primary measurement metric badges (Weight, Height, Age), and clear chevron for detailed records.

### 4. Input Fields
- Enclosed pill or rounded 14px inputs with `#F8FAF8` background, `#E2E8F0` subtle boundary.
- Focused state transitions to `#2E7D32` border with a 3px soft green glow ring (`rgba(46, 125, 50, 0.15)`).
- Left-aligned leading icons (e.g., Search, Calendar, Scale) rendered in `#64748B`.

### 5. Floating Bottom Navigation Bar
- Elevated capsule floating 16px above the device safe area, width spanning `calc(100% - 32px)`.
- Pure white backdrop with soft glass backdrop blur (`backdrop-filter: blur(12px)`).
- 5-slot item arrangement with icon and micro label (`11px`), with the center position accommodating the elevated, glowing action button.

### 6. Lists & Health Metric Trackers
- Divided by soft whitespace (`0.75rem`) rather than hard stroke dividers.
- Visual progress bars (KMS / Kartu Menuju Sehat charts) styled with smooth curved pill segments using `#8BC34A` and `#2E7D32`.