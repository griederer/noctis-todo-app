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
    <li 
      className={`todo-item ${todo.completed ? 'completed' : ''} ${isOverdue() ? 'overdue' : ''} slide-in-left`}
      style={{ animationDelay: `${index * 0.05}s` }}
    >
      <div className="todo-item-header">
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: 'var(--spacing-md)' }}>
          <button
            className={`todo-item-checkbox ${todo.completed ? 'checked' : ''}`}
            onClick={() => onToggleComplete(todo.id, !todo.completed)}
            aria-label={todo.completed ? 'Mark as incomplete' : 'Mark as complete'}
          />

          <div className="todo-item-content">
            <h4 className="todo-item-title">{todo.title}</h4>
            <div className="todo-item-meta">
              {formatDueDateTime() && (
                <span className={`todo-item-date ${isOverdue() ? 'overdue' : ''}`}>
                  {formatDueDateTime()}
                </span>
              )}
              <span className="todo-item-priority">
                {todo.priority || 'medium'} priority
              </span>
            </div>
          </div>
        </div>

        <div className="todo-item-actions">
          <button
            className="todo-action-btn edit"
            onClick={() => onEdit && onEdit(todo.id, { title: prompt('Edit task:', todo.title) || todo.title })}
            aria-label="Edit task"
          >
            ✎
          </button>
          <button
            className="todo-action-btn delete"
            onClick={() => onDelete(todo.id)}
            aria-label="Delete task"
          >
            ✕
          </button>
        </div>
      </div>
    </li>
  );
});

TodoItem.displayName = 'TodoItem';

export default TodoItem; 