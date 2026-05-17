# anzacivic.org modernization — design spec

**Date:** 2026-05-17
**Reference mockup:** `.superpowers/brainstorm/1128-1779039464/content/homepage-proof-v5.html` (committed to repo as `docs/superpowers/mockups/homepage-v5.html`)

## Goal

Modernize anzacivic.org while preserving its identity. The current site (mirrored under `site/`) is a 2010-era table-layout HTML page — not mobile-responsive, decorative `frame-*.jpg` graphics, stale copyright. We are rebuilding it as plain HTML/CSS that:

- Looks contemporary but recognizably the same site
- Works on phones
- Is editable by Claude in future sessions without a build step
- Adds three new features (Google Calendar embed, photo gallery, rental inquiry form) — but only after foundation ships

## Direction

Style direction **H ("Refined Heritage")** — same skeleton as the existing site (centered card on warm background, logo on top, horizontal nav, sectioned content, footer), refined palette and typography, real photography of the schoolhouse. Tone is **warm and community**.

Five other directions were explored and rejected; see `feedback-keep-existing-layout` memory.

## Design system

### Colors (CSS custom properties)

```
--bg-page:      #efd886   /* warm gold page background */
--bg-card:      #fdfaf2   /* cream content card */
--bg-card-deep: #f6efdc   /* deeper cream for alternating sections */
--ink:          #2a221a   /* primary body text */
--ink-soft:     #5c4a2a   /* secondary text */
--ink-mute:     #8a7a55   /* tertiary / meta text */
--rule:         #ede2c4   /* hairline dividers */
--rule-deep:    #d4c290   /* stronger dividers */
--red:          #8b1a1a   /* primary accent (headings, links, active nav) */
--red-deep:     #6e1313   /* hover/active red */
--gold:         #c49c00   /* secondary accent (eyebrows, nav underline) */
--gold-deep:    #a78400   /* darker gold */
--cream-dark:   #3a2e1a   /* footer & dark CTA background */
```

### Typography

- **Headings:** Lora (Google Fonts), italic for section titles, weights 500/600/700
- **Body & UI:** Inter (Google Fonts), weights 400/500/600/700, fallback system sans
- **Loaded via:** single `<link>` to fonts.googleapis.com in each page's `<head>`

### Layout

- Page background `--bg-page`
- Content lives in a centered `.page` div, `max-width: 920px`, `border-radius: 6px`, soft shadow
- Sections alternate `--bg-card` and `--bg-card-deep` for visual rhythm
- All page-level sections have `padding: 40px 32px` desktop / `28px 20px` mobile
- Responsive breakpoint at **720px** (single CSS file, no media-query proliferation)

### Components

- `.topbar` — slim contact strip above masthead (address · phone · email)
- `.masthead` — logo (ACIL-Logo.png, transparent, 340px wide desktop / 260px mobile) + tagline
- `nav.primary` — horizontal flex nav, 9 items, active state via red underline
- `.hero` — two-column on desktop (`440px` postcard image + flexible text), stacked on mobile
- `.postcard` — white frame with `transform: rotate(-1deg)`, tilted card containing photo + caption
- `.section`, `.section-eyebrow`, `.section-title`, `.section-body` — standard content section pattern
- `.three-up` — three-column feature card grid; collapses to 1 column on mobile
- `.then-now-grid` — two-column historical/current photo pair; collapses to stacked
- `.event` — calendar list-item with date block + title + meta + link
- `.cta-row` — dark cream-on-dark callout strip with primary button
- `.btn` / `.hero-cta` — primary action buttons, gold on dark or red on light

All component CSS lives in **one shared `site/styles.css`** loaded by every page.

## File structure (post-rebuild)

