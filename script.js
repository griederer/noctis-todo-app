// ===========================
// Visualization Gallery Controller
// ===========================

// Configuration object for available visualizations
const visualizations = {
    'biblical-logos': {
        component: 'BiblicalLogos',
        name: 'Biblical Logos',
        description: 'An interactive visualization exploring divine order through geometric patterns'
    },
    'particle-system': {
        component: 'ParticleSystem',
        name: 'Particle System',
        description: 'Dynamic particle interactions creating emergent patterns'
    },
    'flowing-torus-knot': {
        component: 'FlowingTorusKnot',
        name: 'Flowing Torus Knot',
        description: 'A breathing torus knot representing dissolution and reformation'
    },
    'infinite-visualization': {
        component: 'InfiniteVisualization',
        name: 'Infinite Spirals',
        description: 'Recursive spiral systems exploring the concept of infinity'
    },
    'wave-patterns': {
        component: 'WavePatterns',
        name: 'Wave Patterns',
        description: 'Mathematical wave interference and resonance visualization'
    }
};

// Global state
let currentVisualization = null;
let currentRoot = null;

// Initialize the application
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM loaded, initializing visualization gallery...');
    
    // Check which components are available
    console.log('Available components:', {
        BiblicalLogos: typeof window.BiblicalLogos,
        ParticleSystem: typeof window.ParticleSystem,
        FlowingTorusKnot: typeof window.FlowingTorusKnot,
        InfiniteVisualization: typeof window.InfiniteVisualization,
        WavePatterns: typeof window.WavePatterns
    });
    
    setupEventListeners();
    
    // Delay initial load to ensure all scripts are loaded
    setTimeout(() => {
        console.log('Loading initial visualization...');
        loadInitialVisualization();
    }, 500);
});

// Set up event listeners
function setupEventListeners() {
    const vizSelect = document.getElementById('viz-select');
    vizSelect.addEventListener('change', handleVisualizationChange);
    
    // Keyboard navigation
    document.addEventListener('keydown', handleKeyboardNavigation);
}

// Handle visualization selection change
function handleVisualizationChange(event) {
    const selectedViz = event.target.value;
    console.log('Switching to visualization:', selectedViz);
    switchVisualization(selectedViz);
}

// Load the initial visualization
function loadInitialVisualization() {
    const vizSelect = document.getElementById('viz-select');
    const initialViz = vizSelect.value;
    switchVisualization(initialViz);
}

// Switch to a new visualization
function switchVisualization(vizKey) {
    // Update content
    updateContent(vizKey);
    
    // Load and mount the visualization component
    loadVisualizationComponent(vizKey);
}

// Update the text content area
function updateContent(vizKey) {
    const contentAreas = document.querySelectorAll('.viz-content');
    
    // Hide all content areas
    contentAreas.forEach(area => {
        area.classList.remove('active');
    });
    
    // Show the selected content area
    const selectedContent = document.querySelector(`[data-viz="${vizKey}"]`);
    if (selectedContent) {
        selectedContent.classList.add('active');
    }
}

// Load and mount React visualization component
function loadVisualizationComponent(vizKey) {
    const vizConfig = visualizations[vizKey];
    if (!vizConfig) {
        console.error(`Visualization "${vizKey}" not found`);
        return;
    }
    
    console.log(`Loading component: ${vizConfig.component}`);
    
    const container = document.getElementById('viz-container');
    
    // Clear existing content
    if (currentRoot) {
        currentRoot.unmount();
        currentRoot = null;
    }
    
    // Add loading state
    container.classList.remove('active');
    
    // Small delay for transition
    setTimeout(() => {
        mountComponentWithRetry(vizConfig.component, container, 0);
    }, 100);
}

// Mount a React component with retry mechanism
function mountComponentWithRetry(componentName, container, retryCount) {
    console.log(`Attempting to mount component: ${componentName} (retry: ${retryCount})`);
    
    // Check if component exists
    const Component = window[componentName];
    
    console.log(`Component ${componentName} type:`, typeof Component);
    
    if (!Component && retryCount < 5) {
        // Component not loaded yet, retry after a delay
        console.log(`Component ${componentName} not ready, retrying in 200ms...`);
        setTimeout(() => {
            mountComponentWithRetry(componentName, container, retryCount + 1);
        }, 200);
        return;
    }
    
    if (!Component) {
        console.warn(`Component ${componentName} not found after ${retryCount} retries`);
        showPlaceholder(container, componentName);
        return;
    }
    
    mountComponent(componentName, container);
}

