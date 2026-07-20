# xclock Specification

## 1. Purpose of This Document

This document records the design specification of the HTML5 Canvas version of xclock.

- Current version: v1.1.1
- v1.1.1 keeps the v1.1.0 second-hand feature while bringing the standard minute-hand position and second-hand shape closer to the original xclock
- This document records the values and behavior implemented in v1.1.1

The README files are user-facing documents. This specification describes internal behavior, design decisions, and the relationship to the original X11 xclock.

## 2. Project Overview

This is a small analog clock inspired by the classic X11 `xclock`.

- Uses HTML5 Canvas
- Uses plain JavaScript only
- Has no external library dependencies
- Keeps a small, single-HTML-centered structure
- Runs as an approximately 200×200 Chrome app-mode window
- Is also published as a normal web page through GitHub Pages

## 3. Design Principles

- Match the appearance and movement of the original xclock where practical
- Do not port the original C/X11 implementation literally
- Prefer simple, readable, Canvas-native drawing code
- Keep the second hand disabled by default
- Preserve the standard no-second-hand display and one-minute redraw interval
- Avoid excessive configuration options
- Avoid large-scale class design, module splitting, or duplicated clock implementations
- Prioritize practical personal usability

## 4. File Structure

Main files:

- `index.html`: Clock application
- `xclock.bat`: Chrome app-mode launcher
- `xclock.ico`: Icon
- `README.md`: Japanese README
- `README-EN.md`: English README
- `LICENSE.txt`: License
- `images/screenshot.png`: Screenshot
- `docs/SPEC.md`: Japanese specification
- `docs/SPEC-EN.md`: English specification

## 5. Common Display Specification

- White background
- Black drawing color
- The clock is drawn in a square Canvas based on the shorter window dimension
- The clock face remains circular
- The Canvas is centered in the window
- No scrollbars
- Text selection is disabled
- High-DPI displays are supported

### 5.1 Canvas Sizing

`resizeCanvas()` performs the following:

- Uses the smaller of `window.innerWidth` and `window.innerHeight` as the CSS size
- Uses `window.devicePixelRatio` to scale the internal pixel dimensions
- Uses `ctx.setTransform()` so later coordinates remain in CSS pixels

## 6. Clock Face Specification

### 6.1 Radius

```javascript
const radius = diameter * 0.46;
```

### 6.2 Tick Marks

- 60 tick marks
- Five-minute marks are longer and thicker
- One-minute marks are shorter and thinner
- Line caps use `butt`

Current values:

```javascript
const outer = radius * 0.985;
const inner = isHour ? radius * 0.900 : radius * 0.945;
```

Line widths:

```javascript
isHour
  ? Math.max(1.35, radius * 0.0085)
  : Math.max(1.00, radius * 0.0058);
```

## 7. Hour and Minute Hands

### 7.1 Shape

- The hour and minute hands are filled black isosceles triangles
- Their tips are pointed
- Their bases extend slightly behind the center
- Both are drawn by `drawTriangleHand()`

### 7.2 Current Ratios

```javascript
// Hour hand
drawTriangleHand(..., radius, 0.40, 0.068);

// Minute hand
drawTriangleHand(..., radius, 0.68, 0.068);
```

Rear extension:

```javascript
-radius * 0.075
```

### 7.3 Center Circle

- A filled black center circle is drawn after the hour and minute hands
- Radius:

```javascript
Math.max(1.5, radius * 0.017)
```

## 8. v1.1.1 Time Calculation

Regardless of whether the second hand is enabled, the minute-hand position includes the current second value. This matches the hand-position calculation of the original xclock.

```javascript
const seconds = now.getSeconds();
const minutes = now.getMinutes() + seconds / 60;
const hours = (now.getHours() % 12) + now.getMinutes() / 60;
```

- The minute hand includes seconds in its position
- The hour hand includes minutes
- Seconds do not affect the hour hand
- With the second hand disabled, the redraw interval remains one minute

