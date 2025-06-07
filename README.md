# Noctis To Do

A beautiful, modern to-do application with helix interference pattern aesthetics. Built with React, featuring clean lines, subtle animations, and a calming design inspired by balance and duality.

## Features

- ✨ Clean, minimal interface with helix animation design
- 📝 Add, edit, delete, and mark tasks as complete
- 📅 Each task includes title, description (optional), date, and time
- ⏰ Time selection with 30-minute intervals (switchable to 15 minutes)
- 🔍 Filter tasks by status (All, Active, Completed)
- 🗂️ Sort tasks by date or time
- 💾 Local storage persistence
- 📱 Responsive design for desktop and mobile
- 🎨 Subtle animations and hover effects
- 🎯 Dynamic helix patterns representing balance

## Getting Started

### Prerequisites

- Node.js (v14 or higher)
- npm or yarn

### Installation

1. Clone or download this repository
2. Navigate to the project directory:
   ```bash
   cd noctis-todo-app
   ```

3. Install dependencies:
   ```bash
   npm install
   ```

### Running the Application

Start the development server:
```bash
npm start
```

The application will open in your browser at `http://localhost:3000`

### Building for Production

To create a production build:
```bash
npm run build
```

The optimized files will be in the `build` directory.

## Design Inspiration

The application features:
- Soft cream background (#F0EEE6)
- Dynamic helix interference patterns
- Subtle particle animations
- Clean, precise typography
- Harmonious color palette
- Balance-inspired hover effects

## Technologies Used

- React 18
- CSS3 with CSS Variables
- Local Storage API
- Modern JavaScript (ES6+)
- Canvas API for animations

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers

Find balance in your tasks with Noctis To Do! 🌙 

# Visualization Gallery

A clean, split-screen web application for showcasing interactive React-based data visualizations with accompanying explanatory text. Inspired by the minimal aesthetic of [thewayofcode.com](https://www.thewayofcode.com).

## Features

- **Split-screen layout**: 50/50 view with visualizations on the left, text content on the right
- **React integration**: Uses React via CDN for creating interactive visualizations
- **Easy navigation**: Dropdown selector to switch between different visualizations
- **Responsive design**: Automatically stacks vertically on mobile devices
- **Smooth transitions**: Fade effects when switching between visualizations
- **Extensible architecture**: Simple system for adding new visualizations

## Current Visualizations

1. **Biblical Logos**: An interactive visualization exploring divine order through geometric patterns, featuring 7 concentric circles, 24 radial lines, and 144 seed particles
2. **Particle System**: Dynamic particle interactions with mouse repulsion, gravity, and network connections
3. **Flowing Torus Knot**: A Three.js visualization showing dissolution and reformation cycles over 5 minutes with flowing red particles
4. **Infinite Spirals**: Recursive spiral systems with an infinity symbol at the center, exploring concepts of boundless expansion

## Project Structure

```
.
├── index.html              # Main HTML file
├── styles.css              # Styling for the split-screen layout
├── script.js               # Visualization switching logic
├── visualizations/         # Directory for React visualization components
│   ├── BiblicalLogos.js    # Divine order visualization
│   ├── ParticleSystem.js   # Interactive particle network
│   ├── FlowingTorusKnot.js # Three.js dissolution/reformation
│   └── InfiniteVisualization.js # Recursive spiral systems
└── README.md              # This file
```

## Getting Started

1. Open `index.html` in a web browser (no build process required!)
2. Use the dropdown in the navigation header to switch between visualizations
3. Interact with visualizations using your mouse where applicable

## Adding New Visualizations

To add a new visualization, follow these steps:

### 1. Create the React Component

Create a new file in the `visualizations/` directory:

```javascript
// visualizations/MyVisualization.js
const MyVisualization = () => {
  return React.createElement('div', {
    style: {
      color: 'white',
      fontSize: '2rem',
      textAlign: 'center'
    }
  }, 'My Amazing Visualization');
};

// Important: Export to window object
window.MyVisualization = MyVisualization;
```

### 2. Include the Script

Add a script tag in `index.html` before the main script:

```html
<script type="text/babel" src="visualizations/MyVisualization.js"></script>
```

### 3. Add to Dropdown

Add an option to the visualization selector in `index.html`:

```html
<option value="my-visualization">My Visualization</option>
```

### 4. Add Content Section

Add the corresponding text content in `index.html`:

```html
<div data-viz="my-visualization" class="viz-content">
    <h2>My Visualization</h2>
    <p class="lead">A brief description of your visualization.</p>
    <p>More detailed explanation here...</p>
</div>
```

### 5. Register the Visualization

Add your visualization to the configuration object in `script.js`:

```javascript
const visualizations = {
    // ... existing visualizations ...
    'my-visualization': {
        component: 'MyVisualization',
        name: 'My Visualization',
        description: 'Brief description here'
    }
};
```

## Customization

### Colors and Typography

Edit the CSS variables in `styles.css`:

```css
:root {
    --color-bg-dark: #1A1A1A;      /* Left side background */
    --color-bg-secondary: #FFFFFF;  /* Right side background */
    --color-text-primary: #1A1A1A;  /* Main text color */
    --color-accent: #0066FF;        /* Accent color */
    /* ... more variables ... */
}
```

### Layout

The split-screen ratio can be adjusted in `styles.css`:

```css
.visualization-section {
    width: 50%;  /* Change this value */
}

.content-section {
    width: 50%;  /* Should total 100% */
}
```

## Tips for Creating Visualizations

1. **Canvas-based visualizations**: Use `React.useRef()` to get a reference to the canvas element
2. **Three.js visualizations**: Three.js is included via CDN, check for its availability with `typeof THREE !== 'undefined'`
3. **Cleanup**: Always clean up animations and event listeners in the `useEffect` cleanup function
4. **Responsive sizing**: Consider the container size when setting canvas dimensions
5. **Dark background**: Design your visualizations to look good on the dark left panel

## Technologies Used

- React 18 (via CDN)
- Three.js (via CDN for 3D visualizations)
- HTML5 Canvas API
- CSS3 with CSS Variables
- Vanilla JavaScript (ES6+)
- Babel Standalone (for JSX transformation)

## Browser Support

- Modern browsers with ES6+ support
- React 18 via CDN
- CSS Grid and Flexbox support required

## Development Tips

- No build process needed - just edit and refresh!
- Use browser developer tools for debugging
- Test responsive behavior by resizing the browser window
- Console errors will help identify missing components or syntax issues

## License

This project is open source and available for educational and commercial use. 