```
site/
  styles.css                # shared CSS for all pages
  index.html                # homepage (per mockup)
  history.html              # renamed from about.html — org history + then/now narrative
  rent.html                 # renamed from rental.html — rental info, schoolhouse + park
  calendar.html             # Phase 3: Google Calendar embed
  anza_days.html            # Anza Days event landing page
  gallery.html              # Phase 3: photo gallery (new file)
  join.html                 # membership / annual dues
  volunteer.html            # volunteer opportunities
  give.html                 # renamed from donate.html — donations, brick paver program
  404.shtml                 # modernized error page
  images/                   # photo + logo assets
  IMAGES/                   # legacy mirror (server has duplicate dirs, see memory)
  docs/                     # historical PDFs/forms (kept as-is)
  DOCUMENTS/                # current PDFs/forms (kept as-is)
```

Each HTML page follows the same skeleton — `<head>` with fonts + stylesheet, `<body>` with `.page > .topbar + .masthead + nav.primary + (page-specific content) + footer`. Shared markup blocks (`.topbar`, `.masthead`, `nav.primary`, `footer`) are wrapped in HTML comments like `<!-- @begin:topbar -->` and `<!-- @end:topbar -->` so Claude can locate and update them consistently across files without templating.

## Page-by-page spec

### index.html (Phase 1)
Implements the v5 mockup. Sections in order: topbar → masthead → nav → hero (postcard + text) → "Our Purpose" → "Then & now" (2-up photo grid) → "Visit · Rent · Give" (3-up cards) → "What's happening at the park" (events list, hand-curated placeholder until Calendar embed lands) → "Have an event in mind?" (CTA row) → footer.

