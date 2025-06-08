import React from 'react';
import '../styles/FilterBar.css';

function FilterBar({ filter, setFilter, todoCount, activeCount, completedCount }) {
  return (
    <div className="todo-filter-bar">
      <div className="todo-filter-group">
        <span className="todo-filter-label">View:</span>
        <button
          className={`todo-filter-btn ${filter === 'all' ? 'active' : ''}`}
          onClick={() => setFilter('all')}
        >
          All Entries
        </button>
        <button
          className={`todo-filter-btn ${filter === 'active' ? 'active' : ''}`}
          onClick={() => setFilter('active')}
        >
          Active
        </button>
        <button
          className={`todo-filter-btn ${filter === 'completed' ? 'active' : ''}`}
          onClick={() => setFilter('completed')}
        >
          Completed
        </button>
      </div>

      <div className="todo-filter-group">
        <span className="todo-filter-label">Statistics:</span>
        <div className="todo-stats">
          <span className="stat-item">
            <span className="stat-number">{todoCount}</span> total
          </span>
          <span>|</span>
          <span className="stat-item">
            <span className="stat-number">{activeCount}</span> active
          </span>
          <span>|</span>
          <span className="stat-item">
            <span className="stat-number">{completedCount}</span> done
          </span>
        </div>
      </div>
    </div>
  );
}

export default FilterBar; 