// Mount a React component
function mountComponent(componentName, container) {
    console.log(`Mounting component: ${componentName}`);
    
    const Component = window[componentName];
    
    // Clear container
    container.innerHTML = '';
    
    try {
        // Create React root and render component
        currentRoot = ReactDOM.createRoot(container);
        currentRoot.render(React.createElement(Component));
        
        console.log(`Successfully mounted ${componentName}`);
        
        // Activate container
        setTimeout(() => {
            container.classList.add('active');
        }, 50);
        
        currentVisualization = componentName;
    } catch (error) {
        console.error(`Error mounting component ${componentName}:`, error);
        showPlaceholder(container, componentName);
    }
}

// Show placeholder for components that aren't implemented yet
function showPlaceholder(container, componentName) {
    container.innerHTML = `
        <div style="
            color: rgba(255, 255, 255, 0.6);
            text-align: center;
            font-family: var(--font-sans);
            padding: 2rem;
        ">
            <h3 style="margin-bottom: 1rem; color: rgba(255, 255, 255, 0.8);">
                ${componentName} Coming Soon
            </h3>
            <p style="font-size: 0.875rem; line-height: 1.6;">
                This visualization is currently being developed.<br>
                Check back soon for updates!
            </p>
            <p style="font-size: 0.75rem; margin-top: 1rem; opacity: 0.7;">
                If this is unexpected, check the browser console for errors.
            </p>
        </div>
    `;
    
    setTimeout(() => {
        container.classList.add('active');
    }, 50);
}

// Handle keyboard navigation
function handleKeyboardNavigation(event) {
    const vizSelect = document.getElementById('viz-select');
    const options = Array.from(vizSelect.options);
    const currentIndex = vizSelect.selectedIndex;
    
    switch(event.key) {
        case 'ArrowLeft':
        case 'ArrowUp':
            event.preventDefault();
            if (currentIndex > 0) {
                vizSelect.selectedIndex = currentIndex - 1;
                vizSelect.dispatchEvent(new Event('change'));
            }
            break;
            
        case 'ArrowRight':
        case 'ArrowDown':
            event.preventDefault();
            if (currentIndex < options.length - 1) {
                vizSelect.selectedIndex = currentIndex + 1;
                vizSelect.dispatchEvent(new Event('change'));
            }
            break;
            
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
            event.preventDefault();
            const index = parseInt(event.key) - 1;
            if (index < options.length) {
                vizSelect.selectedIndex = index;
                vizSelect.dispatchEvent(new Event('change'));
            }
            break;
    }
}

// ===========================
// Utility Functions
// ===========================

// Add new visualization dynamically
// Usage: addVisualization('my-viz', 'MyComponent', 'My Visualization', 'Description here')
function addVisualization(key, componentName, displayName, description) {
    // Add to config
    visualizations[key] = {
        component: componentName,
        name: displayName,
        description: description
    };
    
    // Add option to dropdown
    const vizSelect = document.getElementById('viz-select');
    const option = document.createElement('option');
    option.value = key;
    option.textContent = displayName;
    vizSelect.appendChild(option);
    
    // You would also need to add corresponding content HTML
    console.log(`Added visualization: ${displayName}`);
}

// Check component availability (for debugging)
window.checkComponents = function() {
    console.log('Component availability check:');
    Object.keys(visualizations).forEach(key => {
        const viz = visualizations[key];
        const isAvailable = typeof window[viz.component] === 'function';
        console.log(`  ${viz.component}: ${isAvailable ? '✓ Available' : '✗ Not found'}`);
    });
};

// Example: How to add a new visualization
// This would typically be called after loading a new component script
/*
// In your new visualization file:
window.MyNewVisualization = () => {
    return React.createElement('div', null, 'My New Visualization');
};

// Then add it to the gallery:
addVisualization('my-new-viz', 'MyNewVisualization', 'My New Viz', 'A cool new visualization');

// Don't forget to also add the corresponding content section in the HTML
*/

// ===========================
// Instructions for adding new visualizations:
// ===========================
/*
To add a new visualization:

1. Create a new React component file in the visualizations folder:
   visualizations/MyVisualization.js
   
2. Make sure to export it to window object at the end:
   window.MyVisualization = MyVisualization;
   
3. Add a script tag in index.html:
   <script type="text/javascript" src="visualizations/MyVisualization.js"></script>
   
4. Add an option to the dropdown in index.html:
   <option value="my-visualization">My Visualization</option>
   
5. Add corresponding content section in index.html:
   <div data-viz="my-visualization" class="viz-content">
       <h2>My Visualization</h2>
       <p class="lead">Description...</p>
       ...
   </div>
   
6. Add to the visualizations config object above:
   'my-visualization': {
       component: 'MyVisualization',
       name: 'My Visualization',
       description: 'Description here'
   }
*/ 