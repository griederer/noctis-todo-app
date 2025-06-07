import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Header from './components/Header';
import Navigation from './components/Navigation';
import TodoSection from './components/TodoSection';
import JournalSection from './components/JournalSection';
import HabitsSection from './components/HabitsSection';
import HelixAnimation from './components/HelixAnimation';
import Login from './components/Login';
import ErrorBoundary from './components/ErrorBoundary';
import SectionErrorBoundary from './components/SectionErrorBoundary';
import LoadingSpinner from './components/LoadingSpinner';
import { useAuth } from './contexts/AuthContext';
import './styles/App.css';
import './styles/ScientificElements.css';

function App() {
  const { loading, isAuthenticated } = useAuth();

  // Show loading state
  if (loading) {
    return (
      <div className="app dark-theme">
        <HelixAnimation />
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
        <div className="app dark-theme">
          {/* Scientific decorative elements */}
          <div className="anatomical-watermark"></div>
          <div className="manuscript-stain"></div>
          <div className="manuscript-stain"></div>
          <div className="manuscript-stain"></div>
          <div className="math-notation" style={{ content: '"∑ⁿᵢ₌₁"' }}>∑ⁿᵢ₌₁</div>
          <div className="math-notation" style={{ content: '"∫∞₀"' }}>∫∞₀</div>
          
          <ErrorBoundary>
            <Header />
          </ErrorBoundary>
          <ErrorBoundary>
            <Navigation />
          </ErrorBoundary>
          <main className="main-content">
            <Routes>
              <Route path="/" element={<Navigate to="/todo" />} />
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
                  <HabitsSection />
                </SectionErrorBoundary>
              } />
            </Routes>
          </main>
        </div>
      </Router>
    </ErrorBoundary>
  );
}

export default App; 