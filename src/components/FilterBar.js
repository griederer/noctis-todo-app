import React from 'react';
import '../styles/FilterBar.css';

function FilterBar({ filter, setFilter, todoCount, activeCount, completedCount }) {
  return (
    <div className="filter-bar">
      <div className="filter-section">
        <button
          className={`filter-btn ${filter === 'all' ? 'active' : ''}`}
          onClick={() => setFilter('all')}
        >
          All
        </button>
        <button
          className={`filter-btn ${filter === 'active' ? 'active' : ''}`}
          onClick={() => setFilter('active')}
        >
          Active
        </button>
        <button
          className={`filter-btn ${filter === 'completed' ? 'active' : ''}`}
          onClick={() => setFilter('completed')}
        >
          Completed
        </button>
      </div>

      <div className="todo-stats">
        <div className="stat-item">
          <span className="stat-number">{todoCount}</span>
          <span>total</span>
        </div>
        <span>•</span>
        <div className="stat-item">
          <span className="stat-number">{activeCount}</span>
          <span>active</span>
        </div>
        <span>•</span>
        <div className="stat-item">
          <span className="stat-number">{completedCount}</span>
          <span>done</span>
        </div>
      </div>
    </div>
  );
}

export default FilterBar; 