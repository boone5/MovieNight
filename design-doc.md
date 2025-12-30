# 🎬 Pop'n iOS Design System

*A modern cinema-inspired design system for discovering, rating, organizing, and sharing movies & TV — like Spotify, but for film.*

---

## 1. Design Principles

**Cinema-first**
Inspired by classic movie theatres: rich reds, warm golds, soft off-whites, and subtle metallic neutrals.

**Content is the Star**
Posters, stills, and artwork take center stage. UI should frame content, not compete with it.

**Modern iOS Native**
Feels at home on iOS: Dynamic Type–friendly, SF conventions, high contrast, smooth motion.

**Dark Room Friendly**
Dark mode is a first-class experience — like watching a movie in a theatre.

---

## 2. Color System

### Core Brand Colors

| Token            | Hex       | Role                                 |
| ---------------- | --------- | ------------------------------------ |
| **Pop Red**      | `#DC2026` | Primary brand, CTAs, highlights      |
| **Deep Red**     | `#7E1616` | Emphasis, pressed states, gradients  |
| **Buttercream**  | `#FFFEAD` | Warm accent, ratings, success states |
| **Gold Popcorn** | `#FCC252` | Secondary accent, badges, icons      |
| **Ivory White**  | `#FDFCFA` | Primary light background             |
| **Cinema Gray**  | `#C0C1C1` | Borders, dividers, secondary text    |

---

### Semantic Color Tokens (Light & Dark)

#### Backgrounds

| Token                  | Light Mode | Dark Mode | Usage            |
| ---------------------- | ---------- | --------- | ---------------- |
| `background`      | `#FDFCFA`  | `#000000` | App background   |
| `background.card` | `#FFFFFF`  | `#1C1C1E` | Cards, sheets    |

#### Text

Use system font colors where possible.

`Color.primary` and `Color.secondary` automatically adapt to light/dark mode.

---

## 3. Typography System

Pop'n uses **two complementary typefaces**:

1. **Montserrat** - Modern, cinematic display
2. **Open Sans** - Clean, legible UI text

### Font Pairing

#### 🎥 Display Font — *Montserrat*

A bold, elegant serif for headlines and titles, evoking classic cinema posters.

**Usage:**

* Movie & TV titles
* Section headers
* Marketing moments
* Hero screens

**Weights:**

* Semibold
* Bold

```swift
Font.montserrat(28, weight: .bold)
```

---

#### 🎬 UI Font — **Open Sans**

A versatile sans-serif for body text and UI elements, ensuring readability across all sizes.

**Usage:**

* Body text
* Buttons
* Metadata
* Forms
* Navigation

**Weights:**

* Regular
* Medium
* Semibold

```swift
Font.openSans(17, weight: .regular)
```

## 4. Iconography

* **SF Symbols first** (outlined preferred)