## 9. v1.0.1 Update Scheduling

### 9.1 Minute-Boundary Synchronization

The application does not use `setInterval()`. It calculates the delay to the next minute boundary and uses `setTimeout()`.

```javascript
const delay =
  (60 - now.getSeconds()) * 1000 - now.getMilliseconds();
```

The delay is recalculated after every drawing, preventing accumulated timer drift.

### 9.2 Resize

On window resize:

1. Resize the Canvas
2. Redraw immediately using the current time

### 9.3 Visibility Restoration

When the page becomes visible again, the application waits 300 milliseconds so that browsers such as Android browsers can finish restoring the viewport. It then:

1. Recalculates the Canvas size
2. Redraws using the current time
3. Clears the previous timer
4. Schedules the next second or minute boundary update

This reduces the chance that the clock appears smaller and shifted to the left after the browser has been backgrounded and the device has slept.

## 10. v1.1.0 Second-Hand Option

### 10.1 Enabling the Option

The official URL parameter is:

```text
?seconds=1
```

Behavior:

- No parameter: second hand disabled
- `?seconds=1`: second hand enabled
- `?seconds=0`: disabled
- `?seconds=true`: disabled
- `?seconds=false`: disabled
- Any other value: disabled

Implementation:

```javascript
const params = new URLSearchParams(window.location.search);
const showSeconds = params.get("seconds") === "1";
```

URL parameter values are strings. Only `1` is accepted to avoid unnecessary aliases and ambiguity.

### 10.2 Relationship to Original xclock

The original xclock does not use a dedicated Boolean second-hand option. Its `-update seconds` option controls update frequency, and values of 30 seconds or less enable the second hand in analog mode. The HTML version does not expose arbitrary update intervals; it uses the clearer `seconds=1` option.

## 11. v1.1.0 Second-Hand Design

### 11.1 Appearance

The second hand is based on the visual appearance of the original xclock.

```text
center ───────── thin line ───── ◆ ── short tip line
```

- Thin black line
- Filled black diamond near the tip
- Diamond centered symmetrically on the hand axis
- A short line remains beyond the diamond
- No red color
- Not a wide triangular hand
- No prominent rear tail behind the center
- No second-hand-specific center decoration

### 11.2 Canvas Implementation

The original multi-vertex, single-polygon implementation is not ported literally.

`drawSecondHand()` draws:

1. One line from the center to the tip
2. One filled diamond near the tip, over the line

The line continues beneath the diamond to avoid any visible gap.

Reasons for this implementation:

- Easier to understand
- Easier to adjust
- More natural for Canvas
- Can produce nearly the same visual result
- Easier to maintain

### 11.3 Implemented Dimensions

Let the clock-face radius be `radius`.

```javascript
const length = radius * 0.935;
const diamondCenter = radius * 0.80;
const diamondHalfLength = radius * 0.105;
const diamondHalfWidth = radius * 0.045;
const lineWidth = Math.max(1.5, radius * 0.013);
```

- The second-hand length is 93.5% of the radius
- The diamond center is at 80% of the radius
- The diamond's full length along the hand is 21% of the radius
- The diamond's full width is 9% of the radius
- A line equal to 3% of the radius remains beyond the front of the diamond
- The second hand is longer than the minute hand
- The line width has a minimum of 1.5 CSS pixels

## 12. v1.1.1 Hand Movement

Regardless of whether the second hand is enabled, hand-position calculations follow the original xclock behavior.

### 12.1 Second Hand

- One discrete step per second
- One tick mark per second
- Milliseconds are not used in the angle
- No smooth sweeping motion

```javascript
const seconds = now.getSeconds();
```

### 12.2 Minute Hand

- Includes seconds in its position
- With the second hand enabled, it moves slightly every second
- With the second hand disabled, it includes the current second value whenever the clock is redrawn

```javascript
const minutes = now.getMinutes() + now.getSeconds() / 60;
```

