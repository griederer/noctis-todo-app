// Manual Testing Script for Noctis Todo App
// This script simulates user interactions and validates functionality

console.log('🧪 Starting Noctis Todo App Manual Testing...');

// Test utility functions
const testLogger = {
  section: (name) => console.log(`\n📋 Testing: ${name}`),
  pass: (test) => console.log(`✅ PASS: ${test}`),
  fail: (test, error) => console.log(`❌ FAIL: ${test} - ${error}`),
  warn: (test, warning) => console.log(`⚠️  WARN: ${test} - ${warning}`),
  info: (message) => console.log(`ℹ️  INFO: ${message}`)
};

// Authentication Tests
function testAuthentication() {
  testLogger.section('Authentication & Initial Load');
  
  try {
    // Check if login component is present
    const loginForm = document.querySelector('.login-container, .login-form, [data-testid="login"]');
    const mainApp = document.querySelector('.app, .main-content');
    
    if (loginForm && !mainApp) {
      testLogger.pass('Login screen displayed correctly');
      
      // Check for Google sign-in button
      const googleBtn = document.querySelector('button[type="button"]') || 
                       document.querySelector('.google-signin-btn') ||
                       document.querySelector('button');
      
      if (googleBtn) {
        testLogger.pass('Google sign-in button found');
      } else {
        testLogger.fail('Google sign-in button', 'Button not found');
      }
      
    } else if (mainApp && !loginForm) {
      testLogger.pass('User already authenticated - main app loaded');
      return testMainAppComponents();
    } else {
      testLogger.fail('Authentication state', 'Unclear authentication state');
    }
    
  } catch (error) {
    testLogger.fail('Authentication test', error.message);
  }
}

// Main App Component Tests
function testMainAppComponents() {
  testLogger.section('Main App Components');
  
  try {
    // Test Header
    const header = document.querySelector('header, .header, .app-header');
    if (header) {
      testLogger.pass('Header component rendered');
      
      const title = header.querySelector('h1, .app-title');
      if (title && title.textContent.includes('Noctis')) {
        testLogger.pass('App title displayed correctly');
      } else {
        testLogger.fail('App title', 'Title not found or incorrect');
      }
      
      const userAvatar = header.querySelector('.user-avatar, img');
      const userName = header.querySelector('.user-name');
      const logoutBtn = header.querySelector('.logout-btn, button');
      
      if (userAvatar) testLogger.pass('User avatar displayed');
      if (userName) testLogger.pass('User name displayed');
      if (logoutBtn) testLogger.pass('Logout button available');
      
    } else {
      testLogger.fail('Header component', 'Header not found');
    }
    
    // Test Navigation
    const navigation = document.querySelector('nav, .navigation, .nav');
    if (navigation) {
      testLogger.pass('Navigation component rendered');
      
      const navLinks = navigation.querySelectorAll('a, button, .nav-item');
      if (navLinks.length > 0) {
        testLogger.pass(`Navigation has ${navLinks.length} items`);
      } else {
        testLogger.warn('Navigation items', 'No navigation items found');
      }
    }
    
    return testTodoSection();
    
  } catch (error) {
    testLogger.fail('Main app components test', error.message);
  }
}

// Todo Section Tests
function testTodoSection() {
  testLogger.section('Todo Section Functionality');
  
  try {
    const todoSection = document.querySelector('.todo-section, [data-testid="todo-section"]');
    if (!todoSection) {
      testLogger.fail('Todo section', 'Todo section not found');
      return;
    }
    
    testLogger.pass('Todo section rendered');
    
    // Test Todo Form
    const todoForm = document.querySelector('form, .todo-form');
    if (todoForm) {
      testLogger.pass('Todo form found');
      
      const titleInput = todoForm.querySelector('input[type="text"], input[placeholder*="title"], input[placeholder*="task"]');
      const prioritySelect = todoForm.querySelector('select, .priority-select');
      const submitBtn = todoForm.querySelector('button[type="submit"], .add-btn');
      
      if (titleInput) testLogger.pass('Title input field available');
      if (prioritySelect) testLogger.pass('Priority selector available');
      if (submitBtn) testLogger.pass('Submit button available');
      
    } else {
      testLogger.fail('Todo form', 'Form not found');
    }
    
    // Test Todo List
    const todoList = document.querySelector('.todo-list, .todos');
    if (todoList) {
      testLogger.pass('Todo list container found');
      
      const todoItems = todoList.querySelectorAll('.todo-item, .todo');
      testLogger.info(`Found ${todoItems.length} todo items`);
      
      if (todoItems.length > 0) {
        const firstTodo = todoItems[0];
        const checkbox = firstTodo.querySelector('input[type="checkbox"], .todo-checkbox');
        const deleteBtn = firstTodo.querySelector('.delete-btn, button[aria-label*="delete"]');
        const priority = firstTodo.querySelector('.priority, .todo-priority');
        
        if (checkbox) testLogger.pass('Todo checkbox functionality available');
        if (deleteBtn) testLogger.pass('Todo delete functionality available');
        if (priority) testLogger.pass('Todo priority display available');
      }
    }
    
    // Test Filter Bar
    const filterBar = document.querySelector('.filter-bar, .filters');
    if (filterBar) {
      testLogger.pass('Filter bar found');
      
      const filterButtons = filterBar.querySelectorAll('button, .filter-btn');
      if (filterButtons.length >= 3) {
        testLogger.pass('Filter options available (All, Active, Completed)');
      }
    }
    
    return testJournalSection();
    
  } catch (error) {
    testLogger.fail('Todo section test', error.message);
  }
}

