# UnityHub Design Specification (Figma Blueprint)

This document serves as a high-fidelity design spec for the UnityHub UI, ensuring parity between the code implementation and your Figma designs.

## Core Design Tokens

### 1. Color Palette (Stitch Parity)
- **Primary (Verified)**: `#10B981` (Emerald-500)
- **Secondary**: `#34D399` (Emerald-400)
- **Surface (Card/Bg)**: `#FFFFFF` (Light) / `#111827` (Dark)
- **Error**: `#EF4444` (Red-500)
- **Warning/Pending**: `#F59E0B` (Amber-500)
- **Text (Primary)**: `#111827`
- **Text (Secondary)**: `#6B7280`

### 2. Typography (Inter Font Family)
- **Display Large**: 32px / Bold / 1.25 Line Height (Page Titles)
- **Headline Large**: 24px / SemiBold / 1.33 Line Height (Card Titles)
- **Body Large**: 16px / Regular / 1.5 Line Height (Content)
- **Label Large**: 12px / Medium / 1.33 Line Height (Badges/Status)

### 3. Spacing & Radius
- **Base Grid**: 4px
- **Card Radius**: 16px
- **Button Radius**: 8px
- **Page Padding**: 24px (Mobile) / 32px (Web)

---

## Screen Architecture

### A. Volunteer Experience (Mobile - 390x844)
1. **Map View**: Full-screen Google Map (Silver/Dark Style). Emerald pins for tasks.
2. **Task Tray (Bottom Sheet)**: 16px Top Radius, Glassmorphic background, Emerald CTA.
3. **Verification Step 1**: Full-bleed camera view with an Emerald bounding box (300x300).
4. **Verification Step 2**: Lottie animation center-aligned (Ripple pulse).
5. **Impact Wallet**: Score ring (Circular progress), Badge shelf (Horizontal scroll), List of transaction cards.

### B. NGO Admin Experience (Web - 1440x900)
1. **Side Navigation**: Collapsed icon-only or Expanded with labels.
2. **Dashboard**: KPI Cards (Row), Funnel Bar Chart (Center), Two-column layout for Activity Feed and Leaderboard.
3. **Task Management**: Clean data table with hover states and Status chips.
4. **Report Generator**: Centered layout, Date range picker, Large "Download PDF" primary button.

---

## Design Mockups
Refer to the generated images in the project root for the visual aesthetic guidance.
- ![Volunteer UI](/C:/Users/harsh/.gemini/antigravity/brain/6ab7eb8f-7ef0-4401-abb7-aa323af7c908/unityhub_volunteer_mobile_ui_1777119342464.png)
- ![Admin UI](/C:/Users/harsh/.gemini/antigravity/brain/6ab7eb8f-7ef0-4401-abb7-aa323af7c908/unityhub_admin_dashboard_ui_1777119359053.png)