### 12.3 Hour Hand

- Includes minutes in its position
- Does not include seconds
- Remains fixed during the same minute and advances when the minute changes

```javascript
const hours =
  (now.getHours() % 12) + now.getMinutes() / 60;
```

With the second hand enabled:

```text
Second hand: moves once per second
Minute hand: moves slightly once per second
Hour hand: moves slightly once per minute
```

With the second hand disabled:

```text
Second hand: not drawn
Minute hand: points to the position including the second value at redraw time
Hour hand: points to the position including the minute value
Redraw: at each minute boundary
```

## 13. v1.1.1 Update Scheduling

### 13.1 Generalized Timer

`minuteTimerId` and `scheduleNextMinute()` will be generalized to handle both seconds and minutes.

Expected names:

```text
timerId
scheduleNextDraw()
```

### 13.2 Second Hand Enabled

Wait until the next whole-second boundary.

```javascript
const delay = 1000 - now.getMilliseconds();
```

The current time is read again after every timer event, so delay does not accumulate.

### 13.3 Second Hand Disabled

Wait until the next minute boundary. The minute-hand position includes the second value at the time of drawing, while the redraw interval remains one minute.

### 13.4 Timer Margin

No timer margin will be added initially. A small margin may be considered only if real testing shows execution just before the intended boundary.

## 14. v1.1.0 Drawing Structure

The current small function structure will be preserved.

```text
resizeCanvas()
point()
fillPolygon()
drawTicks()
drawTriangleHand()
drawSecondHand()       new
 drawClock()
scheduleNextDraw()     generalized from scheduleNextMinute()
```

- Do not duplicate the full clock implementation for the two modes
- Clock face, ticks, hour hand, and minute hand remain shared
- Add the second hand only when `showSeconds` is enabled

Conceptual flow:

```javascript
drawTicks(...);

if (showSeconds) {
  drawSecondHand(...);
}

drawTriangleHand(...); // Hour hand
drawTriangleHand(...); // Minute hand
```

## 15. Drawing Order

Implemented order:

1. Background
2. Tick marks
3. Second hand
4. Hour hand
5. Minute hand
6. Center circle

Drawing the second hand first allows the existing hands and center circle to hide its center area naturally.

The final order will be verified against the original xclock image after implementation. The center-circle dimensions should normally remain unchanged to preserve the standard mode.

## 16. Performance

With the second hand enabled, drawing frequency increases from once per minute to once per second. The Canvas is only about 200×200.

Each redraw consists mainly of:

- Clearing the Canvas
- Drawing 60 tick marks
- Drawing three hands
- Drawing the center circle
- A few time calculations
- Scheduling the next timer

This is one redraw per second, not a 60-frames-per-second animation. The practical CPU cost is expected to remain small. `requestAnimationFrame()` will not be used.

## 17. xclock.bat Specification

### 17.1 Organized Settings

Editable values will be grouped at the beginning of the file.

```bat
rem ============================================================
rem xclock display settings
rem ============================================================
set "WINDOW_WIDTH=200"
set "WINDOW_HEIGHT=200"
set "SHOW_SECONDS=0"

rem ============================================================
rem Google Chrome settings
rem ============================================================
set "CHROME=C:\Program Files\Google\Chrome\Application\chrome.exe"
set "XCLOCK_PROFILE=%LOCALAPPDATA%\xclock-chrome-profile"

rem ============================================================
rem xclock file settings
rem ============================================================
set "XCLOCK_HTML=%~dp0index.html"
```

A separator will identify the internal processing section.

```bat
rem ============================================================
rem Internal processing
rem Normally, do not edit below this line
rem ============================================================
```

### 17.2 Second-Hand Setting

- `SHOW_SECONDS=1`: enabled
- Any other value: disabled

Only when enabled, the batch file creates a query string.

```bat
set "XCLOCK_QUERY="
set "XCLOCK_URL_PATH=%XCLOCK_HTML:\=/%"

if "%SHOW_SECONDS%"=="1" (
  set "XCLOCK_QUERY=?seconds=1"
)
```

