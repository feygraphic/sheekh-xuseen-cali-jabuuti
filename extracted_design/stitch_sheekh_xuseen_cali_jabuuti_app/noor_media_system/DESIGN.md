---
name: Noor Media System
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#3f4851'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#707882'
  outline-variant: '#bfc7d2'
  surface-tint: '#00639a'
  primary: '#006096'
  on-primary: '#ffffff'
  primary-container: '#007abc'
  on-primary-container: '#fdfcff'
  inverse-primary: '#96ccff'
  secondary: '#4b6078'
  on-secondary: '#ffffff'
  secondary-container: '#cbe2fe'
  on-secondary-container: '#4f657c'
  tertiary: '#8d4b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#b15f00'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#cee5ff'
  primary-fixed-dim: '#96ccff'
  on-primary-fixed: '#001d32'
  on-primary-fixed-variant: '#004a75'
  secondary-fixed: '#cfe5ff'
  secondary-fixed-dim: '#b2c9e4'
  on-secondary-fixed: '#041d32'
  on-secondary-fixed-variant: '#33495f'
  tertiary-fixed: '#ffdcc3'
  tertiary-fixed-dim: '#ffb77d'
  on-tertiary-fixed: '#2f1500'
  on-tertiary-fixed-variant: '#6e3900'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  title-arabic:
    fontFamily: Amiri
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 30px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-arabic:
    fontFamily: Amiri
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 26px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '500'
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
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

This design system establishes a spiritual, tranquil, and modern mobile experience dedicated to the Islamic lectures and teachings of Sheekh Xuseen Cali Jabuuti. The visual voice blends dignified Islamic aesthetic heritage with modern Android Material 3 design paradigms. 

The aesthetic is clean, devotional, and content-focused. Rather than cluttering the screen with dense ornamentation, it utilizes subtle arabesque geometric motifs as faint watermark accents, allowing modern typographic balance, generous white space, and high-legibility audio scrubbers to lead the user experience. The atmosphere conveys deep spiritual calm, reliability, and academic clarity for Somali and global Islamic audiences.

## Colors

The palette balances uplifting tranquility with scholarly authority:
- **Primary (`#0288D1`)**: Vibrant Islamic sky blue, derived from the signature app bar and active audio player controls, representing serenity and clarity.
- **Secondary (`#0D253A`)**: Deep midnight slate and navy, providing grounded structural weight, deep contrast for typography, and stable surfaces for bottom bars and headers.
- **Tertiary (`#D97706`)**: Warm amber gold, used sparingly for active playback states, sacred marks, bookmark flags, and high-value spiritual badges.
- **Neutral (`#F8FAFC`)**: A cool, crisp background slate tint that prevents eye strain while making pure white (`#FFFFFF`) elevated media cards stand out cleanly.

Text rendering relies on high-contrast pairings: high-emphasis titles use `#0F172A` (Slate 900), medium body lines use `#475569` (Slate 600), and border separators use subtle `#E2E8F0` (Slate 200).

## Typography

Typography prioritizes bilingual harmony between Somali (Latin script) and Arabic (Naskh script). **Plus Jakarta Sans** provides rounded, friendly geometric clarity for all Latin UI elements, timestamps, metadata, and Somali transcript titles (`muxaadaroyinka`). 

For Arabic religious titles (`محاضرة الشيخ حسين علي`), the system couples **Amiri** with calibrated generous line-heights (`line-height: 1.6 - 1.8`) to avoid diacritic clipping and honor classical calligraphic balance.

## Layout & Spacing

The layout is built for native mobile ergonomics following a standard 4-column fluid mobile grid with 16px (`1rem`) outer margins and 16px gutters. 

Vertical cadence adheres to an 8pt baseline rhythm:
- Micro spacing (badges, pill insets, track numbers): 4px - 8px
- Component internal padding (cards, list cells): 12px - 16px
- Section gaps (player sheet, carousel dividers, playlist items): 16px - 24px

Screen edges maintain a dedicated safe area buffer for notch regions and bottom gesture bars, ensuring full-height media drawers and fixed audio minipill bars never obscure touch targets.

## Elevation & Depth

Visual hierarchy combines tonal surface layering with soft ambient lighting rather than heavy drop shadows:
- **Surface Level 0 (Base)**: `#F8FAFC` background canvas.
- **Surface Level 1 (Cards & Lists)**: `#FFFFFF` with a subtle outline (`border: 1px solid rgba(226, 232, 240, 0.8)`) paired with a diffused ambient shadow: `box-shadow: 0 4px 16px -2px rgba(15, 23, 42, 0.04)`.
- **Surface Level 2 (Mini-Player & Floating Dock)**: Elevated white or tinted deep navy container with `box-shadow: 0 8px 24px -4px rgba(2, 136, 209, 0.12), 0 2px 6px 0 rgba(15, 23, 42, 0.04)`.
- **Surface Level 3 (Modals & Full Audio Sheet)**: High-altitude surface with backdrop blur filter (`backdrop-filter: blur(12px)`) and smooth top edge sheet radiuses.

## Shapes

The design uses a rounded visual language (`roundedness: 2`) balancing contemporary software polish with organic warmth:
- Standard audio lecture cards and featured carousels use `16px` border radii.
- Track index avatars, active track icons, and small thumbnail media containers utilize `12px` rounded squares or full circular shapes.
- Filter chips, tag labels, audio playback progress capsules, and primary pill action buttons employ full pill geometry (`9999px`).

## Components

### Audio Lecture Cards & List Items
- **Structure**: Horizontal card format featuring a left-aligned circular or rounded-square index/status badge (e.g., track number or playback equalizer), a middle stacked text column (Arabic title primary, Somali subtitle secondary), and a right-aligned action node (audio wave indicator, bookmark, or download action).
- **Surface**: Pure white (`#FFFFFF`) with 16px corner radius, 12px internal padding, and a 1px border (`#E2E8F0`). On active playback, the border transitions to vibrant sky blue (`#0288D1`) with a subtle 5% blue tint on the background.

### Audio Waveform & Player Controls
- **Waveform**: Vertical bar visualizer with dynamic heights, rendering unplayed portions in muted slate (`#CBD5E1`) and played sections in primary sky blue (`#0288D1`) with a golden tertiary scrubber handle (`#D97706`).
- **Main Player Controls**: Play/pause floating circle button (56px) finished in gradient sky blue (`#0288D1` to `#00A0DC`) with white icons, flanked by secondary rewind/forward jump controls (30s) in slate navy.

### Chips & Pill Tags
- **Categories**: Series parts ("Qaybta 1aad", "Qaybta 2aad") wrapped in pill chips with 6px vertical and 12px horizontal padding.
- **States**: Inactive chips sit on slate surfaces (`#F1F5F9`) with slate-700 text; active selected chips feature a sky blue fill with crisp white text.

### Bottom Navigation Bar
- **Architecture**: Material 3 navigation bar with 80px fixed height, containing icon-plus-label targets for "Muxaadaro" (Lectures), "Silsilado" (Series), "Kuwa La Degsaday" (Downloads), and "Dejinta" (Settings).
- **Indicator**: Active destinations use an elongated pill indicator in soft blue tint (`#E0F2FE`) housing an active icon colored in `#0288D1`.