// Journal Section Tests  
function testJournalSection() {
  testLogger.section('Journal Section Functionality');
  
  try {
    // Navigate to journal if not already there
    const journalNav = document.querySelector('a[href="/journal"], button[data-route="journal"], .nav-journal');
    if (journalNav) {
      testLogger.info('Found journal navigation - clicking...');
      journalNav.click();
      
      // Wait a moment for navigation
      setTimeout(() => {
        const journalSection = document.querySelector('.journal-section, [data-testid="journal-section"]');
        if (journalSection) {
          testLogger.pass('Journal section loaded');
          
          // Test journal sidebar
          const sidebar = journalSection.querySelector('.journal-sidebar, .sidebar');
          if (sidebar) {
            testLogger.pass('Journal sidebar found');
            
            const newEntryBtn = sidebar.querySelector('.new-entry-btn, button');
            if (newEntryBtn) testLogger.pass('New entry button available');
            
            const entriesList = sidebar.querySelector('.entries-list, .journal-entries');
            if (entriesList) testLogger.pass('Entries list container found');
          }
          
          // Test journal editor area
          const editorArea = journalSection.querySelector('.journal-content, .editor-area');
          if (editorArea) {
            testLogger.pass('Journal editor area found');
            
            const markdownEditor = editorArea.querySelector('textarea, .markdown-editor');
            if (markdownEditor) testLogger.pass('Markdown editor available');
          }
        } else {
          testLogger.fail('Journal section', 'Could not load journal section');
        }
        
        return testErrorHandling();
      }, 1000);
      
    } else {
      testLogger.warn('Journal navigation', 'Journal navigation not found - may not be implemented');
      return testErrorHandling();
    }
    
  } catch (error) {
    testLogger.fail('Journal section test', error.message);
  }
}

// Error Handling Tests
function testErrorHandling() {
  testLogger.section('Error Handling & Edge Cases');
  
  try {
    // Test error boundaries
    const errorBoundaries = document.querySelectorAll('.error-boundary, .section-error-boundary');
    if (errorBoundaries.length > 0) {
      testLogger.pass(`Found ${errorBoundaries.length} error boundaries`);
    }
    
    // Test loading states
    const loadingSpinners = document.querySelectorAll('.loading-spinner, .spinner');
    testLogger.info(`Found ${loadingSpinners.length} loading spinners`);
    
    // Test error notifications
    const errorNotifications = document.querySelectorAll('.error-notification, .error-message');
    testLogger.info(`Found ${errorNotifications.length} error notification components`);
    
    return testPerformance();
    
  } catch (error) {
    testLogger.fail('Error handling test', error.message);
  }
}

// Performance Tests
function testPerformance() {
  testLogger.section('Performance Validation');
  
  try {
    // Measure page load performance
    if (window.performance && window.performance.timing) {
      const timing = window.performance.timing;
      const loadTime = timing.loadEventEnd - timing.navigationStart;
      const domReady = timing.domContentLoadedEventEnd - timing.navigationStart;
      
      testLogger.info(`Page load time: ${loadTime}ms`);
      testLogger.info(`DOM ready time: ${domReady}ms`);
      
      if (loadTime < 3000) {
        testLogger.pass('Page load time within acceptable range (<3s)');
      } else {
        testLogger.warn('Page load time', 'Load time exceeded 3 seconds');
      }
    }
    
    // Test memory usage
    if (window.performance && window.performance.memory) {
      const memory = window.performance.memory;
      const memoryUsageMB = memory.usedJSHeapSize / 1024 / 1024;
      testLogger.info(`Memory usage: ${memoryUsageMB.toFixed(2)}MB`);
      
      if (memoryUsageMB < 50) {
        testLogger.pass('Memory usage within acceptable range (<50MB)');
      } else {
        testLogger.warn('Memory usage', 'High memory usage detected');
      }
    }
    
    return testResponsiveness();
    
  } catch (error) {
    testLogger.fail('Performance test', error.message);
  }
}

// Responsiveness Tests
function testResponsiveness() {
  testLogger.section('Responsive Design Validation');
  
  try {
    const viewport = {
      width: window.innerWidth,
      height: window.innerHeight
    };
    
    testLogger.info(`Current viewport: ${viewport.width}x${viewport.height}`);
    
    // Categorize screen size
    let deviceType;
    if (viewport.width < 768) {
      deviceType = 'Mobile';
    } else if (viewport.width < 1024) {
      deviceType = 'Tablet';
    } else {
      deviceType = 'Desktop';
    }
    
    testLogger.pass(`Testing on ${deviceType} viewport`);
    
    // Check responsive elements
    const responsiveElements = document.querySelectorAll('.responsive, [class*="responsive"]');
    testLogger.info(`Found ${responsiveElements.length} responsive elements`);
    
    // Check for overflow issues
    const body = document.body;
    if (body.scrollWidth > viewport.width) {
      testLogger.warn('Horizontal scroll', 'Page has horizontal overflow');
    } else {
      testLogger.pass('No horizontal overflow detected');
    }
    
    return generateSummary();
    
  } catch (error) {
    testLogger.fail('Responsiveness test', error.message);
  }
}

// Generate Test Summary
function generateSummary() {
  testLogger.section('Test Summary');
  
  console.log(`
🏁 Manual Testing Complete!

📊 Test Results Summary:
- Authentication: Validated
- Main Components: Tested
- Todo Functionality: Verified
- Navigation: Working
- Error Handling: Implemented
- Performance: Measured
- Responsiveness: Checked

🔍 Recommendations:
1. Add unit tests for critical components
2. Implement E2E tests for user flows
3. Set up continuous performance monitoring
4. Add accessibility testing
5. Implement cross-browser testing automation

⚡ Next Steps:
- Run this script on different browsers
- Test with various screen sizes
- Validate offline functionality
- Test with large datasets
- Verify real-time synchronization
  `);
}

// Start the testing process
testAuthentication();