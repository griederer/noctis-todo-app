import React from 'react';

const Sidebar = ({ activeView, onViewChange, todoStats }) => {
  const navItems = [
    {
      id: 'today',
      title: 'Today',
      icon: '⭐',
      count: todoStats?.today || 0,
      path: '/today'
    },
    {
      id: 'upcoming',
      title: 'Upcoming',
      icon: '📅',
      count: todoStats?.upcoming || 0,
      path: '/upcoming'
    },
    {
      id: 'all',
      title: 'All Tasks',
      icon: '📋',
      count: todoStats?.total || 0,
      path: '/todo'
    },
    {
      id: 'completed',
      title: 'Completed',
      icon: '✅',
      count: todoStats?.completed || 0,
      path: '/completed'
    }
  ];

  const projectItems = [
    {
      id: 'work',
      title: 'Work',
      icon: '💼',
      count: 0,
      color: '#3B82F6'
    },
    {
      id: 'personal',
      title: 'Personal',
      icon: '🏠',
      count: 0,
      color: '#10B981'
    },
    {
      id: 'shopping',
      title: 'Shopping',
      icon: '🛒',
      count: 0,
      color: '#F59E0B'
    }
  ];

  return (
    <div className="sidebar">
      <div className="sidebar-header">
        <h1 className="sidebar-title">Noctis</h1>
        <p className="text-sm text-text-secondary">Task Management</p>
      </div>
      
      <nav className="sidebar-nav">
        {/* Main Navigation */}
        <div className="nav-section">
          <h3 className="nav-section-title">Main</h3>
          {navItems.map((item) => (
            <button
              key={item.id}
              onClick={() => onViewChange(item.path)}
              className={`nav-item ${activeView === item.path ? 'active' : ''}`}
            >
              <span className="nav-item-icon">{item.icon}</span>
              <span className="flex-1 text-left">{item.title}</span>
              {item.count > 0 && (
                <span className="nav-item-count">{item.count}</span>
              )}
            </button>
          ))}
        </div>

        {/* Projects */}
        <div className="nav-section">
          <h3 className="nav-section-title">Projects</h3>
          {projectItems.map((item) => (
            <button
              key={item.id}
              onClick={() => onViewChange(`/project/${item.id}`)}
              className={`nav-item ${activeView === `/project/${item.id}` ? 'active' : ''}`}
            >
              <span className="nav-item-icon">{item.icon}</span>
              <span className="flex-1 text-left">{item.title}</span>
              {item.count > 0 && (
                <span 
                  className="nav-item-count"
                  style={{ backgroundColor: item.color }}
                >
                  {item.count}
                </span>
              )}
            </button>
          ))}
          
          {/* Add Project Button */}
          <button className="nav-item text-text-tertiary hover:text-accent-blue">
            <span className="nav-item-icon">+</span>
            <span className="flex-1 text-left">Add Project</span>
          </button>
        </div>

        {/* Quick Actions */}
        <div className="nav-section">
          <h3 className="nav-section-title">Quick Actions</h3>
          <button 
            onClick={() => onViewChange('/habits')}
            className={`nav-item ${activeView === '/habits' ? 'active' : ''}`}
          >
            <span className="nav-item-icon">🎯</span>
            <span className="flex-1 text-left">Habits</span>
          </button>
          <button 
            onClick={() => onViewChange('/journal')}
            className={`nav-item ${activeView === '/journal' ? 'active' : ''}`}
          >
            <span className="nav-item-icon">📝</span>
            <span className="flex-1 text-left">Journal</span>
          </button>
        </div>
      </nav>
    </div>
  );
};

export default Sidebar;