import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Header from './components/Header';
import Navigation from './components/Navigation';
import TodoSection from './components/TodoSection';
import JournalSection from './components/JournalSection';
import SimpleHabitsSection from './components/SimpleHabitsSection';
import DailyDashboard from './components/DailyDashboard';
import Login from './components/Login';
import ErrorBoundary from './components/ErrorBoundary';
import SectionErrorBoundary from './components/SectionErrorBoundary';
import LoadingSpinner from './components/LoadingSpinner';
import { useAuth } from './contexts/AuthContext';
import './styles/VintageScientific.css';
import './styles/VintageScientificAnimations.css';
import './styles/ScientificApp.css';

function App() {
  const { loading, isAuthenticated } = useAuth();

  // Show loading state
  if (loading) {
    return (
      <div className="app loading">
        <LoadingSpinner size="large" message="Initializing app..." />
      </div>
    );
  }

  // Show login if not authenticated
  if (!isAuthenticated) {
    return <Login />;
  }

  // Show main app
  return (
    <ErrorBoundary>
      <Router>
        <div className="app-container">
          {/* Scientific Background Elements */}
          <div className="scientific-bg"></div>
          
          <div className="app">
            {/* Technical Corner Markings */}
            <div className="technical-corner top-left"></div>
            <div className="technical-corner top-right"></div>
            <div className="technical-corner bottom-left"></div>
            <div className="technical-corner bottom-right"></div>
          
          <ErrorBoundary>
            <Header />
          </ErrorBoundary>
          <ErrorBoundary>
            <Navigation />
          </ErrorBoundary>
          <main className="main-content">
            <Routes>
              <Route path="/" element={<Navigate to="/today" />} />
              <Route path="/today" element={
                <SectionErrorBoundary 
                  sectionName="Daily Dashboard" 
                  fallbackMessage="There was an error loading your daily dashboard. Please try again."
                >
                  <DailyDashboard />
                </SectionErrorBoundary>
              } />
              <Route path="/todo" element={
                <SectionErrorBoundary 
                  sectionName="Todo Section" 
                  fallbackMessage="There was an error loading your tasks. Please try again."
                >
                  <TodoSection />
                </SectionErrorBoundary>
              } />
              <Route path="/journal" element={
                <SectionErrorBoundary 
                  sectionName="Journal Section" 
                  fallbackMessage="There was an error loading your journal. Please try again."
                >
                  <JournalSection />
                </SectionErrorBoundary>
              } />
              <Route path="/habits" element={
                <SectionErrorBoundary 
                  sectionName="Habits Section" 
                  fallbackMessage="There was an error loading your habits tracker. Please try again."
                >
                  <SimpleHabitsSection />
                </SectionErrorBoundary>
              } />
            </Routes>
          </main>
          </div>
        </div>
      </Router>
    </ErrorBoundary>
  );
}

export default App; 