### 17.3 Local file URL

Keep the existing working Windows-path conversion and append only the query string.

```bat
--app="file:///%XCLOCK_URL_PATH%%XCLOCK_QUERY%"
```

Example:

```text
file:///C:/path/to/xclock/index.html?seconds=1
```

Chrome opens `index.html` as a local file and exposes `?seconds=1` to the page as the URL query string.

### 17.4 Window Size

Replace the current fixed option:

```bat
--window-size=200,200
```

with:

```bat
--window-size=%WINDOW_WIDTH%,%WINDOW_HEIGHT%
```

No separate second-hand batch file will be added.

## 18. Browser Usage

### 18.1 Chrome

- Official local-app usage
- Uses `--app`
- Uses a dedicated `user-data-dir`
- Intended for an approximately 200×200 small window

### 18.2 Firefox

- Can display the GitHub Pages version as a normal web page
- Current minimum app-window width prevents the same small-window usage as Chrome
- This Firefox limitation will not be documented in the README files

## 19. README Changes

For v1.1.0, both Japanese and English README files will mention:

- The second hand is disabled by default
- Add `?seconds=1` to display it
- The second hand moves in one-second steps
- Set `SHOW_SECONDS=1` in the batch file
- Window width and height can be configured in the batch file

Internal dimensions, calculation formulas, and drawing details will remain in this specification rather than the README.

## 20. Versioning

This release is `v1.1.1`.

- Refines the second-hand diamond to more closely match the original xclock
- Includes seconds in the standard-mode minute-hand position
- Preserves the standard one-minute redraw interval and existing URL/batch options
- Updates the Japanese and English specifications to match the implementation

Under the common `MAJOR.MINOR.PATCH` convention, this is a PATCH release because it refines and corrects existing behavior.

```text
v1.1.0 → v1.1.1
```

## 21. Post-Implementation Test Checklist

### 21.1 Standard Mode

- No parameter produces the same appearance as v1.0.1
- No second hand
- Updates on the minute boundary
- No unintended changes to ticks, hands, or center circle

### 21.2 URL Parameters

- `?seconds=1` enables the second hand
- `?seconds=0` disables it
- `?seconds=true` disables it
- Unknown values disable it

### 21.3 Second-Hand Appearance

- Appears as a thin line
- Has a diamond near the tip
- Has a short line beyond the diamond
- Does not look excessively like an arrowhead
- Is longer than the minute hand
- Remains readable at 200×200
- Remains visible on high-DPI displays
- Looks close to the original xclock

### 21.4 Hand Movement

- Second hand advances one tick per second
- Minute hand advances slightly every second
- Hour hand remains fixed during the same minute
- Hour hand advances when the minute changes
- No millisecond-based smooth movement
- Correct positions at 0, 15, 30, and 45 seconds

### 21.5 Timers and Events

- Updates approximately on second boundaries
- No accumulated long-term drift
- No duplicate timers
- Restores the correct time after becoming visible
- Maintains proportions after resizing

### 21.6 Batch File

- `SHOW_SECONDS=0` disables the second hand
- `SHOW_SECONDS=1` enables it
- Width and height settings work
- Chrome path, profile path, and HTML path remain configurable
- The local file URL query is passed correctly
- Existing Chrome app-mode startup remains functional

## 22. Known Tuning Items

The following will be finalized after implementation and visual testing:

- Total second-hand length
- Second-hand line width
- Diamond position and proportions
- Line length beyond the diamond
- Drawing order relative to the other hands
- Optional timer margin, if real testing shows it is needed

These are visual and environment-specific tuning values, not missing functional requirements.

## 23. References

- X.Org xclock manual: https://www.x.org/archive/X11R7.5/doc/man/man1/xclock.1.html
- X.Org xclock project: https://gitlab.freedesktop.org/xorg/app/xclock