### history.html (Phase 2)
Org founding story (1914 schoolhouse, ACIL's role), restoration history, then/now photo pairing larger than homepage, board/officer list if available. Replaces `about.html`.

### rent.html (Phase 2 layout, Phase 3 form)
Rental information — schoolhouse and park separately, pricing if public, what's included, photos. Phase 2 ships with a "Download the application PDF" link to the existing forms in `DOCUMENTS/`. Phase 3 adds an inline inquiry form (see below).

### calendar.html (Phase 3)
Single Google Calendar iframe embed, styled to fit page width responsively. Requires a Google Calendar URL/ID from ACIL — until then, page shows a hand-curated event list matching the homepage.

### anza_days.html (Phase 2)
Annual Anza Days event landing page. Date, schedule, parade info, vendor info (link to PDFs already in `DOCUMENTS/`). Photo strip from past years (sourced from gallery).

### gallery.html (Phase 3)
CSS Grid of captioned photos, organized by section (Schoolhouse, Park, Anza Days, Rentals). Hand-coded HTML, growing over time. Each photo's `<figure>` has `<img>` + `<figcaption>`. Lazy-load via `loading="lazy"`.

### join.html (Phase 2)
Membership tiers, what membership funds, current PayPal button retained (`hosted_button_id=EQCYCXWPTYVB4` per existing code), printable application link.

### volunteer.html (Phase 2)
Volunteer opportunities, sign-up call-to-action (initially `mailto:` link, Phase 3 form later if desired).

### give.html (Phase 2)
Donation options: PayPal donate button (`hosted_button_id=BG8648D8ZH54Q` per existing code), brick paver program (link to `docs/ACIL brick-flyer.pdf`), Veterans Paver program (link to existing PDF).

### 404.shtml (Phase 2)
Same chrome (topbar, masthead, nav, footer) with a centered "this page isn't here" message and a button back to home.

## Phase 3 features — implementation notes

### Google Calendar embed
Standard `<iframe src="https://calendar.google.com/calendar/embed?src=...">` wrapped in a responsive container (`.calendar-embed { aspect-ratio: 4/3; }`). Requires the Google Calendar ID — owner to provide.

### Photo gallery
Pure CSS Grid (`grid-template-columns: repeat(auto-fill, minmax(220px, 1fr))`). Each photo is a `<figure>` with caption. Manual curation — no JS, no lightbox initially. May add a small lightbox script in a later iteration if desired.

### Rental inquiry form
Backend: **Formspree** (free tier, ~50 submissions/month). Form fields: name, email, phone, requested date, alternate date, event type (dropdown), expected attendees, message. Submission goes to `anzacivic@gmail.com`. Includes anti-spam honeypot field. Requires creating a Formspree account — owner to set up; spec only requires the endpoint URL.

## Photo plan

**Currently have (in `images/`):**
- `school-current.jpg` (480×480) — color photo of schoolhouse with park sign
- `school-old.jpg` (2048×1427) — historical B&W photo of schoolhouse
- `ACIL-Logo.jpg` (265×100, in `site/IMAGES/`) — current logo
- `ACIL-Logo.png` (265×100, in `site/IMAGES/`) — same logo with transparent background (generated by `scripts/make-logo-transparent.ps1`)

**Need (Phase 2 / Phase 3):**
- Higher-resolution logo (530×200+) for sharp retina display
- Interior photos of the schoolhouse
- Park photos (different seasons, the brick walkway, the stone wall, the rental setup)
- Anza Days event photos (parade, vendors, crowds)
- Wedding/rental event photos (with permission)
- Board / volunteer group photos

These are referenced as TODOs in the mockup with placeholder/empty-state treatment until added.

## Content updates

- **Copyright:** "© 2013-2019" → "© 2026 ACIL"
- **Page renames** (preserve old URLs via redirect or keep both filenames during transition):
  - `about.html` → `history.html`
  - `rental.html` → `rent.html`
  - `donate.html` → `give.html`
- **New pages:** `gallery.html`, `styles.css`
- **Remove:** `home.html` (the GoDaddy placeholder, not linked from anywhere)
- **Decorative assets to remove from active use** (keep in IMAGES/ for archive):
  - `frame-top.jpg`, `frame-middle.jpg`, `frame-btm.jpg`
  - `tab.gif`, `bkgd-blend.jpg`, `bkgd-main.jpg`
- **`links.html`:** orphan in current site (not in nav). Decide whether to integrate or drop. Default: drop, since not linked.

## Deployment

- Local working dir: `E:\anza_civic\site\`
- Push to production via `winscp.com /script=E:\anza_civic\.winscp\upload.txt`
- The upload script uses `synchronize remote` **without** `-mirror` — never enable mirror (see `feedback-no-mirror-upload` memory; server has case-collision `images/`+`IMAGES/` that Windows merged locally)
- After uploading, verify on https://anzacivic.org — the FTP server is `anzacivic.org`, not `ftp.anzacivic.org`

## Phasing (per user choice: "Homepage first as design proof")

**Phase 1 — Foundation (this iteration):**
1. Extract shared CSS into `site/styles.css` from the v5 mockup
2. Build the real `site/index.html` using `styles.css` and real image paths
3. Wire up the transparent-PNG logo in the masthead
4. Verify locally in browser (open `site/index.html` directly)
5. User approval gate — does the real coded homepage match the mockup feel?

**Phase 2 — Propagation:**
6. Apply the same chrome (masthead, nav, footer) and design system to all other 7 pages
7. Adapt page-specific content into the new sectioning
8. Delete `home.html`, decide on `links.html`
9. Update `404.shtml` to use the new chrome

**Phase 3 — New features (gated on owner-provided prereqs):**
10. Google Calendar embed (needs Calendar ID)
11. Gallery (needs photo curation)
12. Rental inquiry form (needs Formspree account / endpoint)

Phase 1 ships when the homepage is approved. Phases 2 and 3 may overlap or reorder based on priority.

## Open TODOs / known limitations

- Logo at 265×100 will be slightly soft when displayed at 340px (1.28× upscale). Acceptable for now; replace with retina version when available.
- `images/` and `IMAGES/` duplicate dirs on the server are intentionally left untouched (see deployment notes).
- The PayPal hosted_button_ids in the current site are preserved as-is; we are not changing the donation flow in this redesign.
