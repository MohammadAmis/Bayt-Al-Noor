```markdown
# Design System Document: The Sacred Rhythm

## 1. Overview & Creative North Star
### Creative North Star: "The Celestial Compass"
This design system moves away from the utilitarian "alarm clock" aesthetic of traditional prayer apps. Instead, it adopts the persona of a **Celestial Compass**—a sophisticated, editorial experience that mirrors the rhythmic, cyclical nature of spiritual life. 

To break the "template" look, we employ **Intentional Asymmetry** and **Tonal Depth**. We eschew rigid grids in favor of a "Golden Ratio" inspired layout where elements breathe. By utilizing a high-contrast typography scale (pairing a timeless Serif with a modern Sans-Serif), we create an environment that feels both ancient and cutting-edge. The interface should feel less like a software tool and more like a premium, digital sanctuary.

---

## 2. Colors & Surface Philosophy
The palette is rooted in the depth of the night sky (`primary: #00342b`) and the warmth of divine light (`secondary: #775a19`).

### The "No-Line" Rule
**Strict Mandate:** Traditional 1px solid borders are prohibited for sectioning. 
Structure must be defined through **Background Color Shifts**. For example, a `surface-container-low` card sitting on a `surface` background provides all the definition needed. If visual separation is required, use whitespace or a tonal shift, never a stroke.

### Surface Hierarchy & Nesting
Treat the UI as physical layers of "Fine Silk" or "Frosted Glass." Use the surface tiers to create nested depth:
*   **Base Layer:** `surface` (#f8f9fa)
*   **Secondary Content Area:** `surface-container-low` (#f3f4f5)
*   **Interactive Cards:** `surface-container-lowest` (#ffffff)
*   **Elevated Overlays:** Use `surface-bright` with 80% opacity and a 20px backdrop-blur.

### The "Glass & Gold" Rule
To elevate the "Modern Spiritual" feel, floating elements (like the prayer timeline) should utilize **Glassmorphism**. Apply `surface-tint` at 5% opacity with a heavy `backdrop-filter: blur(12px)`. 
*   **Signature Texture:** Use a linear gradient for primary CTAs: `primary` (#00342b) to `primary_container` (#004d40) at a 135-degree angle. This prevents the "flat" app look and adds "visual soul."

---

## 3. Typography
We use a dual-font system to balance tradition with modernity.

*   **The Serif (Noto Serif):** Used for `display` and `headline` roles. This provides the "Sacred" feel, evoking the elegance of printed scripture.
*   **The Sans (Manrope):** Used for `title`, `body`, and `labels`. This provides the "Modern" clarity required for high-frequency utility.

**Hierarchy Intent:**
*   **Display-LG (3.5rem):** Reserved for the current time or the countdown to the next prayer.
*   **Headline-SM (1.5rem):** Used for prayer names (e.g., Fajr, Maghrib).
*   **Body-MD (0.875rem):** Used for spiritual quotes or location settings.

---

## 4. Elevation & Depth
### Tonal Layering
Avoid the "Shadow-Heavy" look of 2010-era design. Depth is achieved by "stacking" surface tiers. Place a `surface-container-lowest` (#ffffff) card on a `surface-container` (#edeeef) background to create a soft, natural lift.

### Ambient Shadows
When a component must float (e.g., a "Tasbih" floating action button):
*   **Blur:** 24px to 40px.
*   **Opacity:** 4%–6%.
*   **Color:** Use a tinted shadow (`on-surface` with a hint of `primary`) rather than pure black to simulate natural, atmospheric light.

### The "Ghost Border" Fallback
If accessibility requires a border, use a **Ghost Border**: `outline-variant` (#bfc9c4) at 15% opacity. It should be felt, not seen.

---

## 5. Components

### The Prayer Timeline (Signature Component)
The circular analog-style timeline should use a `full` (9999px) roundedness. The "Current Time" indicator should glow using a `secondary_fixed` (#ffdea5) outer glow shadow to represent light.

### Buttons
*   **Primary:** Rounded `lg` (1rem). Gradient fill (`primary` to `primary_container`). White text. No border.
*   **Secondary:** `surface-container-highest` background with `on-surface` text.
*   **Tertiary:** Transparent background, `primary` text, `title-sm` weight.

### Cards & Lists
**Forbid the use of divider lines.** 
*   Separate list items using `1rem` of vertical whitespace.
*   For grouped content, use a `surface-container-low` background with a `lg` (1rem) corner radius.

### Input Fields
*   **Style:** Minimalist. No bottom line. Use `surface-container-highest` as a subtle background fill.
*   **Roundedness:** `md` (0.75rem).
*   **State:** On focus, transition the background to `surface-container-lowest` and add a 1px `primary` Ghost Border (20% opacity).

### Chips (Prayer Status)
*   **Selection:** Use `primary_fixed` background with `on_primary_fixed` text for an "Active" state.
*   **Unselected:** `surface-container-high` with `on_surface_variant` text.

---

## 6. Do's and Don'ts

### Do:
*   **Embrace Negative Space:** Give every element room to "breathe." Spiritual apps should feel calm, not cluttered.
*   **Use Asymmetric Padding:** Try using slightly more padding at the top of a card than the bottom (e.g., `pt-8 pb-6`) to create an editorial feel.
*   **Soft Transitions:** All hover and state changes should have a minimum `300ms` ease-in-out duration to maintain the peaceful vibe.

### Don't:
*   **Don't use pure black (#000000):** Use `on_surface` (#191c1d) for text to maintain softness.
*   **Don't use hard corners:** Every corner must have at least a `sm` (0.25rem) radius; however, `lg` (1rem) is the preferred standard for this system.
*   **Don't use standard Dividers:** If you feel the need to separate content, ask if you can do it with an extra `16px` of whitespace first. 
*   **Don't Over-Saturate:** Keep the Gold (`secondary`) for accents and "Moments of Light" only. The Teal (`primary`) is your anchor.```