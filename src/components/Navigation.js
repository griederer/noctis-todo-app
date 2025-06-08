import React from 'react';
import { NavLink } from 'react-router-dom';
import '../styles/Navigation.css';

function Navigation() {
  return (
    <nav className="main-navigation">
      {/* Scientific measurement marks and coordinates */}
      <div className="scientific-notation coordinates" style={{ position: 'absolute', top: '5px', left: '10px', fontSize: '10px' }}>0,0</div>
      <div className="blueprint-element dimension-line" style={{ position: 'absolute', top: '5px', right: '50px' }}></div>
      
      <NavLink to="/today" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
        <span className="nav-icon">🌅</span>
        <span className="nav-text">Today</span>
      </NavLink>
      <NavLink to="/todo" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
        <span className="nav-icon">✓</span>
        <span className="nav-text">Todo</span>
      </NavLink>
      <NavLink to="/journal" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
        <span className="nav-icon">📝</span>
        <span className="nav-text">Journal</span>
      </NavLink>
      <NavLink to="/habits" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
        <span className="nav-icon">📊</span>
        <span className="nav-text">Habits</span>
      </NavLink>
      
      <div className="crosshair" style={{ position: 'absolute', top: '50%', right: '10px', transform: 'translateY(-50%)' }}>
        <div className="circle"></div>
      </div>
    </nav>
  );
}

export default Navigation;