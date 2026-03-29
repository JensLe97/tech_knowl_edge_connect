---
name: "ux-designer"
description: "Assist with UX design tasks for a Flutter app: audits, wireframes, component guidance, theming, and accessibility with German-first localization."
metadata:
  title: "UX Designer (Flutter)"
  tags:
    - ux
    - flutter
    - design
    - accessibility
    - localization
    - firebase
  applyTo:
    - repository
---

# UX Designer (Flutter)

Purpose

- Provide a repeatable UX design workflow tailored to Flutter apps. Produces audits, component recommendations, wireframe descriptions, accessibility checks, localization notes (German default), and implementation hints for Flutter widgets.

When to use

- When you need a design audit, layout/wireframe guidance, theming recommendations, accessibility review, or a component implementation plan for the repository.

Inputs

- `design_goals` (string): primary goals or problems to solve.
- `target_platforms` (array): e.g., ["android","ios","web"].
- `focus_pages` (array, optional): paths or page names to examine (e.g., `lib/pages/home`).
- `constraints` (object, optional): visual brand, color limits, accessibility standards, performance targets.
- `deliverables` (array): list of required outputs (e.g., ["audit.md","wireframes","component_list","pr_checklist"]).

Step-by-step workflow

1. Repo scan: Note relevant files and assets to inspect (e.g., `lib/theme.dart`, `lib/pages/`, `images/`, `lib/components/`).
2. Context & goals: Confirm `design_goals`, target platforms, and constraints.
3. Heuristic audit: Produce a short `audit.md` with issues by severity (usability, accessibility, localization, performance).
4. Theming & tokens: Recommend color adjustments, contrast checks, typography, and suggest `ThemeData` updates or color tokens consistent with `lib/theme.dart`.
5. Wireframes & layout guidance: Provide textual wireframes for requested pages and responsive behavior per platform.
6. Component list: Enumerate reusable components (name, props, accessibility notes) and include small Flutter widget snippets or `Widget` API suggestions.
7. Accessibility & localization: Run checklist for a11y and German localization (date/number formats, text length), and flag strings in code for `l10n` extraction.
8. Implementation checklist: Produce `pr_checklist` covering visual tests, device sizes, accessibility tests, and localization checks.
9. Deliver final artifacts and suggested next steps (Figma spec, tickets, or PR template).

Outputs

- `audit.md` — summarized issues + prioritized fixes.
- `wireframes/<page>.md` — textual wireframe and responsive notes.
- `components.md` — list of reusable components and examples.
- `pr_checklist.md` — checklist for PR reviewers.
- Optional: small code snippets or patch suggestions (copy-paste-ready Flutter snippets).

Quality criteria

- Contrast ratio >= 4.5:1 for body text where possible.
- All interactive elements keyboard and screen-reader reachable.
- Strings marked for localization; no hard-coded German/English only strings in UI code.
- Layouts adapt to small, medium, and large viewports.

Examples (prompts to use this skill)

- "Audit accessibility and localization for `lib/pages/home.dart` with `design_goals`: better readability and German localization."
- "Create wireframe and component list for Landing and Profile pages for Android and Web."
- "Suggest theme token changes to improve contrast in dark mode and produce Flutter `ThemeData` snippet."

Notes and implementation hints

- Inspect existing `lib/theme.dart` and `lib/components/` before proposing tokens or components.
- For localization, prefer the project's existing `l10n` setup; if missing, recommend `flutter_localizations` and `intl` extraction steps.
- If Firebase-backed content affects layouts (e.g., learning bites), note asynchronous loading states and placeholder patterns.

Testing / Validation

- Ask for screenshots or run visual checks on key screen sizes.
- Validate all string replacements by searching for string literals under `lib/`.

Related skills

- `agent-customization` — to refine the skill's prompts and frontmatter.

Security & Permissions

- No secrets required. May request read access to repo files (automatically granted when running in repo-scoped Copilot sessions).

Next steps after using the skill

- Create `design/` artifacts, open issues for high-priority fixes, or draft PRs with sample widget updates.

---
