import React from 'react';
import '../styles/TodoItem.css';

const TodoItem = React.memo(({ todo, onToggleComplete, onDelete, onEdit, index }) => {
  const formatDueDateTime = () => {
    if (!todo.dueDate) return null;
    
    const date = new Date(todo.dueDate);
    const today = new Date();
    const tomorrow = new Date();
    tomorrow.setDate(today.getDate() + 1);
    
    let dateStr;
    if (date.toDateString() === today.toDateString()) {
      dateStr = 'Today';
    } else if (date.toDateString() === tomorrow.toDateString()) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = date.toLocaleDateString([], { month: 'short', day: 'numeric' });
    }
    
    if (todo.dueTime) {
      const timeStr = new Date(`2000-01-01T${todo.dueTime}`).toLocaleTimeString([], { 
        hour: '2-digit', 
        minute: '2-digit',
        hour12: true 
      });
      return `${dateStr} at ${timeStr}`;
    }
    
    return dateStr;
  };

  const isOverdue = () => {
    if (!todo.dueDate || todo.completed) return false;
    const dueDateTime = todo.dueDateTime ? new Date(todo.dueDateTime) : new Date(todo.dueDate);
    return dueDateTime < new Date();
  };

  return (
    <div 
      className={`todo-item ${todo.completed ? 'completed' : ''} ${isOverdue() ? 'overdue' : ''}`}
      style={{ animationDelay: `${index * 0.05}s` }}
    >
      <button
        className={`todo-checkbox ${todo.completed ? 'checked' : ''}`}
        onClick={() => onToggleComplete(todo.id, !todo.completed)}
        aria-label={todo.completed ? 'Mark as incomplete' : 'Mark as complete'}
      >
        {todo.completed && (
          <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
            <path d="M3 8L6 11L13 4" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        )}
      </button>

      <div className="todo-content">
        <div className="todo-title">{todo.title}</div>
        {formatDueDateTime() && (
          <div className={`todo-due-date ${isOverdue() ? 'overdue' : ''}`}>
            <svg width="12" height="12" viewBox="0 0 16 16" fill="currentColor">
              <path d="M8 0a8 8 0 1 1 0 16A8 8 0 0 1 8 0zM1.5 8a6.5 6.5 0 1 0 13 0 6.5 6.5 0 0 0-13 0zm7-3.25v2.992l2.028.812a.75.75 0 0 1-.557 1.392l-2.5-1A.751.751 0 0 1 7 8.25v-3.5a.75.75 0 0 1 1.5 0z"/>
            </svg>
            {formatDueDateTime()}
          </div>
        )}
      </div>

      <span className={`todo-priority priority-${todo.priority || 'medium'}`}>
        {todo.priority || 'medium'}
      </span>

      <div className="todo-actions">
        <button
          className="todo-action delete-btn"
          onClick={() => onDelete(todo.id)}
          aria-label="Delete task"
        >
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
            <path d="M4 4L12 12M12 4L4 12" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
      </div>
    </div>
  );
});

TodoItem.displayName = 'TodoItem';

export default TodoItem; 