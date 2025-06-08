import React from 'react';
import { NavLink } from 'react-router-dom';
import '../styles/ScientificNavigation.css';

function Navigation() {
  return (
    <nav className="main-navigation">
      <div className="nav-corner-accent left"></div>
      
      <NavLink to="/today" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
        <span className="nav-icon">🔬</span>
        <span className="nav-text">Analysis</span>
      </NavLink>
      <NavLink to="/todo" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
        <span className="nav-icon">✓</span>
        <span className="nav-text">Tasks</span>
      </NavLink>
      <NavLink to="/journal" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
        <span className="nav-icon">📝</span>
        <span className="nav-text">Notes</span>
      </NavLink>
      <NavLink to="/habits" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
        <span className="nav-icon">🧪</span>
        <span className="nav-text">Matrix</span>
      </NavLink>
      
      <div className="nav-corner-accent right"></div>
      <div className="nav-annotations">v2.1.0 - productivity research interface</div>
    </nav>
  );
}

export default Navigation;