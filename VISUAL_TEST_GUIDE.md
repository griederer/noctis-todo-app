# 🧪 Visual Test Guide - Noctis App

## 🚀 App is running at: http://localhost:3000

---

## 📋 Test 1: Enhanced Scientific Design

### What to Look For:
- **Grid Pattern**: White lines forming a grid (should be clearly visible)
- **Mathematical Formulas**: Look for "∑ⁿᵢ₌₁" and "∫∞₀" in the background
- **Crosshair Patterns**: Technical compass diagram with circles and cross lines
- **Vintage Stains**: Brown/sepia colored spots (coffee stain effect)
- **Corner Annotations**: Dashed square in top-right corner

✅ **Success**: If you can clearly see grid lines and mathematical symbols
❌ **Issue**: If background looks plain black with no patterns

---

## 📋 Test 2: Navigation

### What to Test:
1. You should see **3 tabs**: TODO, JOURNAL, HABITS
2. Click each tab - they should highlight when active
3. Each section should load without errors

✅ **Success**: All 3 tabs work and show different content
❌ **Issue**: Missing tabs or sections don't load

---

## 📋 Test 3: Habits Section (Most Important)

### Step-by-Step Test:

1. **Click "HABITS" tab**
   - You should see "Habit Tracker" title
   - Daily Score circle (shows 0% if no habits completed)
   - Category filters: All, Sleep & Rest, Physical Health, etc.

2. **Look for Debug Panel** (top-right corner)
   - Shows: `showAddHabit = false`
   - Shows: `User: Logged in`
   - Shows: `Habits count: [number]`

3. **Click "+ Add New Habit" button**
   - Modal should appear with dark overlay
   - Title: "Choose a Habit to Track"
   - Categories with habits listed below

4. **Test Adding a Habit**
   - Find any habit (e.g., "Consistent Sleep Schedule")
   - Click "Add" button next to it
   - Modal should close
   - Habit should appear in your grid

5. **Test Completing a Habit**
   - Click "Mark Complete" on any habit card
   - Card should turn green
   - Score should update in the circle
   - Button should change to "✓ Completed"

✅ **Success**: Can add habits and mark them complete
❌ **Issue**: Button doesn't work or modal doesn't appear

---

## 📋 Test 4: Todo Section

### What to Test:
1. Type a new todo in the input field
2. Select priority (Low/Medium/High)
3. Set a date and time (optional)
4. Click "Add Todo"
5. Try completing a todo by clicking checkbox

✅ **Success**: Can create and complete todos
❌ **Issue**: Can't add todos or they don't appear

---

## 📋 Test 5: Journal Section

### What to Test:
1. Click "JOURNAL" tab
2. Click "+ New Entry"
3. Should open in edit mode (dark text area)
4. Type some text
5. Click "Save"

✅ **Success**: Text is visible while typing (not white on white)
❌ **Issue**: Can't see text or white area appears

---

## 🎯 Quick Checklist:

- [ ] Grid patterns visible throughout app
- [ ] Mathematical formulas in background
- [ ] All 3 navigation tabs work
- [ ] "+ Add New Habit" button opens modal
- [ ] Can add habits from modal
- [ ] Can mark habits as complete
- [ ] Daily score updates when completing habits
- [ ] Todo creation works
- [ ] Journal text is visible when typing

---

## 🔧 If Something Doesn't Work:

1. **Refresh the page** (Ctrl+F5 or Cmd+Shift+R)
2. **Check if logged in** - Look for login screen
3. **Open browser console** (F12) - Look for red errors
4. **Try a different browser** if issues persist

---

## 📊 Expected Results:

### Habits Section Should Show:
- Daily Score Circle (0-100%)
- Category filters
- "+ Add New Habit" button
- Grid of habit cards (after adding)
- Points and streaks on each card

### Scientific Design Should Show:
- Grid lines (clearly visible)
- Mathematical formulas (∑, ∫ symbols)
- Compass/crosshair patterns
- Vintage brown stains
- Dashed corner decorations

---

**The app is running at http://localhost:3000 - Test it now!**