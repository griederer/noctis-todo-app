import React from 'react';
import { useAuth } from '../contexts/AuthContext';
import { logout } from '../firebase/auth';
import '../styles/Header.css';

function Header() {
  const { user } = useAuth();
  

  const handleLogout = async () => {
    try {
      await logout();
    } catch (error) {
      console.error('Error logging out:', error);
    }
  };

  return (
    <header className="header">
      <div className="logo-container">
        <h1 className="app-title">Noctis</h1>
      </div>
      <div className="user-section">
        {user?.photoURL && (
          <img 
            src={user.photoURL} 
            alt={user.displayName || 'User'} 
            className="user-avatar"
          />
        )}
        <span className="user-name">{user?.displayName || user?.email || 'User'}</span>
        <button className="logout-btn" onClick={handleLogout}>
          Sign out
        </button>
      </div>
    </header>
  );
}

export default Header; 