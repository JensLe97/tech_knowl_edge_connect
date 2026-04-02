# Design System: TechKnowlEdgeConnect

## Overview

A calm interface designed for modern education and community building.
The aesthetic prioritizes **focus, warmth, and accessibility** through rounded terminals and a neutral-cool palette that reduces eye strain during long study sessions.

## Colors

### Light Theme

- **Primary** (#798EAF): Branding, FABs, and active navigation states
- **Secondary** (#CBD8E6): Secondary buttons and subtle UI highlights
- **Tertiary** (#506686): Accent color for interactive elements and highlights
- **Surface** (#FEF7FF): Clean, paper-like background for readability
- **On-surface** (#1D1B20): High-contrast text for body and headings

### Dark Theme

- **Primary** (#879BBD): Desaturated blue for low-light accessibility
- **Secondary** (#587192): Muted depth for secondary interaction
- **Tertiary** (#6D7F96): Accent color for highlights and interactive elements
- **Surface** (#141318): Deep charcoal for immersive, late-night learning
- **On-surface** (#E6E1E9): Soft white text to prevent "haloing" effects

### Surface Hierarchy & Nesting
Treat the UI as a physical stack of fine paper.
* **Level 0 (Base):** `background` (#141218)
* **Level 1 (Sectioning):** `surface-container-low` (#1D1B20)
* **Level 2 (Cards/Prominence):** `surface-container-highest` (#36343B) — *Used for the Welcome Text containers to ensure maximum contrast and readability.*
## Typography

- **Headlines**: Nunito Sans, semi-bold, 18px (AppBar)
- **Body**: Nunito Sans, regular, Material 2021 weight
- **Labels**: Nunito Sans, bold, 16px for buttons and interactive elements

## Components

- **Buttons**: Rounded (10px), 44px minimum height, Secondary color for primary actions
- **Inputs**: 12px radius, filled background, 1.5px border on focus
- **Cards**: Low-elevation, utilizes 82% opacity (Light) and 35% opacity (Dark)
- **Navigation**: Bottom Bar (8dp elevation) with labeled icons for clear orientation

## Do's and Don'ts

- **Do** use `ElevatedButton` with the Secondary color for a softer visual hierarchy
- **Don't** use ripple effects; `splashColor` is transparent to maintain a static, focused environment
- **Do** apply `Clip.antiAlias` to all containers to ensure smooth, rounded "stitched" corners
- **Don't** use sharp corners; maintain a minimum 8px radius across all UI elements
