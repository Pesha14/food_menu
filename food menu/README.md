# 🍽️ Food Menu App — Design Kit

A complete visual & design guide for building a **Staff Food Menu App** where employees log in, see their allocated balance, pick meals within that balance, and print a receipt.

---

## 📁 Folder Contents

```
food menu/
├── README.md                    ← this file
├── food-images/                 ← food photography (menu items)
│   ├── roasted-chicken.jpg
│   ├── beef-stew.jpg
│   ├── ugali-beef.jpg
│   ├── pilau.jpg
│   ├── chapati.jpg
│   ├── salad.jpg
│   ├── coffee.jpg
│   └── juice.jpg
└── app-mockups/                 ← how the improved app should look
    ├── mockup-login.jpg
    ├── mockup-home.jpg
    └── mockup-cart.jpg
```

---

## 🎯 App Concept

**Users:** Staff members with a pre‑loaded meal allowance (e.g. KSH 3,000/day).

**Flow:**
1. **Login** — staff enter a password (or PIN / staff card).
2. **Menu** — see today's food with photos, prices, and their remaining balance.
3. **Cart** — add items, quantities auto‑checked against the balance (cannot exceed it).
4. **Checkout** — print receipt on the thermal printer (same format as the sample receipt).

---

## 🎨 Recommended Look — "Midnight & Gold" (Classic Premium)

The current app uses a flat plain-purple Material style. It looks generic. The mockups in `app-mockups/` show a **classic, premium, restaurant-grade** direction.

### Color Palette

| Role        | Hex        | Usage                                    |
|-------------|------------|------------------------------------------|
| Background  | `#0B1220`  | Main app background (deep navy)          |
| Surface     | `#111C2E`  | Cards, sheets                            |
| Primary     | `#C9A24C`  | Buttons, highlights (warm gold)          |
| Accent      | `#E8C878`  | Hover / active gold                      |
| Text        | `#F5F1E6`  | Warm ivory (easier on the eye than white)|
| Muted text  | `#9AA3B2`  | Secondary text                           |
| Success     | `#4CAF77`  | Balance OK / order placed                |
| Danger      | `#E76F51`  | Insufficient balance                     |

### Typography

- **Display / titles:** *Playfair Display* or *Cormorant Garamond* (serif, editorial feel)
- **Body & UI:** *Inter* or *DM Sans* (clean, legible on small POS screens)
- **Numbers / prices:** tabular-nums, medium weight, gold color

### Visual Language

- **Cards with soft shadow + 16px radius** (not sharp Material rectangles)
- **Food photography** as the hero of every menu row — large square with rounded corners
- **Gold hairline dividers** instead of grey lines
- **Micro-animations** on Add / Remove (scale 0.96 → 1)
- **Empty balance state** shows a friendly illustration, not a blank screen

---

## 🧭 Three Design Directions You Can Explore

Look at `app-mockups/` for the primary "Midnight & Gold" direction. Here are three alternatives you can request:

### 1. **Midnight & Gold** (shown in mockups)
Dark navy + warm gold + serif titles. Feels like a high‑end hotel restaurant.
Best for: corporate cafeterias, executive dining.

### 2. **Warm Bistro** (cream + terracotta)
Cream background `#FAF4E8`, terracotta accents `#C4654A`, sage green `#87A878`, hand-lettered display font (*Fraunces*).
Best for: casual staff canteens, welcoming feel.

### 3. **Modern Minimal** (paper white + one bold accent)
Off-white `#F7F7F5`, near-black text `#111`, single vivid accent (e.g. electric coral `#FF5A5F`), grotesque font (*Space Grotesk*). Lots of whitespace, big typography, food photos framed in perfect squares.
Best for: modern tech-forward companies.

---

## 🛠️ How to Make the Code Look More Classic & Modern

The current mobile app uses default Material styling. Here's how to elevate it:

### 1. Replace default Material colors with a design token file
Instead of hard-coding `Colors.deepPurple`, define semantic tokens once:
```dart
class AppTokens {
  static const bg      = Color(0xFF0B1220);
  static const surface = Color(0xFF111C2E);
  static const gold    = Color(0xFFC9A24C);
  static const ivory   = Color(0xFFF5F1E6);
  // ...
}
```
Then every screen references `AppTokens.gold` — never a raw hex.

### 2. Custom ThemeData
Override `ThemeData` globally: font family, button shape (16px radius), elevated button gradient, input decoration border, scaffold background. One file → the whole app changes.

### 3. Replace the plain AppBar with a custom header
The current purple bar is generic. Use a `SliverAppBar` with:
- Serif "Welcome, {staff name}" title
- Gold-outlined circular avatar
- Balance chip on the right (pill, gold text on translucent surface)

### 4. Menu item cards
Current UI: a plain table row (`Item | Price | Add`).
Improved: a `Card` with:
- 72×72 rounded food image on the left
- Item name (serif, 18px) + description (14px muted)
- Price in gold, tabular figures
- `Add +` as a small filled circle button on the right
- Ripple on tap, subtle scale animation

### 5. Balance widget
Currently just text. Turn it into a **hero card** at the top:
- Wallet icon in a gold circle
- "Your Balance" label + big `KSH 3,000` amount
- Progress bar showing how much of today's allowance is left
- Colour turns amber below 30%, red below 10%

### 6. Cart screen
- Group items visually, each with its thumbnail
- +/– quantity steppers (gold outline)
- Sticky bottom sheet with Grand Total and a **full-width gold "Print Receipt" button**
- Confirmation dialog with a receipt preview before printing

### 7. Micro-interactions
- `AnimatedContainer` on card taps
- `Hero` transitions when opening item detail
- Haptic feedback on Add / Remove
- Success checkmark animation after "Print Receipt"

### 8. Typography discipline
Import Google Fonts once:
```dart
GoogleFonts.playfairDisplayTextTheme(base).copyWith(
  bodyMedium: GoogleFonts.inter(...),
)
```
Never use `TextStyle(fontSize: 14)` inline — always reference `Theme.of(context).textTheme.titleLarge` etc.

### 9. Empty & error states
- "Insufficient balance" → friendly message + illustration, not a red toast
- "No items yet" → gold icon + "Your cart is empty, pick something delicious"

### 10. Receipt format (matches the sample photo)
Keep the printer layout, but improve the header:
```
       ══════════════════
          MENU SYSTEM
       ══════════════════
       STAFF: test21
       DATE : 2026-07-08 11:09
       ─────────────────────────
       Item          Qty  Total
       ─────────────────────────
       Roasted Chicken 3  4500.00
       ─────────────────────────
       Subtotal:        KSH 4500
       Discount:        KSH 3000
       ─────────────────────────
       TO PAY:          KSH 1500
       ═════════════════════════
       Thank you for your service!
```

---

## 🖼️ Using the Food Images

Every menu item in the app should have a real photo. The 8 images in `food-images/` cover the common items. To wire them into the app:

- Upload each JPG to the backend's `product.image_url` field, **or**
- Bundle them in the mobile app under `assets/food/` and reference by name.

Recommended sizes:
- List thumbnail: **160×160**
- Detail view: **1024×1024** (original)

---

## ✅ Next Steps

1. Show these mockups to your team and pick one direction (Midnight & Gold, Warm Bistro, or Modern Minimal).
2. Extract the color tokens into a single theme file in the mobile app.
3. Replace the current flat menu list with the card-based layout shown in `mockup-home.jpg`.
4. Add the food images to your product catalog so every item has a picture.
5. Rebuild the receipt printer template to match the improved header shown above.

That's it — same functionality, dramatically better feel.
