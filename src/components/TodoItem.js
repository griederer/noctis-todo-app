import React from 'react';

const TodoItem = React.memo(({ todo, onToggleComplete, onDelete, onEdit, onSelect, isSelected, index }) => {
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

  const handleClick = (e) => {
    // Don't select if clicking on checkbox or action buttons
    if (e.target.closest('.todo-checkbox') || e.target.closest('.todo-actions')) {
      return;
    }
    onSelect && onSelect(todo);
  };

  return (
    <div 
      className={`todo-item ${todo.completed ? 'completed' : ''} ${isSelected ? 'selected' : ''} animate-fade-in`}
      style={{ animationDelay: `${index * 0.05}s` }}
      onClick={handleClick}
    >
      <button
        className={`todo-checkbox ${todo.completed ? 'checked' : ''}`}
        onClick={(e) => {
          e.stopPropagation();
          onToggleComplete(todo.id, !todo.completed);
        }}
        aria-label={todo.completed ? 'Mark as incomplete' : 'Mark as complete'}
      />

      <div className="todo-content">
        <div className="todo-title">{todo.title}</div>
        <div className="todo-meta">
          {todo.project && <span>{todo.project}</span>}
          {formatDueDateTime() && (
            <span className={isOverdue() ? 'text-danger-red' : ''}>
              {formatDueDateTime()}
            </span>
          )}
          {todo.priority && todo.priority !== 'medium' && (
            <span className={`priority-${todo.priority}`}>
              {todo.priority} priority
            </span>
          )}
        </div>
      </div>
    </div>
  );
});

TodoItem.displayName = 'TodoItem';

export default TodoItem; 